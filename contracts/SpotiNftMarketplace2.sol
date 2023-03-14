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
}