import { ethers } from "hardhat";

const main = async () => {
    const manager = "0xDFD2168901BD0825d48d44e10A8a387A035aaf2F";

    const contractAddress = "0x4c61b87246Be97E8FebFF7d0d7e5a3F9AEd1abE8";

    const profile = await ethers.getContractAt(
        "InvestorProfileV3",
        contractAddress
    );

    const role = await profile.DATA_MANAGER();

    const tx = await profile.hasRole(role, manager);

    return tx;
};

main().then(console.log);
