// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract SpotiNftMarketplace {
   address payable public owner;

   constructor() {
      owner = payable(msg.sender);
   }
}


contract SpotiAlbum  is ERC721URIStorage{
   address payable public owner;
   string public albumCover;
   mapping(uint256 => string) public songs;

   using Counters for Counters.Counter;

   Counters.Counter private tokenIds;
   Counters.Counter private itemsSold;

   struct SpotiSong {
      uint256 tokenId;
      
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
      owner = payable(msg.sender);
      albumCover = _albumCover;
      setSongs(_songs);
   }

   function createSong() private {
      
   }

   function setSongs(string[] memory _songs) internal {
      for(uint256 i = 0; i < _songs.length; i++){
         songs[i] = _songs[i];
      }
   }
}