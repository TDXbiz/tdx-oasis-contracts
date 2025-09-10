// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "./InvestorProfileV2.sol";

contract InvestorProfileV3 is InvestorProfileV2 {
    struct InvestorParamsV3 {
        bytes32 investorId;
        InvestorCategory category;
        string kycId;
        string wallet;
        string twitter;
        string youtube;
        string discord;
        string telegram;
    }

    mapping(bytes32 => string) internal kycIds;

    function addInvestor(
        InvestorParamsV3 memory params
    ) external virtual onlyRole(DATA_MANAGER) {
        _addInvestor(params);
    }

    function _addInvestor(InvestorParamsV3 memory params) internal virtual {
        require(
            investors[params.investorId].investorId == bytes32(0),
            "invalid investor id"
        );

        require(bytes(params.wallet).length > 20, "invalid wallet address");

        Investor storage newInvestor = investors[params.investorId];
        newInvestor.investorId = params.investorId;
        newInvestor.category = params.category;
        newInvestor.wallet = params.wallet;
        newInvestor.twitter = params.twitter;
        newInvestor.youtube = params.youtube;
        newInvestor.discord = params.discord;
        newInvestor.telegram = params.telegram;
        kycIds[params.investorId] = params.kycId;
        emit InvestorAdded(params.investorId, params.category);
    }

    function _updateInvestor(InvestorParamsV3 memory params) internal virtual {
        require(
            investors[params.investorId].investorId != bytes32(0),
            "invalid investor id"
        );

        Investor storage investor = investors[params.investorId];
        investor.investorId = params.investorId;
        investor.category = params.category;
        investor.wallet = params.wallet;
        investor.twitter = params.twitter;
        investor.youtube = params.youtube;
        investor.discord = params.discord;
        investor.telegram = params.telegram;
        kycIds[params.investorId] = params.kycId;

        emit InvestorUpdated(params.investorId, params.category);
    }

    function updateInvestorDetails(
        InvestorParamsV3 memory params
    ) external virtual onlyRole(DATA_MANAGER) {
        _updateInvestor(params);
        emit InvestorUpdated(params.investorId, params.category);
    }

    function getInvestorProfile(
        bytes32 investorId
    )
        external
        view
        onlyRole(DATA_MANAGER)
        returns (InvestorParamsV3 memory investor)
    {
        Investor storage params = investors[investorId];
        investor.investorId = params.investorId;
        investor.category = params.category;
        investor.wallet = params.wallet;
        investor.twitter = params.twitter;
        investor.youtube = params.youtube;
        investor.discord = params.discord;
        investor.telegram = params.telegram;
        investor.kycId = kycIds[params.investorId];
    }

    function getInvestmentDetails(
        bytes32 investorId,
        bytes32 assetId
    ) external view onlyRole(DATA_MANAGER) returns (Investment memory) {
        Investor storage investor = investors[investorId];
        return investor.investments[assetId];
    }
}
