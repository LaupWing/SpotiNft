// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./SpotiNftAlbum.sol";

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
   Counters.Counter private token_ids;

   address payable public owner;
   mapping(address => address) private albums;
   mapping(address => Artist) private artists;
   address[] private artistsArray;

   struct Artist {
      address artist_address;
      string name;
      uint256 tokenId;
      bool created;
      address[] albums;
   }

   event AlbumCreated (
      address indexed album_address,
      string indexed name
   );

   event ArtistCreated (
      address indexed artist_address,
      uint256 indexed token_id,
      string indexed name
   );

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

   constructor() ERC721(
      "SpotiNft",
      "SNFT"
   ){
      owner = payable(msg.sender);
   }

   function register(
      string memory _profile_pic,
      string memory _name
   ) public payable alreadyRegistered{
      token_ids.increment();
      uint256 new_token_id = token_ids.current();

      _safeMint(msg.sender, new_token_id);
      _setTokenURI(new_token_id, _profile_pic);

      artists[msg.sender] = Artist(
         msg.sender,
         _name,
         new_token_id,
         true,
         new address[](0)
      );
      artistsArray.push(msg.sender);
      emit ArtistCreated(
         msg.sender,
         new_token_id,
         _name
      );
   }

   function getAllArtists() public view returns(Artist[] memory){
      Artist[] memory ret = new Artist[](artistsArray.length);

      for (uint256 i = 0; i < artistsArray.length; i ++){
         ret[i] = artists[artistsArray[i]];
      }
      return ret;
   }

   function myInfo() public view returns(Artist memory) {
      return artists[msg.sender];
   }

   function createAlbum(
      string memory _name,
      string memory _cover_uri,
      string[] memory _song_uris,
      string[] memory _song_names,
      uint256 _song_price,
      uint256 _album_price
   ) public checkRegistration{
      address createdAlbum = address(new SpotiNftAlbum(
         _name,
         _cover_uri,
         _album_price,
         _song_uris,
         _song_names,
         _song_price
      ));
      albums[createdAlbum] = msg.sender;
      Artist storage artist = artists[msg.sender];
      artist.albums.push(createdAlbum);

      emit AlbumCreated(createdAlbum, _name);
   }
}