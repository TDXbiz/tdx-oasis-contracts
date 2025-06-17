import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@oasisprotocol/sapphire-hardhat";
import "dotenv/config"

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
};

export default config;
