import { ethers, upgrades } from "hardhat";

const main = async () => {
    const proxy = "0x4c61b87246Be97E8FebFF7d0d7e5a3F9AEd1abE8"; // proxy address - mainnet
    const profileFactory = await ethers.getContractFactory("InvestorProfileV2");

    const res = await upgrades.forceImport(proxy, profileFactory);

    console.log("Contract imported successfully...");
};

main().catch(console.error);
