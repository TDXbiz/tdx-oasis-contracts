import { ethers } from "hardhat";

const main = async () => {
    const proxy = "0x487C47491D2224c02324576A83d864FAD7396591"; // proxy address

    // will work regardless of the version .. since upgradeToAndCall funciton abi is same
    const proxyContract = await ethers.getContractAt("InvestorProfile", proxy);

    const factory = await ethers.getContractFactory("InvestorProfileV3");

    const newImplementation = await factory.deploy();
    await newImplementation.waitForDeployment();

    console.log("New implementation deployed at: ", newImplementation.target);

    const tx = await proxyContract.upgradeToAndCall(
        newImplementation.target,
        "0x"
    );

    await tx.wait(1);
    console.log("Upgrade transaction sent:", tx.hash);
};

main().catch(console.error);
