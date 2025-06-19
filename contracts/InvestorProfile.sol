// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./Roles.sol";

contract InvestorProfile is Roles {
    enum InvestorCategory {
        BEGINNER,
        PROFESSIONAL
    }

    struct Investor {
        bytes32 userId;
        InvestorCategory category;
        uint portfolioValue;
        // investment id => amount
        mapping(bytes32 => uint256) investments;
    }

    struct InvestmentAsset {
        bytes32 id;
        string name;
        address investmentToken;
        bool isActive;
    }

    event InvestorAdded(bytes32 investorId, InvestorCategory indexed category);
    event InvestorAssetAdded(bytes32 id, string name);
    event SetInvestorAsset(bytes32 id, bool isActive);
    event UserInvested(
        bytes32 indexed userId,
        bytes32 indexed assetId,
        uint tokenAmount,
        uint usdValue
    );
    event UserWithdraw(
        bytes32 indexed userId,
        bytes32 indexed assetId,
        uint tokenAmount,
        uint usdValue
    );

    mapping(bytes32 => Investor) private investors;
    mapping(bytes32 => InvestmentAsset) public investmentAssets;

    function addInvestor(
        bytes32 userId,
        InvestorCategory category
    ) external onlyAdminOrOwner {
        Investor storage i = investors[userId];
        require(i.userId != bytes32(0), "UserId already taken");
        investors[userId].userId = userId;
        investors[userId].category = category;
        investors[userId].portfolioValue = 0;

        emit InvestorAdded(userId, category);
    }

    function addInvestmentOption(
        bytes32 id,
        string memory name,
        address investmentToken
    ) external onlyOwner {
        InvestmentAsset memory a = investmentAssets[id];
        require(a.investmentToken == address(0), "Id already taken");
        investmentAssets[id] = InvestmentAsset({
            id: id,
            name: name,
            investmentToken: investmentToken,
            isActive: true
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
        bytes32 userId,
        bytes32 assetId,
        uint tokenAmount,
        uint usdAmount
    ) external onlyAdminOrOwner {
        InvestmentAsset memory a = investmentAssets[assetId];
        require(a.investmentToken != address(0), "Invalid asset id");
        Investor storage i = investors[userId];
        require(i.userId == bytes32(0), "Invalid user id");
        i.investments[assetId] += tokenAmount;
        i.portfolioValue += usdAmount;

        emit UserInvested(userId, assetId, tokenAmount, usdAmount);
    }

    function withdrawUserInvestment(
        bytes32 userId,
        bytes32 assetId,
        uint tokenAmount,
        uint usdAmount
    ) external onlyAdminOrOwner {
        InvestmentAsset memory a = investmentAssets[assetId];
        require(a.investmentToken != address(0), "Invalid asset id");
        // require(a.investmentToken != address(0), "Invalid asset id");
        Investor storage i = investors[userId];
        require(i.userId == bytes32(0), "Invalid user id");
        require(
            i.investments[assetId] >= tokenAmount,
            "Invalid withdraw amount"
        );
        require(i.portfolioValue >= usdAmount, "Invalid usd amount");
        i.investments[assetId] -= tokenAmount;
        i.portfolioValue -= usdAmount;

        emit UserWithdraw(userId, assetId, tokenAmount, usdAmount);
    }
}
