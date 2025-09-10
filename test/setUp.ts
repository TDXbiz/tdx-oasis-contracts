import { deployments, ethers, getNamedAccounts, upgrades } from "hardhat";
import { InvestorProfile__factory } from "../typechain-types";

export const setUpTest = deployments.createFixture(async () => {
    await deployments.fixture();

    const { deployer, alice, bob } = await getNamedAccounts();
    const profileFactory = (await ethers.getContractFactory(
        "InvestorProfile"
    )) as unknown as InvestorProfile__factory;

    const profile = await upgrades.deployProxy(profileFactory, [deployer], {
        initializer: "initialize",
        kind: "uups",
    });

    const investorProfile = await profile.waitForDeployment();

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

export const setUpTestV3 = deployments.createFixture(async () => {
    const obj = await setUpTest();
    const profileFactory = (await ethers.getContractFactory(
        "InvestorProfile"
    )) as unknown as InvestorProfile__factory;

    const profile = await upgrades.deployProxy(profileFactory, [obj.deployer], {
        initializer: "initialize",
        kind: "uups",
    });

    const investorProfile = await profile.waitForDeployment();

    return {
        ...obj,
        investorProfile,
    };
});
