import { HardhatUserConfig } from "hardhat/config"
import "@nomicfoundation/hardhat-toolbox"
import "hardhat-contract-sizer"

const config: HardhatUserConfig = {
   solidity: {
      version: "0.8.17",
      settings: {
         optimizer: {
           enabled: true,
           runs: 5000
         },
      }
   },
   contractSizer: {
      alphaSort: true,
      disambiguatePaths: false,
      runOnCompile: true,
      strict: true,
   },
   networks:{
      hardhat:{
         allowUnlimitedContractSize: true
      }
   }
   
}

export default config
