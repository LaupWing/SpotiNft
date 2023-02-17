// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract SpotiNftMarketplace {
   address payable public owner;
   SpotiAlbum[] public albums;
   
   struct Artist {
      address artist_address;
      string name;
   }

   constructor() {
      owner = payable(msg.sender);
   }
}


contract SpotiAlbum  is ERC721URIStorage{
   address payable public owner;
   string public artist;
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

   constructor(
      string memory _name, 
      string memory _symbol,
      string memory _albumCover,
      string[] memory _songs,
      string memory _artist
   ) ERC721(
      _name,
      _symbol
   ) {
      owner = payable(msg.sender);
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

   function addSong(string memory uri) private {
      uint256 id = songIds.current();
      songs[id] = SpotiSong(
         id,
         0,
         uri,
         block.timestamp
      );
      totalSongs.increment();
   }

   function setSongs(string[] memory _songs) internal {
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