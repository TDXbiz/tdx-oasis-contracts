// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "./lib/SiweAuthUpgradeable.sol";
import "./InvestorProfileV3.sol";

contract InvestorProfileV4 is InvestorProfileV3, SiweAuthUpgradeable {
    error UnauthorizedCaller();
    error InvalidToken();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @custom:oz-upgrades-validate-as-initializer
    /// @custom:oz-upgrades-unsafe-allow missing-initializer-call
    function initializeV4(string memory inDomain) public reinitializer(4) {
        __SiweAuth_init(inDomain);
    }

    modifier onlyDataManager(bytes memory token) {
        if (msg.sender != authMsgSender(token)) revert InvalidToken();
        if (!hasRole(DATA_MANAGER, msg.sender)) revert UnauthorizedCaller();
        _;
    }

    // Authenticated view call for Sapphire using SIWE session authentication
    function getInvestorProfile(
        bytes32 investorId,
        bytes memory token
    )
        external
        view
        onlyDataManager(token)
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
        bytes32 assetId,
        bytes memory token
    ) external view onlyDataManager(token) returns (Investment memory) {
        Investor storage investor = investors[investorId];
        return investor.investments[assetId];
    }
}
