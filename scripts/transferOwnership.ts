import { ethers } from "hardhat";
import { InvestorProfile__factory } from "../typechain-types";

const main = async () => {
    const manager = "0x814e444258266f27CeD3a066d7DE3cd972e9a4Ee";
    const contractAddress = "0x487C47491D2224c02324576A83d864FAD7396591";
    const [signer, _] = await ethers.getSigners();

    const profile = InvestorProfile__factory.connect(contractAddress, signer);

    const role = await profile.DEFAULT_ADMIN_ROLE();

    const tx = await profile.grantRole(role, manager);
    await tx.wait(1);

    return tx.hash;
};

main().then(console.log);
