import { ethers } from "hardhat";
import { InvestorProfile__factory } from "../typechain-types";

const main = async () => {
    // test net address
    // const newOwner = "0x8BA52eCB5573ACF5265184D80450272bd265604E";
    // const contractAddress = "0x487C47491D2224c02324576A83d864FAD7396591";
    // const [signer, _] = await ethers.getSigners();
    // const profile = InvestorProfile__factory.connect(contractAddress, signer);

    // const role = await profile.DEFAULT_ADMIN_ROLE();
    // console.log("Role to transfer:", role);
    // // grant role
    // let tx = await profile.grantRole(role, newOwner);
    // await tx.wait(1);
    // // revoke super admin role
    // tx = await profile.revokeRole(role, signer.address);
    // await tx.wait(1);

    const proxy = "0x487C47491D2224c02324576A83d864FAD7396591"; // proxy address

    // will work regardless of the version .. since upgradeToAndCall funciton abi is same
    const proxyContract = await ethers.getContractAt("InvestorProfile", proxy);

    return await proxyContract.owner();
};

main().then(console.log);
