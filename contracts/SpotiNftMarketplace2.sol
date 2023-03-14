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
   Counters.Counter private tokenIds;

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
      tokenIds.increment();
      uint256 newTokenId = tokenIds.current();

      _safeMint(msg.sender, newTokenId);
      _setTokenURI(newTokenId, profilePic);

      artists[msg.sender] = Artist(
         msg.sender,
         name,
         newTokenId,
         true,
         new address[](0)
      );
      artistsArray.push(msg.sender);
   }
}