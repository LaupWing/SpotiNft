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
   mapping(address => address) private albums;
   mapping(address => Artist) private artists;
   address[] private artistsArray;


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
      artistsArray.push(msg.sender);
   }

   function unregister() public checkRegistration{
      delete artists[msg.sender];
   }

   function createAlbum(
      string memory _name, 
      string memory _symbol,
      string memory _albumCover,
      string[] memory _song_uris,
      uint256[] memory _song_prices,
      uint256 _albumPrice
   ) public checkRegistration{
      address createdAlbum = address(new SpotiAlbum(
         _name,
         _symbol,
         _albumCover,
         _song_uris,
         _song_prices,
         _albumPrice
      ));
      albums[createdAlbum] = msg.sender;
   }

   function getAllArtists() public view returns(Artist[] memory){
      Artist[] memory ret = new Artist[](artistsArray.length);

      for (uint256 i = 0; i < artistsArray.length; i ++){
         ret[i] = artists[artistsArray[i]];
      }
      return ret;
   }
}

error SpotiAlbum__OnlyOwner();

contract SpotiAlbum is ERC721URIStorage{
   address payable public artist;
   string public albumCover;
   uint256 public albumPrice;
   mapping(uint256 => SpotiSong) public songs;
   mapping(uint256 => SpotiSongBought) public boughtSongs;

   using Counters for Counters.Counter;

   Counters.Counter private tokenIds;
   Counters.Counter private itemsSold;
   Counters.Counter private songIds;
   Counters.Counter private totalSongs;

   struct SpotiSong {
      uint256 id;
      uint256 price;
      string url;
      uint256 total_bought;
      uint256 timestamp;
   }
   struct SpotiSongBought {
      uint256 tokenId;
      uint256 songId;
   }

   event SongBought (
      uint256 indexed songId,
      address indexed buyer,
      uint256 indexed price,
      uint256 total_bought
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
      string[] memory _song_uris,
      uint256[] memory _song_prices,
      uint256 _albumPrice
   ) ERC721(
      _name,
      _symbol
   ) {
      artist = payable(msg.sender);
      albumCover = _albumCover;
      setSongs(_song_uris, _song_prices);
      albumPrice = _albumPrice;
   }

   function buySong(uint256 songId) public payable {
      tokenIds.increment();
      uint256 newTokenId = tokenIds.current();
      SpotiSong storage song = songs[songId];
      _safeMint(msg.sender, newTokenId);
      _setTokenURI(newTokenId, song.url);
      song.total_bought++;
      emit SongBought(
         songId, 
         msg.sender, 
         song.price,
         song.total_bought
      );
   }

   function addSong(string memory uri, uint256 price) private onlyOwner {
      uint256 id = songIds.current();
      songs[id] = SpotiSong(
         id,
         price,
         uri,
         0,
         block.timestamp
      );
      totalSongs.increment();
   }

   function setSongs(string[] memory song_uris, uint256[] memory song_prices) internal onlyOwner {
      for(uint256 i = 0; i < song_uris.length; i++){
         uint256 id = songIds.current(); 
         songs[id] = SpotiSong(
            id,
            song_prices[i],
            song_uris[i],
            0,
            block.timestamp
         );
         songIds.increment();
      }
      totalSongs._value = song_uris.length;
   }
}