// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./Roles.sol";

contract InvestorProfile is Roles {
    enum InvestmentCategory {
        VC_SALE,
        SIGNALS,
        OTC_SALE,
        NODE_SALE,
        PUBLIC_SALE,
        YIELD_AGGREGATOR
    }

    enum Tier {
        SILVER,
        GOLD,
        PLATINUM
    }

    struct Investment {
        uint investmentAmount;
        uint assetAmount;
    }

    struct InvestorView {
        bytes32 investorId;
        Tier launchpadLoyalist;
        Tier strategicSuit;
        Tier nodeMaximalist;
        Tier realworldRaider;
        Tier otcOperator;
        Tier signalSeeker;
    }

    struct Investor {
        bytes32 investorId;
        uint otcInvestment;
        uint totalInvestment;
        uint vcSaleInvestment;
        uint signalsInvestment;
        uint nodeSaleInvestment;
        uint launchpadInvestment;
        uint publicSaleInvestment;
        uint yieldAggregatorInvestment;
        // investment id => amount
        mapping(bytes32 => Investment) investments;
    }

    struct InvestmentAsset {
        bytes32 id;
        string name;
        uint chainId;
        bool isActive;
        address investmentToken;
        InvestmentCategory category;
        address assetToken;
    }

    event InvestorAssetAdded(bytes32 id, string name);
    event SetInvestorAsset(bytes32 id, bool isActive);
    event UserInvested(
        bytes32 indexed investorId,
        bytes32 indexed assetId,
        uint tokenAmount,
        uint assetAmount
    );
    event UserWithdraw(
        bytes32 indexed investorId,
        bytes32 indexed assetId,
        uint assetAmount
    );

    mapping(bytes32 => Investor) private investors;
    mapping(bytes32 => InvestmentAsset) public investmentAssets;

    function addInvestmentOption(
        bytes32 id,
        string memory name,
        uint chainId,
        address investmentToken,
        address assetToken,
        InvestmentCategory category
    ) external onlyOwner {
        InvestmentAsset memory a = investmentAssets[id];
        require(a.investmentToken == address(0), "Id already taken");
        investmentAssets[id] = InvestmentAsset({
            id: id,
            name: name,
            chainId: chainId,
            investmentToken: investmentToken,
            assetToken: assetToken,
            isActive: true,
            category: category
        });

        emit InvestorAssetAdded(id, name);
    }

    function setInvestmentOption(bytes32 id, bool enable) external onlyOwner {
        InvestmentAsset memory a = investmentAssets[id];
        require(a.investmentToken != address(0), "Invalid id");
        investmentAssets[id].isActive = enable;
        emit SetInvestorAsset(id, enable);
    }

    function addUserInvestment(
        bytes32 investorId,
        bytes32 assetId,
        uint tokenAmount,
        uint assetAmount
    ) external onlyAdminOrOwner {
        InvestmentAsset memory asset = investmentAssets[assetId];
        require(asset.investmentToken != address(0), "Invalid asset id");
        Investor storage investor = investors[investorId];
        investor.investments[assetId].investmentAmount += tokenAmount;
        investor.investments[assetId].assetAmount += assetAmount;

        if (asset.category == InvestmentCategory.NODE_SALE) {
            investor.nodeSaleInvestment += tokenAmount;
        } else if (asset.category == InvestmentCategory.VC_SALE) {
            investor.vcSaleInvestment += tokenAmount;
        } else if (asset.category == InvestmentCategory.PUBLIC_SALE) {
            investor.publicSaleInvestment += tokenAmount;
        } else if (asset.category == InvestmentCategory.OTC_SALE) {
            investor.otcInvestment += tokenAmount;
        } else if (asset.category == InvestmentCategory.SIGNALS) {
            investor.signalsInvestment += tokenAmount;
        } else if (asset.category == InvestmentCategory.YIELD_AGGREGATOR) {
            investor.yieldAggregatorInvestment += tokenAmount;
        }

        investor.totalInvestment += tokenAmount;

        emit UserInvested(investorId, assetId, tokenAmount, assetAmount);
    }

    function getInvestor(
        bytes32 investorId
    ) external view returns (InvestorView memory iview) {
        Investor storage investor = investors[investorId];
        iview.investorId = investor.investorId;

        uint uints = 10 ** 6;

        // if (investor.signalsInvestment > 2_000 * uints) {
        iview.signalSeeker = Tier.SILVER;
        // }

        if (investor.otcInvestment >= 10_000 * uints) {
            iview.otcOperator = Tier.PLATINUM;
        } else if (investor.otcInvestment >= 1_000 * uints) {
            iview.otcOperator = Tier.GOLD;
        } else {
            iview.otcOperator = Tier.SILVER;
        }

        if (investor.yieldAggregatorInvestment >= 10_000 * uints) {
            iview.realworldRaider = Tier.PLATINUM;
        } else if (investor.yieldAggregatorInvestment >= 1_000 * uints) {
            iview.realworldRaider = Tier.GOLD;
        } else {
            iview.realworldRaider = Tier.SILVER;
        }

        if (investor.nodeSaleInvestment >= 10_000 * uints) {
            iview.nodeMaximalist = Tier.PLATINUM;
        } else if (investor.nodeSaleInvestment >= 1_000 * uints) {
            iview.nodeMaximalist = Tier.GOLD;
        } else {
            iview.nodeMaximalist = Tier.SILVER;
        }

        if (investor.vcSaleInvestment >= 25_000 * uints) {
            iview.strategicSuit = Tier.PLATINUM;
        } else if (investor.vcSaleInvestment >= 5_000 * uints) {
            iview.strategicSuit = Tier.GOLD;
        } else {
            iview.strategicSuit = Tier.SILVER;
        }

        if (investor.publicSaleInvestment >= 10_000 * uints) {
            iview.launchpadLoyalist = Tier.PLATINUM;
        } else if (investor.publicSaleInvestment >= 1_000 * uints) {
            iview.launchpadLoyalist = Tier.GOLD;
        } else {
            iview.launchpadLoyalist = Tier.SILVER;
        }
    }

    function withdrawUserInvestment(
        bytes32 investorId,
        bytes32 assetId,
        uint assetAmount
    ) external onlyAdminOrOwner {
        InvestmentAsset memory asset = investmentAssets[assetId];
        require(asset.investmentToken != address(0), "Invalid asset id");
        Investor storage i = investors[investorId];

        require(
            i.investments[assetId].assetAmount >= assetAmount,
            "Invalid withdraw amount"
        );
        i.investments[assetId].assetAmount -= assetAmount;

        emit UserWithdraw(investorId, assetId, assetAmount);
    }
}
