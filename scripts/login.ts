import { ethers, network } from "hardhat";
import { SiweMessage } from "siwe";
import { InvestorProfileV4 } from "../typechain-types";

const getInvestorProfile = async function (investorId: string) {
    const [signer] = await ethers.getSigners();

    const profileContract = (await ethers.getContractAt(
        "InvestorProfileV4",
        "0x4c61b87246Be97E8FebFF7d0d7e5a3F9AEd1abE8",
        signer
    )) as unknown as InvestorProfileV4;
    try {
        investorId = ethers.encodeBytes32String(investorId.toString());

        const siweMessage = new SiweMessage({
            chainId: network.config.chainId,
            uri: "http://app.tdx.biz",
            domain: "app.tdx.biz",
            version: "1",
            address: signer.address,
        });

        const prepared = siweMessage.prepareMessage();
        const sig = ethers.Signature.from(await signer.signMessage(prepared));
        const token = await profileContract.login(prepared, sig);

        let investor = await profileContract.getInvestorProfile(
            investorId,
            token
        );

        return { success: true, data: investor };
    } catch (err) {
        console.error(err, "------error getting investor profile data");
        return { success: false, error: err };
    }
};

// mainnet example user id
getInvestorProfile("625d5d0d4889155199288ccf")
    .then(console.log)
    .catch(console.error);
