import { deployments, ethers, getNamedAccounts, upgrades } from "hardhat";
import { InvestorProfile__factory } from "../typechain-types";
import { InvestorProfileV3 } from "../typechain-types/contracts/InvestorProfileV3";

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
    const profileFactory = await ethers.getContractFactory("InvestorProfileV3");

    const name = "InvestorProfileV3";
    const version = "3";
    const profile = (await upgrades.upgradeProxy(
        obj.investorProfile,
        profileFactory,
        {
            kind: "uups",
            call: {
                fn: "initializeV3",
                args: [name, version],
            },
        }
    )) as unknown as InvestorProfileV3;

    const domain = {
        name,
        version,
        chainId: 31337,
        verifyingContract: profile.target as string,
    };

    const investmentType = {
        InvestmentRequest: [
            { name: "investorId", type: "bytes32" },
            { name: "assetId", type: "bytes32" },
            { name: "requester", type: "address" },
            { name: "deadline", type: "uint256" },
        ],
    };

    const investorProfileType = {
        InvestorProfileRequest: [
            { name: "investorId", type: "bytes32" },
            { name: "requester", type: "address" },
            { name: "deadline", type: "uint256" },
        ],
    };

    return {
        ...obj,
        investorProfile: profile,
        investmentType,
        investorProfileType,
        domain,
    };
});
