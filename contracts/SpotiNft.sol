// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract SpotiNftMarketplace is ERC721URIStorage {
   address payable public owner;
   using Counters for Counters.Counter;

   constructor() ERC721(
      "SpotiNft",
      "SP"
   ) {
      owner = payable(msg.sender);
   }
}