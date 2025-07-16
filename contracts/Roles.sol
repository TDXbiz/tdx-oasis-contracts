// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Roles is Ownable {
    constructor(address _owner) Ownable(_owner) {}

    mapping(address => bool) private admins;

    event AdminSet(address indexed admin, bool enable);

    function setAdmin(address admin, bool enable) external onlyOwner {
        admins[admin] = enable;
        emit AdminSet(admin, enable);
    }

    function _onlyAdminOrOwner() internal view {
        address user = _msgSender();
        require(admins[user] || (owner() == user), "unauthorized caller");
    }

    modifier onlyAdminOrOwner() {
        _onlyAdminOrOwner();
        _;
    }
}
