// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./Roles.sol";

contract InvestorProfile is Roles {
    enum InvestorCategory {
        BEGINNER,
        PROFESSIONAL
    }

    struct Investment {
        uint investmentAmount;
        uint assetAmount;
    }

    struct Investor {
        bytes32 userId;
        InvestorCategory category;
        // investment id => amount
        mapping(bytes32 => Investment) investments;
    }

    struct InvestmentAsset {
        bytes32 id;
        string name;
        address investmentToken;
        address assetToken;
        uint chainId;
        bool isActive;
    }

    event InvestorAdded(bytes32 investorId, InvestorCategory indexed category);
    event InvestorAssetAdded(bytes32 id, string name);
    event SetInvestorAsset(bytes32 id, bool isActive);
    event UserInvested(
        bytes32 indexed userId,
        bytes32 indexed assetId,
        uint tokenAmount,
        uint assetAmount
    );
    event UserWithdraw(
        bytes32 indexed userId,
        bytes32 indexed assetId,
        uint tokenAmount,
        uint assetAmount
    );

    mapping(bytes32 => Investor) private investors;
    mapping(bytes32 => InvestmentAsset) public investmentAssets;

    function addInvestor(
        bytes32 userId,
        InvestorCategory category
    ) external onlyAdminOrOwner {
        Investor storage i = investors[userId];
        require(i.userId == bytes32(0), "UserId already taken");
        investors[userId].userId = userId;
        investors[userId].category = category;

        emit InvestorAdded(userId, category);
    }

    function addInvestmentOption(
        bytes32 id,
        string memory name,
        uint chainId,
        address investmentToken,
        address assetToken
    ) external onlyOwner {
        InvestmentAsset memory a = investmentAssets[id];
        require(a.investmentToken == address(0), "Id already taken");
        investmentAssets[id] = InvestmentAsset({
            id: id,
            name: name,
            chainId: chainId,
            investmentToken: investmentToken,
            assetToken: assetToken,
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
        uint assetAmount
    ) external onlyAdminOrOwner {
        InvestmentAsset memory a = investmentAssets[assetId];
        require(a.investmentToken != address(0), "Invalid asset id");
        Investor storage i = investors[userId];
        require(i.userId == bytes32(0), "Invalid user id");
        i.investments[assetId].investmentAmount += tokenAmount;
        i.investments[assetId].assetAmount += assetAmount;

        emit UserInvested(userId, assetId, tokenAmount, assetAmount);
    }

    // function withdrawUserInvestment(
    //     bytes32 userId,
    //     bytes32 assetId,
    //     uint investmentAmount,
    //     uint assetAmount
    // ) external onlyAdminOrOwner {
    //     InvestmentAsset memory a = investmentAssets[assetId];
    //     require(a.investmentToken != address(0), "Invalid asset id");
    //     // require(a.investmentToken != address(0), "Invalid asset id");
    //     Investor storage i = investors[userId];
    //     require(i.userId == bytes32(0), "Invalid user id");
    //     require(
    //         i.investments[assetId].assetAmount >= assetAmount,
    //         "Invalid withdraw amount"
    //     );
    //     require(
    //         i.investments[assetId].investAmount >= assetAmount,
    //         "Invalid withdraw amount"
    //     );

    //     emit UserWithdraw(userId, assetId, tokenAmount, usdAmount);
    // }
}
