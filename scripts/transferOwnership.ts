import { ethers } from "hardhat";
import { InvestorProfile__factory } from "../typechain-types";

const main = async () => {
    // test net address
    const newOwner = "0x8BA52eCB5573ACF5265184D80450272bd265604E";
    const contractAddress = "0x487C47491D2224c02324576A83d864FAD7396591";
    const [signer, _] = await ethers.getSigners();

    const profile = InvestorProfile__factory.connect(contractAddress, signer);

    const role = await profile.DATA_MANAGER();

    console.log("Role to transfer:", role);

    const tx = await profile.grantRole(role, newOwner);
    await tx.wait(1);

    return tx.hash;
};

main().then(console.log);
