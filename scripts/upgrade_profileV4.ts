import { ethers, upgrades } from "hardhat";

const main = async () => {
    const proxy = "0x4c61b87246Be97E8FebFF7d0d7e5a3F9AEd1abE8"; // proxy address - mainnet

    const factory = await ethers.getContractFactory("InvestorProfileV4");

    const domain = "app.tdx.biz";

    await upgrades.validateUpgrade(proxy, factory, {
        kind: "uups",
        unsafeAllow: ["missing-initializer-call"],
    });

    const result = await upgrades.upgradeProxy(proxy, factory, {
        kind: "uups",
        redeployImplementation: "onchange",
        call: {
            fn: "initializeV4",
            args: [domain],
        },
        unsafeAllow: ["missing-initializer-call"],
    });

    console.log("Upgrade transaction sent:", result.hash);
};

main().catch(console.error);
