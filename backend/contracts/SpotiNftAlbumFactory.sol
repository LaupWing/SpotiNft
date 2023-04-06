// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./SpotiNftAlbum.sol";

contract SpotiNftAlbumFactory {
   SpotiNftAlbum[] public SpotiNftAlbumArray;

   function createAlbum(
      string memory _name,
      string memory _cover_uri,
      uint256 _album_price,
      string[] memory _song_uris,
      string[] memory _song_names,
      uint256 _song_price
   ) public {
      SpotiNftAlbum createdAlbum = new SpotiNftAlbum(
         _name,
         _cover_uri,
         _album_price,
         _song_uris,
         _song_names,
         _song_price,
         msg.sender
      );

      SpotiNftAlbumArray.push(createdAlbum);
      return address(createdAlbum);
   }
}