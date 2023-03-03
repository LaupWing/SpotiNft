import { ethers } from "hardhat"
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"

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

      it("throws error when you create album when you are not registered", async () => {

      })
   }) 
})