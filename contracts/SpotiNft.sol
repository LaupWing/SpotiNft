// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract SpotiNftMarketplace {
   address payable public owner;

   constructor() payable {
      owner = payable(msg.sender);
   }
}


contract SpotiNftAlbum is ERC721URIStorage {
   constructor (
      string memory albumName, 
      string memory albumSymbol
   ) ERC721(
      albumName,
      albumSymbol
   ) {
      
   }
}