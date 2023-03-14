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
      token_ids.increment();
      uint256 new_token_id = token_ids.current();

      _safeMint(msg.sender, new_token_id);
      _setTokenURI(new_token_id, profilePic);

      artists[msg.sender] = Artist(
         msg.sender,
         name,
         new_token_id,
         true,
         new address[](0)
      );
      artistsArray.push(msg.sender);
   }
}