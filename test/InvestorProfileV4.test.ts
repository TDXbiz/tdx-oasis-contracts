import { expect } from "chai";
import { setUpTestV4 } from "./setUp";
import { ethers } from "hardhat";
import { SiweMessage } from "siwe";

describe.only("InvestorProfileV4 - Siwe Auth", () => {
    it(".. should deploy the contracts perfectly", async () => {
        const { investorProfile, deployer } = await setUpTestV4();
        const role = await investorProfile.DEFAULT_ADMIN_ROLE();

        expect(await investorProfile.hasRole(role, deployer)).to.be.true;
        expect(await investorProfile.UNITS()).to.equal(10 ** 6);
    });

    it(".. should be able to add an investor", async () => {
        const { investorProfile, deployer, Tier, InvestorCategory } =
            await setUpTestV4();

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
            await setUpTestV4();

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

    it(".. should be able to add investment asset", async () => {
        const { investorProfile, AssetCategory, alice, bob } =
            await setUpTestV4();

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

    it.only(".. should be able to call getProfile using Siwe auth", async () => {
        const { investorProfile, deployer, InvestorCategory, domain, chainId } =
            await setUpTestV4();
        const signer = await ethers.getNamedSigner("deployer");

        const siweMsg = new SiweMessage({
            domain,
            address: signer.address,
            uri: `http://${domain}`,
            version: "1",
            chainId,
        }).toMessage();

        const sig = ethers.Signature.from(await signer.signMessage(siweMsg));
        const token = await investorProfile.login(siweMsg, sig);

        const investorId = ethers.encodeBytes32String("USER_ID_2");
        const TWITTER = "https://x.com/userId2";
        const YOUTUBE = "https://youtube.com/@userId2";
        const DISCORD = "https://discord/com/userId2";
        const TELEGRAM = "https://t.me/userId2";
        const params = {
            investorId,
            category: InvestorCategory.CONSERVATIVE,
            wallet: deployer,
            twitter: TWITTER,
            discord: DISCORD,
            youtube: YOUTUBE,
            telegram: TELEGRAM,
            kycId: "ksjdbfkjsdbfk2",
        };

        console.log("Siwe Msg: ", params);

        await expect(
            investorProfile[
                "addInvestor((bytes32,uint8,string,string,string,string,string,string))"
            ](params)
        ).to.emit(investorProfile, "InvestorAdded");

        const profile = await investorProfile.getInvestorProfile(
            investorId,
            token
        );

        console.log("Profile:", profile);

        expect(profile.investorId).to.equal(investorId);
        expect(profile.category).to.equal(InvestorCategory.CONSERVATIVE);
        expect(profile.wallet).to.equal(deployer);
    });
});
