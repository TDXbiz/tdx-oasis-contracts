import { ethers, upgrades } from "hardhat";

const main = async () => {
    const proxy = "0x487C47491D2224c02324576A83d864FAD7396591"; // proxy address

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
