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
   address payable public owner;

   constructor (
      string memory albumName, 
      string memory albumSymbol,
      address _owner
   ) ERC721(
      albumName,
      albumSymbol
   ) {
      owner = payable(_owner);
   }
}