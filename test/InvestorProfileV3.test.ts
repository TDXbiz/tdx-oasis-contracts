import { expect } from "chai";
import { setUpTestV3 } from "./setUp";
import { ethers, } from "hardhat";
import { time } from "@nomicfoundation/hardhat-network-helpers";

describe("InvestorProfileV3 ", () => {
    it(".. should deploy the contracts perfectly", async () => {
        const { investorProfile, deployer } = await setUpTestV3();

        const role = await investorProfile.DEFAULT_ADMIN_ROLE();

        expect(await investorProfile.hasRole(role, deployer)).to.be.true;

        expect(await investorProfile.UNITS()).to.equal(10 ** 6);
    });

    it(".. should be able to add an investor", async () => {
        const { investorProfile, deployer, Tier, InvestorCategory } =
            await setUpTestV3();

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
            kycId: "ksjdbfkjsdbfk",
        };

        await expect(
            investorProfile[
                "addInvestor((bytes32,uint8,string,string,string,string,string,string))"
            ](params)
        ).to.emit(investorProfile, "InvestorAdded");

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
            await setUpTestV3();

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
            kycId: "ksjdbfkjsdbfk",
        };

        expect(
            await investorProfile[
                "addInvestor((bytes32,uint8,string,string,string,string,string,string))"
            ](params)
        ).to.emit(investorProfile, "InvestorAdded");

        await expect(
            investorProfile[
                "addInvestor((bytes32,uint8,string,string,string,string,string,string))"
            ](params)
        ).to.be.revertedWith("invalid investor id");
    });

    it(".. only owner and admin should be able to add investors", async () => {
        const { investorProfile, deployer, alice, InvestorCategory } =
            await setUpTestV3();

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
            kycId: "ksjdbfkjsdbfk",
        };

        const signer = await ethers.getSigner(alice);

        await expect(
            investorProfile
                .connect(signer)
                [
                    "addInvestor((bytes32,uint8,string,string,string,string,string,string))"
                ](params)
        ).to.be.reverted;

        const role = await investorProfile.DATA_MANAGER();
        await investorProfile.grantRole(role, alice);

        await expect(
            investorProfile
                .connect(signer)
                [
                    "addInvestor((bytes32,uint8,string,string,string,string,string,string))"
                ](params)
        ).to.emit(investorProfile, "InvestorAdded");
    });

    it(".. should be able to add investment asset", async () => {
        const { investorProfile, AssetCategory, alice, bob } =
            await setUpTestV3();

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

    it.only(".. should be able to add investment of user by admin", async () => {
        const {
            investorProfile,
            AssetCategory,
            alice,
            bob,
            InvestorCategory,
            domain,
            investorProfileType,
            investmentType,
        } = await setUpTestV3();

        const otcSaleId = ethers.encodeBytes32String("OTC_SALE");

        const chainId = 1n;
        const assetToken = alice;
        const investmentToken = bob;

        await investorProfile.addAssetOption(
            otcSaleId,
            otcSaleId,
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
            kycId: "ksjdbfkjsdbfk",
        };

        const tokenAmount = ethers.parseUnits("10000", 6);
        const assetAmount = 100;

        await investorProfile
            .connect(signer)
            [
                "addInvestor((bytes32,uint8,string,string,string,string,string,string))"
            ](params);

        await investorProfile.addUserInvestment(
            investorId,
            otcSaleId,
            tokenAmount,
            assetAmount
        );

        const deadline = (await time.latest()) + 30;

        const profileValue = {
            investorId: investorId,
            requester: alice,
            deadline,
        };

        let signature = await signer.signTypedData(
            domain,
            investorProfileType,
            profileValue
        );

        const profile = await investorProfile.getInvestorProfile(
            investorId,
            alice,
            deadline,
            signature
        );
        expect(profile.discord).equal(DISCORD);

        const investmentValues = {
            investorId,
            assetId: otcSaleId,
            requester: alice,
            deadline,
        };

        signature = await signer.signTypedData(
            domain,
            investmentType,
            investmentValues
        );

        const investmentDetails = await investorProfile.getInvestmentDetails(
            params.investorId,
            otcSaleId,
            alice,
            deadline,
            signature
        );
        expect(investmentDetails.assetAmount).to.equal(assetAmount);
        expect(investmentDetails.investmentAmount).to.equal(tokenAmount);
    });
});
