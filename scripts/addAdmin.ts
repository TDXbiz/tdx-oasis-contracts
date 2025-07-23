import { InvestorProfile__factory } from "../typechain-types";

const main = async () => {
    const manager = "0x8BA52eCB5573ACF5265184D80450272bd265604E";

    const contractAddress = "";

    const profile = InvestorProfile__factory.connect(contractAddress);

    const role = await profile.DATA_MANAGER();

    const tx = await profile.grantRole(role, manager);
    await tx.wait(1);

    return tx.hash;
};

main().then(console.log);
