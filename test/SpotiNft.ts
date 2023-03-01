import { ethers } from "hardhat"
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import { SpotiNftMarketplace } from "../typechain-types"

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
      let _spotiNft:SpotiNftMarketplace
      
      beforeEach(async () => {
         const { owner, spotiNft, account1, account2 } = await loadFixture(
            deploySpotiNftFixture
         )

         await spotiNft.connect(owner).register(
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
         _spotiNft = spotiNft
      })

      it("registers the users", async () => {
         console.log(await _spotiNft!.getAllArtists())
      })
   })
})