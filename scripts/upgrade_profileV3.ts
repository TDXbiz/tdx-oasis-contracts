import { ethers, upgrades } from "hardhat";

const main = async () => {
    const proxy = "0x4c61b87246Be97E8FebFF7d0d7e5a3F9AEd1abE8"; // proxy address - mainnet

    const factory = await ethers.getContractFactory("InvestorProfileV3");

    const name = "InvestorProfileV3";
    const version = "3";
    const result = await upgrades.upgradeProxy(proxy, factory, {
        kind: "uups",
        redeployImplementation: "onchange",
        call: {
            fn: "initializeV3",
            args: [name, version],
        },
    });

    console.log("Upgrade transaction sent:", result.target);
};

main().catch(console.error);
