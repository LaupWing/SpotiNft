// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./SpotiNftSong.sol";

error SpotiAlbum__NotEoughEthSend();
error SpotiAlbum__OnlyOwner();

contract SpotiNftAlbum is ERC721{
   using Counters for Counters.Counter;
   Counters.Counter private tokenId;

   string private cover_uri;
   uint256 private mint_fee;
   uint256 private song_mint_fee;
   address[] private ownersList;
   address payable private owner;
   SpotiNftSong[] private song_nfts;
   mapping(address => SpotiNftSong ) address_to_song;
   mapping(address => bool) owners;

   modifier onlyOwner(address sender){
      if(sender != owner){
         revert SpotiAlbum__OnlyOwner();
      }
      _;
   }

   modifier songMintCheck(){
      if(msg.value < song_mint_fee){
         revert SpotiAlbum__NotEoughEthSend();
      }
      _;
   }

   event AlbumMinted (
      address indexed buyer,
      uint256 indexed tokenId
   );

   event SongAdded (
      address indexed song_address,
      string indexed uri,
      string indexed name
   );

   constructor(
      string memory _name,
      string memory _cover_uri,
      uint256 _mint_fee,
      string[] memory _song_uris,
      string[] memory _song_names,
      uint256 _song_price,
      address _owner
   ) ERC721(_name, "ALBUM"){
      owner = payable(_owner);
      cover_uri = _cover_uri;
      mint_fee = _mint_fee;
      song_mint_fee = _song_price;
      setSongs(_song_uris, _song_names, _owner);
   }

   function getTokenId() public view returns(uint256) {
      return tokenId.current();
   }

   function mintAlbum() public payable {
      if(msg.value < mint_fee){
         revert SpotiAlbum__NotEoughEthSend();
      }
      tokenId.increment();
      uint256 newTokenId = tokenId.current();
      _safeMint(msg.sender, newTokenId);
      if(!owners[msg.sender]){
         ownersList.push(msg.sender);
         owners[msg.sender] = true;
      }
      emit AlbumMinted(msg.sender, tokenId.current());
   }

   function getCoverUri() public view returns(string memory){
      return cover_uri;
   }

   function getOwners() public view returns(address[] memory){
      return ownersList;
   }

   function getOwner() public view returns(address){
      return owner;
   }

   function getName() public view returns(string memory){
      return name();
   }

   function getSongs() public view returns(SpotiNftSong[] memory){
      return song_nfts;
   }

   function getMintFee() public view returns(uint256){
      return mint_fee;
   }

   function getSongMintFee() public view returns(uint256){
      return song_mint_fee;
   }

   function setSongs(
      string[] memory _song_uris, 
      string[] memory _song_names,
      address _owner
   ) internal onlyOwner(_owner) {
      for(uint256 i = 0; i < _song_uris.length; i++){
         setSong(
            _song_uris[i],
            _song_names[i]
         );
      }
   }

   function setSong(string memory _song_uri, string memory _song_name) internal {
      SpotiNftSong newSpotiNFtSong = new SpotiNftSong(
         _song_uri,
         _song_name,
         song_mint_fee
      );
      address new_address = address(newSpotiNFtSong);
      address_to_song[new_address] = newSpotiNFtSong;
      song_nfts.push(newSpotiNFtSong);
   }

   function addSong(string memory _song_uri, string memory _song_name) public onlyOwner(msg.sender){
      setSong(_song_uri, _song_name);
   }

   function buySong(
      address _spotiNftAddress
   ) public payable songMintCheck{
      SpotiNftSong song = address_to_song[_spotiNftAddress];
      song.mintSong(msg.sender, msg.value);
   }

   function getSongsAddresses() public view returns(address[] memory){
      address[] memory _songs = new address[](song_nfts.length);

      for(uint256 i = 0; i < song_nfts.length; i++){
         _songs[i] = address(song_nfts[i]);
      }
      return _songs;
   }
   
   function getBalance() public view returns(uint256) {
      return address(this).balance;
   }

   function transferBalanceToOwner() public {
      require(msg.sender == owner, "Only the owner can transfer");
      uint256 balance = address(this).balance;
      owner.transfer(balance);
   }
}