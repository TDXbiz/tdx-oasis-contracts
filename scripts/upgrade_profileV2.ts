import { ethers, upgrades } from "hardhat";

const main = async () => {
    const proxy = "0x4c61b87246Be97E8FebFF7d0d7e5a3F9AEd1abE8"; // proxy address
    const profileFactory = await ethers.getContractFactory("InvestorProfileV2");

    const proxyContract = await ethers.getContractAt("InvestorProfile", proxy);
    const newImplAddress = "0x36589124650Ca0457b709d033f13ce7E884d6BC6";
    // console.log("Upgrading InvestorProfile to V2...", newImplAddress.address);

    const tx = await proxyContract.upgradeToAndCall(newImplAddress, "0x");

    // const tx = await upgrades.upgradeProxy(proxy, profileFactory);

    console.log("Upgrade transaction sent:", tx.hash);

    return tx.hash;
};

main().then(console.log);
