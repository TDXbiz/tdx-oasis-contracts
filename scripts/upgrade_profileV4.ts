import { ethers, upgrades } from "hardhat";

const main = async () => {
    const proxy = "0x487C47491D2224c02324576A83d864FAD7396591"; // proxy address - testnet

    const factory = await ethers.getContractFactory("InvestorProfileV4");

    // const domain = "app.tdx.biz";

    await upgrades.validateUpgrade(proxy, factory, {
        kind: "uups",
        unsafeAllow: ["missing-initializer-call"],
    });

    const result = await upgrades.upgradeProxy(proxy, factory, {
        kind: "uups",
        redeployImplementation: "onchange",
        // since v4 is deployed multiple times for minor changes, we skip the initializer call on testnet
        // call: {
        //     fn: "initializeV4",
        //     args: [domain],
        // },
        unsafeAllow: ["missing-initializer-call"],
    });

    console.log("Upgrade transaction sent:", result.hash);
};

main().catch(console.error);
