import { expect } from "chai";
import { setUpTest, setUpAdmin } from "./setUp";
import { ethers } from "hardhat";

describe("InvestorProfile", () => {
    it(".. should deploy the contracts perfectly", async () => {
        const { investorProfile, deployer } = await setUpTest();

        const role = await investorProfile.DEFAULT_ADMIN_ROLE();

        expect(await investorProfile.hasRole(role, deployer)).to.be.true;

        expect(await investorProfile.UNITS()).to.equal(10 ** 6);
    });

    it(".. should be able to add an investor", async () => {
        const { investorProfile, deployer, Tier, InvestorCategory } =
            await setUpTest();

        const investorId = ethers.encodeBytes32String("USER_ID");
        const TWITTER = "https://x.com/userId";
        const YOUTUBE = "https://youtube.com/@userId";
        const DISCORD = "https://discord/com/userId";
        const TELEGRAM = "https://t.me/userId";

        const params = {
            investorId,
            category: InvestorCategory.AGGRESIVE,
            wallet: deployer,
            twitter: TWITTER,
            discord: DISCORD,
            youtube: YOUTUBE,
            telegram: TELEGRAM,
        };

        await expect(investorProfile.addInvestor(params)).to.emit(
            investorProfile,
            "InvestorAdded"
        );

        const investor = await investorProfile.getInvestor(investorId);

        expect(investor.investorId).to.equal(investorId);
        expect(investor.category).to.equal(InvestorCategory.AGGRESIVE);
        expect(investor.otcOperator).equal(Tier.SILVER);
        expect(investor.signalSeeker).equal(Tier.SILVER);
        expect(investor.strategicSuit).equal(Tier.SILVER);
        expect(investor.nodeMaximalist).equal(Tier.SILVER);
        expect(investor.realworldRaider).equal(Tier.SILVER);
        expect(investor.launchpadLoyalist).equal(Tier.SILVER);
    });

    it(".. should fail trying to add user twice", async () => {
        const { investorProfile, deployer, InvestorCategory } =
            await setUpTest();

        const investorId = ethers.encodeBytes32String("USER_ID");
        const TWITTER = "https://x.com/userId";
        const YOUTUBE = "https://youtube.com/@userId";
        const DISCORD = "https://discord/com/userId";
        const TELEGRAM = "https://t.me/userId";

        const params = {
            investorId,
            category: InvestorCategory.AGGRESIVE,
            wallet: deployer,
            twitter: TWITTER,
            discord: DISCORD,
            youtube: YOUTUBE,
            telegram: TELEGRAM,
        };

        expect(await investorProfile.addInvestor(params)).to.emit(
            investorProfile,
            "InvestorAdded"
        );

        await expect(investorProfile.addInvestor(params)).to.be.revertedWith(
            "invalid investor id"
        );
    });

    it(".. only owner and admin should be able to add investors", async () => {
        const { investorProfile, deployer, alice, InvestorCategory } =
            await setUpTest();

        const investorId = ethers.encodeBytes32String("USER_ID");
        const TWITTER = "https://x.com/userId";
        const YOUTUBE = "https://youtube.com/@userId";
        const DISCORD = "https://discord/com/userId";
        const TELEGRAM = "https://t.me/userId";

        const params = {
            investorId,
            category: InvestorCategory.AGGRESIVE,
            wallet: deployer,
            twitter: TWITTER,
            discord: DISCORD,
            youtube: YOUTUBE,
            telegram: TELEGRAM,
        };

        const signer = await ethers.getSigner(alice);

        await expect(investorProfile.connect(signer).addInvestor(params)).to.be
            .reverted;

        const role = await investorProfile.DATA_MANAGER();
        await investorProfile.grantRole(role, alice);

        await expect(
            investorProfile.connect(signer).addInvestor(params)
        ).to.emit(investorProfile, "InvestorAdded");
    });

    it(".. should be able to add investment asset", async () => {
        const { investorProfile, AssetCategory, alice, bob } =
            await setUpTest();

        const assetId = ethers.encodeBytes32String("ASSET_ID");
        const name = "Asset Option 1";
        const chainId = 1n;
        const assetToken = alice;
        const investmentToken = bob;

        expect(
            await investorProfile.addAssetOption(
                assetId,
                name,
                chainId,
                investmentToken,
                assetToken,
                AssetCategory.NODE_SALE
            )
        ).to.emit(investorProfile, "InvestorAdded");

        await expect(
            investorProfile.addAssetOption(
                assetId,
                name,
                chainId,
                investmentToken,
                assetToken,
                AssetCategory.NODE_SALE
            )
        ).to.be.revertedWith("id already taken");

        const signer = await ethers.getNamedSigner("alice");

        await expect(
            investorProfile
                .connect(signer)
                .addAssetOption(
                    assetId,
                    name,
                    chainId,
                    investmentToken,
                    assetToken,
                    AssetCategory.NODE_SALE
                )
        ).to.be.reverted;

        // only owner can add assets
    });

    it(".. should be able to add investment of user by admin", async () => {
        const {
            investorProfile,
            AssetCategory,
            alice,
            Tier,
            bob,
            InvestorCategory,
        } = await setUpTest();

        const otcSaleId = ethers.encodeBytes32String("OTC_SALE");
        const otcSaleName = "OTC Sale 1";
        const chainId = 1n;
        const assetToken = alice;
        const investmentToken = bob;

        const nodeSaleId = ethers.encodeBytes32String("NODE_SALE");
        const nodeSaleName = "Node Sale 1";

        const publicSaleId = ethers.encodeBytes32String("PUBLIC_SALE");
        const publicSaleName = "Public Sale 1";

        const signalId = ethers.encodeBytes32String("SIGNAL");
        const signalName = "Signals Pack 1";

        const vcSaleId = ethers.encodeBytes32String("VC_SALE");
        const vcSaleName = "VC Sale 1";

        const yieldAggregatorOptionId = ethers.encodeBytes32String(
            "YIELD_AGGREGATOR_OPTION"
        );
        const yieldAggregatorOptionName = "Yield Aggregator Option 1";

        await investorProfile.addAssetOption(
            nodeSaleId,
            nodeSaleName,
            chainId,
            investmentToken,
            assetToken,
            AssetCategory.NODE_SALE
        );
        await investorProfile.addAssetOption(
            publicSaleId,
            publicSaleName,
            chainId,
            investmentToken,
            assetToken,
            AssetCategory.PUBLIC_SALE
        );
        await investorProfile.addAssetOption(
            signalId,
            signalName,
            chainId,
            investmentToken,
            assetToken,
            AssetCategory.SIGNALS
        );
        await investorProfile.addAssetOption(
            vcSaleId,
            vcSaleName,
            chainId,
            investmentToken,
            assetToken,
            AssetCategory.VC_SALE
        );
        await investorProfile.addAssetOption(
            yieldAggregatorOptionId,
            yieldAggregatorOptionName,
            chainId,
            investmentToken,
            assetToken,
            AssetCategory.YIELD_AGGREGATOR
        );
        await investorProfile.addAssetOption(
            otcSaleId,
            otcSaleName,
            chainId,
            investmentToken,
            assetToken,
            AssetCategory.OTC_SALE
        );

        const signer = await ethers.getNamedSigner("alice");
        const role = await investorProfile.DATA_MANAGER();
        await investorProfile.grantRole(role, signer.address);
        const investorId = ethers.encodeBytes32String("USER_ID");
        const TWITTER = "https://x.com/userId";
        const YOUTUBE = "https://youtube.com/@userId";
        const DISCORD = "https://discord/com/userId";
        const TELEGRAM = "https://t.me/userId";

        const params = {
            investorId,
            category: InvestorCategory.AGGRESIVE,
            wallet: bob,
            twitter: TWITTER,
            discord: DISCORD,
            youtube: YOUTUBE,
            telegram: TELEGRAM,
        };

        const tokenAmount = ethers.parseUnits("10000", 6);
        const assetAmount = 100;

        await investorProfile.connect(signer).addInvestor(params);

        await expect(
            investorProfile.addUserInvestment(
                investorId,
                otcSaleId,
                tokenAmount,
                assetAmount
            )
        )
            .to.emit(investorProfile, "UserInvested")
            .withArgs(investorId, otcSaleId, tokenAmount, assetAmount);

        const investor = await investorProfile.getInvestor(investorId);

        expect(investor.otcOperator).to.equal(Tier.PLATINUM);
    });

    it(".. admin should be able to update investor details", async () => {
        const { investorProfile, deployer, alice, InvestorCategory } =
            await setUpTest();

        const investorId = ethers.encodeBytes32String("USER_ID");
        const TWITTER = "https://x.com/userId";
        const YOUTUBE = "https://youtube.com/@userId";
        const DISCORD = "https://discord/com/userId";
        const TELEGRAM = "https://t.me/userId";

        const params = {
            investorId,
            category: InvestorCategory.AGGRESIVE,
            wallet: deployer,
            twitter: TWITTER,
            discord: DISCORD,
            youtube: YOUTUBE,
            telegram: TELEGRAM,
        };

        const signer = await ethers.getSigner(alice);

        await expect(investorProfile.connect(signer).addInvestor(params)).to.be
            .reverted;

        const role = await investorProfile.DATA_MANAGER();
        await investorProfile.grantRole(role, signer.address);

        await expect(
            investorProfile.connect(signer).updateInvestorDetails(params)
        ).to.be.revertedWith("invalid investor id");

        await expect(
            investorProfile.connect(signer).addInvestor(params)
        ).to.emit(investorProfile, "InvestorAdded");

        params.category = InvestorCategory.CONSERVATIVE;

        await expect(
            investorProfile.connect(signer).updateInvestorDetails(params)
        ).to.emit(investorProfile, "InvestorUpdated");
    });

    it(".. should be able to add investor withdraw amount", async () => {
        const {
            investorProfile,
            AssetCategory,
            alice,
            Tier,
            bob,
            InvestorCategory,
        } = await setUpTest();

        const otcSaleId = ethers.encodeBytes32String("OTC_SALE");
        const otcSaleName = "OTC Sale 1";
        const chainId = 1n;
        const assetToken = alice;
        const investmentToken = bob;

        await investorProfile.addAssetOption(
            otcSaleId,
            otcSaleName,
            chainId,
            investmentToken,
            assetToken,
            AssetCategory.NODE_SALE
        );

        const signer = await ethers.getNamedSigner("alice");
        const role = await investorProfile.DATA_MANAGER();
        await investorProfile.grantRole(role, signer.address);
        const investorId = ethers.encodeBytes32String("USER_ID");

        const params = {
            investorId,
            category: InvestorCategory.AGGRESIVE,
            wallet: bob,
            twitter: "https://x.com/userId",
            discord: "https://discord/com/userId",
            youtube: "https://youtube.com/@userId",
            telegram: "https://t.me/userId",
        };

        const tokenAmount = ethers.parseUnits("10000", 6);
        const assetAmount = 100;

        await investorProfile.addInvestor(params);

        await investorProfile.addUserInvestment(
            investorId,
            otcSaleId,
            tokenAmount,
            assetAmount
        );

        await expect(
            investorProfile
                .connect(signer)
                .withdrawUserInvestment(
                    investorId,
                    otcSaleId,
                    tokenAmount + 200n
                )
        ).to.revertedWith("Invalid withdraw amount");

        await expect(
            investorProfile
                .connect(signer)
                .withdrawUserInvestment(investorId, otcSaleId, assetAmount)
        )
            .to.emit(investorProfile, "UserWithdraw")
            .withArgs(investorId, otcSaleId, assetAmount);
    });
});
