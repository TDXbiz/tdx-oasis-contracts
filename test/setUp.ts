import { deployments, ethers, getNamedAccounts } from "hardhat";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { InvestorProfile } from "../typechain-types";

export const setUpTest = deployments.createFixture(async () => {
    await deployments.fixture();

    const { deployer, alice, bob } = await getNamedAccounts();
    const investorProfile = (await ethers.getContract(
        "InvestorProfile"
    )) as InvestorProfile;

    enum InvestorCategory {
        CONSERVATIVE,
        BALANCED,
        AGGRESIVE,
        HIGHRISK,
    }

    enum Tier {
        SILVER,
        GOLD,
        PLATINUM,
    }

    enum AssetCategory {
        VC_SALE,
        SIGNALS,
        OTC_SALE,
        NODE_SALE,
        PUBLIC_SALE,
        YIELD_AGGREGATOR,
    }

    return {
        bob,
        Tier,
        alice,
        deployer,
        AssetCategory,
        investorProfile,
        InvestorCategory,
    };
});
