import { ethers } from "hardhat";
import { InvestorProfile } from "../typechain-types";

const main = async () => {
    const contract = (await ethers.getContract(
        "InvestorProfile"
    )) as InvestorProfile;

    const owner = "0x8BA52eCB5573ACF5265184D80450272bd265604E";

    const tx = await contract.transferOwnership(owner);
    await tx.wait(1);

    return tx.hash;
};

main().then(console.log);
