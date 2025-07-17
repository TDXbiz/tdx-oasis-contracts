// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "./InvestorProfileParams.sol";

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract InvestorProfile is
    UUPSUpgradeable,
    InvestorProfileParams,
    AccessControlUpgradeable
{
    // we only deal with stable coins
    uint public constant UNITS = 1_000_000;

    bytes32 public constant DATA_MANAGER = bytes32("DATA_MANAGER");

    function initialize(address _owner) external initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(DATA_MANAGER, _owner);
    }

    enum AssetCategory {
        VC_SALE,
        SIGNALS,
        OTC_SALE,
        NODE_SALE,
        PUBLIC_SALE,
        YIELD_AGGREGATOR
    }

    struct Investment {
        uint investmentAmount;
        uint assetAmount;
    }

    struct Asset {
        bytes32 id;
        string name;
        uint chainId;
        bool isActive;
        address assetToken;
        address investmentToken;
        AssetCategory category;
    }

    struct Investor {
        bytes32 investorId;
        InvestorCategory category;
        uint otcInvestment;
        uint totalInvestment;
        uint vcSaleInvestment;
        uint signalsInvestment;
        uint nodeSaleInvestment;
        uint launchpadInvestment;
        uint publicSaleInvestment;
        uint yieldAggregatorInvestment;
        string wallet;
        string twitter;
        string youtube;
        string discord;
        string telegram;
        // investment id => amount
        mapping(bytes32 => Investment) investments;
    }

    event InvestorAdded(bytes32 id, InvestorCategory indexed category);
    event InvestorUpdated(bytes32 id, InvestorCategory indexed category);
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
    mapping(bytes32 => Asset) public assets;

    function addInvestor(
        AddInvestorParams memory params
    ) external onlyRole(DATA_MANAGER) {
        require(
            investors[params.investorId].investorId == bytes32(0),
            "invalid investor id"
        );

        Investor storage newInvestor = investors[params.investorId];
        newInvestor.investorId = params.investorId;
        newInvestor.category = params.category;
        newInvestor.wallet = params.wallet;
        newInvestor.twitter = params.twitter;
        newInvestor.youtube = params.youtube;
        newInvestor.discord = params.discord;
        newInvestor.telegram = params.telegram;

        emit InvestorAdded(params.investorId, params.category);
    }

    function addAssetOption(
        bytes32 id,
        string memory name,
        uint chainId,
        address investmentToken,
        address assetToken,
        AssetCategory category
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        Asset memory a = assets[id];
        require(a.investmentToken == address(0), "id already taken");
        assets[id] = Asset({
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

    function setInvestmentOption(
        bytes32 id,
        bool enable
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        Asset memory asset = assets[id];
        require(asset.investmentToken != address(0), "Invalid id");
        assets[id].isActive = enable;
        emit SetInvestorAsset(id, enable);
    }

    function addUserInvestment(
        bytes32 investorId,
        bytes32 assetId,
        uint tokenAmount,
        uint assetAmount
    ) external onlyRole(DATA_MANAGER) {
        Asset memory asset = assets[assetId];
        require(asset.isActive, "Invalid asset id");
        Investor storage investor = investors[investorId];
        require(investor.investorId != bytes32(0), "invalid investor id");
        investor.investments[assetId].investmentAmount += tokenAmount;
        investor.investments[assetId].assetAmount += assetAmount;

        if (asset.category == AssetCategory.NODE_SALE) {
            investor.nodeSaleInvestment += tokenAmount;
        } else if (asset.category == AssetCategory.VC_SALE) {
            investor.vcSaleInvestment += tokenAmount;
        } else if (asset.category == AssetCategory.PUBLIC_SALE) {
            investor.publicSaleInvestment += tokenAmount;
        } else if (asset.category == AssetCategory.OTC_SALE) {
            investor.otcInvestment += tokenAmount;
        } else if (asset.category == AssetCategory.SIGNALS) {
            investor.signalsInvestment += tokenAmount;
        } else if (asset.category == AssetCategory.YIELD_AGGREGATOR) {
            investor.yieldAggregatorInvestment += tokenAmount;
        }

        investor.totalInvestment += tokenAmount;

        emit UserInvested(investorId, assetId, tokenAmount, assetAmount);
    }

    function getInvestor(
        bytes32 investorId
    ) external view returns (InvestorView memory iview) {
        Investor storage investor = investors[investorId];
        require(investor.investorId != bytes32(0), "invalid investor id");
        iview.category = investor.category;
        iview.investorId = investor.investorId;

        // if (investor.signalsInvestment > 2_000 * UNITS) {
        iview.signalSeeker = Tier.SILVER;
        // }

        if (investor.otcInvestment >= 10_000 * UNITS) {
            iview.otcOperator = Tier.PLATINUM;
        } else if (investor.otcInvestment >= 1_000 * UNITS) {
            iview.otcOperator = Tier.GOLD;
        } else {
            iview.otcOperator = Tier.SILVER;
        }

        if (investor.yieldAggregatorInvestment >= 10_000 * UNITS) {
            iview.realworldRaider = Tier.PLATINUM;
        } else if (investor.yieldAggregatorInvestment >= 1_000 * UNITS) {
            iview.realworldRaider = Tier.GOLD;
        } else {
            iview.realworldRaider = Tier.SILVER;
        }

        if (investor.nodeSaleInvestment >= 10_000 * UNITS) {
            iview.nodeMaximalist = Tier.PLATINUM;
        } else if (investor.nodeSaleInvestment >= 1_000 * UNITS) {
            iview.nodeMaximalist = Tier.GOLD;
        } else {
            iview.nodeMaximalist = Tier.SILVER;
        }

        if (investor.vcSaleInvestment >= 25_000 * UNITS) {
            iview.strategicSuit = Tier.PLATINUM;
        } else if (investor.vcSaleInvestment >= 5_000 * UNITS) {
            iview.strategicSuit = Tier.GOLD;
        } else {
            iview.strategicSuit = Tier.SILVER;
        }

        if (investor.publicSaleInvestment >= 10_000 * UNITS) {
            iview.launchpadLoyalist = Tier.PLATINUM;
        } else if (investor.publicSaleInvestment >= 1_000 * UNITS) {
            iview.launchpadLoyalist = Tier.GOLD;
        } else {
            iview.launchpadLoyalist = Tier.SILVER;
        }
    }

    function withdrawUserInvestment(
        bytes32 investorId,
        bytes32 assetId,
        uint assetAmount
    ) external onlyRole(DATA_MANAGER) {
        Asset memory asset = assets[assetId];
        require(asset.investmentToken != address(0), "Invalid asset id");
        Investor storage i = investors[investorId];

        require(
            i.investments[assetId].assetAmount >= assetAmount,
            "Invalid withdraw amount"
        );
        i.investments[assetId].assetAmount -= assetAmount;

        emit UserWithdraw(investorId, assetId, assetAmount);
    }

    function updateInvestorDetails(
        UpdateInvestorParams memory params
    ) external onlyRole(DATA_MANAGER) {
        require(
            investors[params.investorId].investorId != bytes32(0),
            "invalid investor id"
        );

        Investor storage newInvestor = investors[params.investorId];
        newInvestor.investorId = params.investorId;
        newInvestor.category = params.category;
        newInvestor.wallet = params.wallet;
        newInvestor.twitter = params.twitter;
        newInvestor.youtube = params.youtube;
        newInvestor.discord = params.discord;
        newInvestor.telegram = params.telegram;

        emit InvestorUpdated(params.investorId, params.category);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal virtual override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
