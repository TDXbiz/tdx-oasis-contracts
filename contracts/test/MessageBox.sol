// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "../InvestorProfileParams.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "../lib/SiweAuthUpgradeable.sol";

/// this is just a dummy contract to test the SiweAuthUpgradeable
contract MessageBox is UUPSUpgradeable, SiweAuthUpgradeable {
    string private _message;

    address public owner;

    error UnAuthorizedCaller(address caller);

    function initialize(
        address _owner,
        string memory inDomain
    ) external initializer {
        __UUPSUpgradeable_init();
        __SiweAuth_init(inDomain);
        owner = _owner;
    }

    modifier onlyOwner(bytes memory token) {
        address caller = authMsgSender(token);
        if (caller != owner && msg.sender != owner) {
            revert UnAuthorizedCaller(caller);
        }
        _;
    }
    function setMessage(string calldata newMessage) external {
        require(msg.sender == owner, "Only owner can set message");
        _message = newMessage;
    }

    function getMessage(
        bytes memory token
    ) external view onlyOwner(token) returns (string memory) {
        return _message;
    }

    function _authorizeUpgrade(address) internal view override {
        require(msg.sender == owner, "Only owner can upgrade");
    }
}
