// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./InvestorProfileV2.sol";

contract InvestorProfileV3 is InvestorProfileV2, EIP712Upgradeable {
    using ECDSA for bytes32;

    bytes32 private constant INVESTMENT_REQUEST_TYPEHASH =
        keccak256(
            "InvestmentRequest(bytes32 investorId,bytes32 assetId,address requester,uint256 deadline)"
        );
    bytes32 private constant INVESTOR_PROFILE_REQUEST_TYPEHASH =
        keccak256(
            "InvestorProfileRequest(bytes32 investorId,address requester,uint256 deadline)"
        );

    /// @custom:oz-upgrades-validate-as-initializer
    function initializeV3(
        string memory name,
        string memory version
    ) public reinitializer(3) {
        __EIP712_init(name, version);
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
}
