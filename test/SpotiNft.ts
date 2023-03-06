import { ethers } from "hardhat"
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"

const EVENT_ALBUM_CREATED = "AlbumCreated"
const ALBUM_OBJECT = {
   name: "My First Album",
   symbol: "MFA",
   albumCover: "ipfscoverurl.png",
   songUris: ["ipfssonguri1.mp3", "ipfssonguri2.mp3", "ipfssonguri3.mp3"],
   songPrices: [1, 2, 3],
   albumPrice: 10
}

describe.only("SpotiNft", () => {
   const deploySpotiNftFixture = async () => {
      const [owner, account1, account2] = await ethers.getSigners()

      const SpotiNft = await ethers.getContractFactory("SpotiNftMarketplace")
      const spotiNft = await SpotiNft.deploy()

      await spotiNft.deployed()
      
      return {
         owner,
         account1,
         account2,
         spotiNft
      }
   }
   describe("Deployment", () => {
      it("Should set the right name and symbol", async () => {
         const { owner, spotiNft } = await loadFixture(
            deploySpotiNftFixture
         )
         
         expect(await spotiNft.owner()).equal(owner.address)
         expect(await spotiNft.symbol()).equal("SNFT")
      })
   })

   describe("Registration", () => {
      const registerSpotiNftFixture = async () =>{
         const [owner, account1, account2] = await ethers.getSigners()

         const SpotiNft = await ethers.getContractFactory("SpotiNftMarketplace")
         const spotiNft = await SpotiNft.deploy()

         await spotiNft.deployed()

         await spotiNft.register(
            "owner_profile",
            "owner_name"
         )
         await spotiNft.connect(account1).register(
            "account1_profile",
            "account1_name"
         )
         await spotiNft.connect(account2).register(
            "account2_profile",
            "account2_name"
         )
         return {
            owner,
            account1,
            account2,
            spotiNft
         }
      }

      it("registers the users", async () => {
         const { owner, account1, account2, spotiNft } = await loadFixture(
            registerSpotiNftFixture
         )
         const artists = await spotiNft.getAllArtists() 
         
         expect(artists.length).equal(3)
         expect(artists[0].artist_address).equal(owner.address)
         expect(artists[1].artist_address).equal(account1.address)
         expect(artists[2].artist_address).equal(account2.address)
      })
   })

   describe.only("Albums", () => {
      const registerSpotiNftFixture = async () =>{
         const [owner, account1, account2] = await ethers.getSigners()

         const SpotiNft = await ethers.getContractFactory("SpotiNftMarketplace")
         const spotiNft = await SpotiNft.deploy()

         await spotiNft.deployed()

         await spotiNft.register(
            "owner_profile",
            "owner_name"
         )
         await spotiNft.connect(account1).register(
            "account1_profile",
            "account1_name"
         )
         return {
            owner,
            account1,
            account2,
            spotiNft
         }
      }

      const useCreateAlbum = async () => {
         const { spotiNft } = await loadFixture(registerSpotiNftFixture)
         const transaction = await spotiNft.createAlbum(
            ALBUM_OBJECT.name,
            ALBUM_OBJECT.symbol,
            ALBUM_OBJECT.albumCover,
            ALBUM_OBJECT.songUris,
            ALBUM_OBJECT.songPrices,
            ALBUM_OBJECT.albumPrice
         )
         const receipt = await transaction.wait()
         const albumAddress = receipt.events?.find(x => x.event === EVENT_ALBUM_CREATED)?.args![0]

         return {
            albumAddress,
            receipt,
            spotiNft,
            transaction
         }
      }

      it("Emits event when new album is created", async () => {
         const { albumAddress, spotiNft, transaction } = await useCreateAlbum()
         
         await expect(transaction)
            .to.emit(spotiNft, EVENT_ALBUM_CREATED)
            .withArgs(albumAddress, ALBUM_OBJECT.name)
      })

      it("registers album correctly", async () => {
         const { albumAddress } = await useCreateAlbum()
         const spotiAlbum = await ethers.getContractAt("SpotiAlbum", albumAddress)
         expect(await spotiAlbum.getName()).equal(ALBUM_OBJECT.name)
         expect(await spotiAlbum.getPrice()).equal(ALBUM_OBJECT.albumPrice)
      })
   }) 
})