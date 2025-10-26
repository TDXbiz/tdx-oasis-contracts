// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "./lib/SiweAuthUpgradeable.sol";
import "./InvestorProfileV3.sol";

contract InvestorProfileV4 is InvestorProfileV3, SiweAuthUpgradeable {
    error UnauthorizedCaller();

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
        if (!isDataManager(token)) revert UnauthorizedCaller();
        _;
    }

    function isDataManager(bytes memory token) internal view returns (bool) {
        address caller = authMsgSender(token);
        return hasRole(DATA_MANAGER, caller);
    }

    function getInvestorProfile(
        bytes32 investorId,
        bytes memory token
    )
        external
        view
        onlyDataManager(token)
        returns (InvestorParamsV3 memory investor)
    {
        Investor storage s = investors[investorId];
        investor.investorId = s.investorId;
        investor.category = s.category;
        investor.wallet = s.wallet;
        investor.twitter = s.twitter;
        investor.youtube = s.youtube;
        investor.discord = s.discord;
        investor.telegram = s.telegram;
        investor.kycId = kycIds[s.investorId];
    }

    function getInvestmentDetails(
        bytes32 investorId,
        bytes32 assetId,
        bytes memory token
    ) external view onlyDataManager(token) returns (Investment memory) {
        return investors[investorId].investments[assetId];
    }
}
