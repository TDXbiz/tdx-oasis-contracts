import { HardhatUserConfig } from "hardhat/config";
import "@oasisprotocol/sapphire-hardhat";
import "dotenv/config";

import "@openzeppelin/hardhat-upgrades";

import "hardhat-deploy";
import "hardhat-deploy-ethers";

import "@nomicfoundation/hardhat-chai-matchers";
import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-verify";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";

const accounts = [process.env.PRIVATE_KEY as string];

const config: HardhatUserConfig = {
    solidity: {
        compilers: [
          {
            version: "0.8.29",
            settings: { optimizer: { enabled: true, runs: 200 } }
          },
          {
            version: "0.8.22",
            settings: { optimizer: { enabled: true, runs: 200 } }
          }
        ],
        overrides: {
          "contracts/InvestorProfile.sol":       { version: "0.8.22" },
          "contracts/InvestorProfileParams.sol": { version: "0.8.22" }
        }
    },

    networks: {
        sapphire: {
            url: "https://sapphire.oasis.io",
            chainId: 23294,
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

    etherscan: {
        enabled: false,
    },

    sourcify: {
        enabled: true,
    },
};

export default config;
