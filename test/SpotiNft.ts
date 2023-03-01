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
      beforeEach(async () => {
         const { owner, spotiNft, account1, account2 } = await loadFixture(
            deploySpotiNftFixture
         )

         spotiNft.connect(owner).register(
            "owner_profile",
            "owner_name"
         )
         spotiNft.connect(account1).register(
            "account1_profile",
            "account1_name"
         )
         spotiNft.connect(account2).register(
            "account2_profile",
            "account2_name"
         )
      })

      it.only("registers the users", async () => {
         const { owner, spotiNft, account1, account2 } = await loadFixture(
            deploySpotiNftFixture
         )
         console.log(await spotiNft.getAllArtists())
      })
   })
})