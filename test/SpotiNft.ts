import { ethers } from "hardhat"
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"

describe.only("SpotiNft", () => {
   const deploySpotiNftFixture = async () => {
      const [owner, otherAccount] = await ethers.getSigners()

      const SpotiNft = await ethers.getContractFactory("SpotiNftMarketplace")
      const spotiNft = await SpotiNft.deploy()

      return {
         owner,
         otherAccount,
         // spotiNft
      }
   }
   describe("Deployment", function () {
      it("Should set the right unlockTime", async function () {
         const { owner } = await loadFixture(
            deploySpotiNftFixture
         )

         // console.log(owner)
         // console.log(spotiNft)
      })
   })
})