// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

error SpotiNftMarketplace__AlreadyRegistered(
   address artist_address,
   bool created
);

error SpotiNftMarketplace__NotRegistered(
   address artist_address,
   bool created
);

contract SpotiNftMarketplace is ERC721URIStorage {
   using Counters for Counters.Counter;

   address payable public owner;
   Counters.Counter private tokenIds;
   SpotiAlbum[] public albums;
   mapping (address => Artist) artists;


   modifier alreadyRegistered(){
      Artist memory _artist = artists[msg.sender]; 
      if(_artist.created){
         revert SpotiNftMarketplace__AlreadyRegistered(
            msg.sender,
            _artist.created
         );
      }
      _;
   }

   modifier checkRegistration(){
      Artist memory _artist = artists[msg.sender]; 
      if(!_artist.created){
         revert SpotiNftMarketplace__NotRegistered(
            msg.sender,
            _artist.created
         );
      }
      _;
   }

   
   struct Artist {
      address artist_address;
      string name;
      uint256 tokenId;
      bool created;
   }

   constructor() ERC721(
      "SpotiNft",
      "SNFT"
   ){
      owner = payable(msg.sender);
   }

   function register(
      string memory profilePic,
      string memory name
   ) public payable alreadyRegistered{
      tokenIds.increment();
      uint256 newTokenId = tokenIds.current();

      _safeMint(msg.sender, newTokenId);
      _setTokenURI(newTokenId, profilePic);

      artists[msg.sender] = Artist(
         msg.sender,
         name,
         newTokenId,
         true
      );
   }

   function unregister() public {
      delete artists[msg.sender];
   }

   function createAlbum() public {

   }
}

error SpotiAlbum__OnlyOwner();

contract SpotiAlbum is ERC721URIStorage{
   address payable public artist;
   string public albumCover;
   mapping(uint256 => SpotiSong) public songs;
   mapping(uint256 => SpotiSongBought) public boughtSongs;

   using Counters for Counters.Counter;

   Counters.Counter private tokenIds;
   Counters.Counter private itemsSold;
   Counters.Counter private songIds;
   Counters.Counter private totalSongs;

   struct SpotiSong {
      uint256 id;
      uint256 total_bought;
      string url;
      uint256 timestamp;
   }
   struct SpotiSongBought {
      uint256 tokenId;
      uint256 songId;
   }

   event SongBought (
      uint256 indexed songId,
      address indexed buyer,
      uint256 indexed total_bought
   );

   modifier onlyOwner(){
      if(msg.sender != artist){
         revert SpotiAlbum__OnlyOwner();
      }
      _;
   }

   constructor(
      string memory _name, 
      string memory _symbol,
      string memory _albumCover,
      string[] memory _songs
   ) ERC721(
      _name,
      _symbol
   ) {
      artist = payable(msg.sender);
      albumCover = _albumCover;
      setSongs(_songs);
   }

   function buySong(uint256 songId) public payable {
      tokenIds.increment();
      uint256 newTokenId = tokenIds.current();
      SpotiSong storage song = songs[songId];
      _safeMint(msg.sender, newTokenId);
      _setTokenURI(newTokenId, song.url);
      song.total_bought++;
      emit SongBought(songId, msg.sender, song.total_bought);
   }

   function addSong(string memory uri) private onlyOwner {
      uint256 id = songIds.current();
      songs[id] = SpotiSong(
         id,
         0,
         uri,
         block.timestamp
      );
      totalSongs.increment();
   }

   function setSongs(string[] memory _songs) internal onlyOwner {
      for(uint256 i = 0; i < _songs.length; i++){
         uint256 id = songIds.current(); 
         songs[id] = SpotiSong(
            id,
            0,
            _songs[i],
            block.timestamp
         );
         songIds.increment();
      }
      totalSongs._value = _songs.length;
   }
}