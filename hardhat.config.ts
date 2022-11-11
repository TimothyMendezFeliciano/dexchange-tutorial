import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from 'dotenv'
dotenv.config()

const ALCHEMY_URL = process.env.ALCHEMY_HTTP_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY as string

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: ALCHEMY_URL,
      accounts: [PRIVATE_KEY]
    }
  }
};

export default config;
