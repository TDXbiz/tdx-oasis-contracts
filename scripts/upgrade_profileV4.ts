import { ethers, upgrades } from "hardhat";

const main = async () => {
    const proxy = "0x487C47491D2224c02324576A83d864FAD7396591"; // proxy address - testnet

    const factory = await ethers.getContractFactory("InvestorProfileV4");

    const domain = "app.tdx.biz";

    const cont = await ethers.getContractAt("InvestorProfileV3", proxy);
    console.log(
        "Has role: ",
        await cont.hasRole(
            await cont.DEFAULT_ADMIN_ROLE(),
            "0x55ecEb75176fA99d6108a4a1f83766701556867B"
        )
    );

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

    console.log("Upgrade transaction sent:", result);
};

main().catch(console.error);
