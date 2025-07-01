import { HardhatUserConfig } from "hardhat/config";
import "@oasisprotocol/sapphire-hardhat";
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config";

import "hardhat-deploy";
import "hardhat-deploy-ethers"

import "@nomicfoundation/hardhat-chai-matchers";
import "@nomicfoundation/hardhat-ethers";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";


const accounts = [process.env.PRIVATE_KEY as string];

const config: HardhatUserConfig = {
    solidity: "0.8.20",

    networks: {
        sapphire: {
            url: "https://sapphire.oasis.io",
            chainId: 0x5afe,
            accounts,
        },
        "sapphire-testnet": {
            url: "https://testnet.sapphire.oasis.io",
            accounts,
            chainId: 0x5aff,
        },
    },

    namedAccounts: {
        deployer: 0,
        alice: 1,
        bob: 2,
    },

    gasReporter: {
        enabled: true,
    },
};

export default config;
