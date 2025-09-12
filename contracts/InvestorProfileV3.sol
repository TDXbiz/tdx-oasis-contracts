// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./InvestorProfileV2.sol";

contract InvestorProfileV3 is InvestorProfileV2, EIP712Upgradeable {
    using ECDSA for bytes32;

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

    function getInvestorProfile(
        bytes32 investorId,
        address requester,
        uint deadline,
        bytes memory signature
    ) external view returns (InvestorParamsV3 memory investor) {
        bytes32 structHash = keccak256(
            abi.encode(
                INVESTOR_PROFILE_REQUEST_TYPEHASH,
                investorId,
                requester,
                deadline
            )
        );

        bytes32 digest = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(digest, signature);

        require(hasRole(DATA_MANAGER, signer), "Not a data manager");
        require(block.timestamp <= deadline, "Request timed out");

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
        address requester,
        uint deadline,
        bytes calldata signature
    ) external view returns (Investment memory) {
        bytes32 structHash = keccak256(
            abi.encode(
                INVESTMENT_REQUEST_TYPEHASH,
                investorId,
                assetId,
                requester,
                deadline
            )
        );

        bytes32 digest = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(digest, signature);

        require(hasRole(DATA_MANAGER, signer), "Not a data manager");
        require(block.timestamp <= deadline, "Request timed out");

        Investor storage investor = investors[investorId];
        return investor.investments[assetId];
    }
}
