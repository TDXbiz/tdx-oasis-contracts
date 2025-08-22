// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "./InvestorProfile.sol";

contract InvestorProfileV2 is InvestorProfile {
    function _addInvestor(
        AddInvestorParams memory params
    ) internal virtual override {
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
        emit InvestorAdded(params.investorId, params.category);
    }
}
