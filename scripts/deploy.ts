// @ts-ignore
import {ethers} from 'hardhat';
import * as dotenv from 'dotenv';
dotenv.config()

import {chainWaveTokenAddress} from '../constants/index'

async function main() {
    const exchangeContract = await ethers.getContractFactory("Exchange")

    const deployedExchangeContract = await exchangeContract.deploy(chainWaveTokenAddress);
    await deployedExchangeContract.deployed();

    console.log("Exchange Contract Address: ", deployedExchangeContract.address);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })