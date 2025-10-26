// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {SignatureRSV, A13e} from "@oasisprotocol/sapphire-contracts/contracts/auth/A13e.sol";
import {ParsedSiweMessage, SiweParser} from "@oasisprotocol/sapphire-contracts/contracts/SiweParser.sol";
import {Sapphire} from "@oasisprotocol/sapphire-contracts/contracts/Sapphire.sol";
import {AuthToken} from "@oasisprotocol/sapphire-contracts/contracts/auth/SiweAuth.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract SiweAuthUpgradeable is Initializable, A13e {
    /// Domain which the dApp is associated with
    string internal _domain;
    /// Encryption key which the authentication tokens are encrypted with
    bytes32 private _authTokenEncKey;
    /// Default authentication token validity, if no expiration-time provided
    uint256 private constant DEFAULT_VALIDITY = 24 hours;

    /// Chain ID in the SIWE message does not match the actual chain ID
    error SiweAuth_ChainIdMismatch();
    /// Domain in the SIWE message does not match the domain of a dApp
    error SiweAuth_DomainMismatch();
    /// User address in the SIWE message does not match the message signer's address
    error SiweAuth_AddressMismatch();
    /// The Not before value in the SIWE message is still in the future
    error SiweAuth_NotBeforeInFuture();
    /// Validity of the authentication token or the Expires value in the SIWE message is in the past
    error SiweAuth_Expired();

    /**
     * @notice Instantiate the contract which uses SIWE for authentication and
     * runs on the specified domain.
     * @param inDomain The domain this contract is associated with
     */
    function __SiweAuth_init(string memory inDomain) internal onlyInitializing {
        __SiweAuth_init_unchained(inDomain);
    }

    function __SiweAuth_init_unchained(
        string memory inDomain
    ) internal onlyInitializing {
        _authTokenEncKey = bytes32(Sapphire.randomBytes(32, ""));
        _domain = inDomain;
    }

    /**
     * @notice Login using a SIWE message and signature
     * @param siweMsg The signed SIWE message
     * @param sig The signature of the SIWE message
     * @return The encrypted authentication token
     */
    function login(
        string calldata siweMsg,
        SignatureRSV calldata sig
    ) external view override returns (bytes memory) {
        AuthToken memory b;

        // Derive the user's address from the signature.
        bytes memory eip191msg = abi.encodePacked(
            "\x19Ethereum Signed Message:\n",
            Strings.toString(bytes(siweMsg).length),
            siweMsg
        );
        address addr = ecrecover(
            keccak256(eip191msg),
            uint8(sig.v),
            sig.r,
            sig.s
        );
        b.userAddr = addr;

        ParsedSiweMessage memory p = SiweParser.parseSiweMsg(bytes(siweMsg));

        if (p.chainId != block.chainid) {
            revert SiweAuth_ChainIdMismatch();
        }

        if (keccak256(p.schemeDomain) != keccak256(bytes(_domain))) {
            revert SiweAuth_DomainMismatch();
        }
        b.domain = string(p.schemeDomain);

        if (p.addr != addr) {
            revert SiweAuth_AddressMismatch();
        }

        if (
            p.notBefore.length != 0 &&
            block.timestamp <= SiweParser.timestampFromIso(p.notBefore)
        ) {
            revert SiweAuth_NotBeforeInFuture();
        }

        if (p.expirationTime.length != 0) {
            // Compute expected block number at expiration time.
            uint256 expirationTime = SiweParser.timestampFromIso(
                p.expirationTime
            );
            b.validUntil = expirationTime;
        } else {
            // Otherwise, just take the default validity.
            b.validUntil = block.timestamp + DEFAULT_VALIDITY;
        }
        if (block.timestamp >= b.validUntil) {
            revert SiweAuth_Expired();
        }

        // Store statement from the SIWE message.
        b.statement = string(p.statement);

        // Store resources from the SIWE message.
        b.resources = new string[](p.resources.length);
        for (uint256 i = 0; i < p.resources.length; i++) {
            b.resources[i] = string(p.resources[i]);
        }

        bytes memory encB = Sapphire.encrypt(
            _authTokenEncKey,
            0,
            abi.encode(b),
            ""
        );
        return encB;
    }

    /**
     * @notice Return the domain associated with the dApp.
     * @return The domain string
     */
    function domain() public view returns (string memory) {
        return _domain;
    }

    /**
     * @notice Get the authenticated address from a token
     * @param token The authentication token
     * @return The authenticated user address or zero address if token is empty
     */
    function authMsgSender(
        bytes memory token
    ) internal view override checkRevokedAuthToken(token) returns (address) {
        if (token.length == 0) {
            return address(0);
        }

        AuthToken memory b = decodeAndValidateToken(token);
        return b.userAddr;
    }

    /**
     * @notice Get the statement from the authentication token
     * @param token The authentication token
     * @return The statement string from the SIWE message
     */
    function getStatement(
        bytes memory token
    ) internal view checkRevokedAuthToken(token) returns (string memory) {
        if (token.length == 0) {
            return "";
        }

        AuthToken memory b = decodeAndValidateToken(token);
        return b.statement;
    }

    /**
     * @notice Get all resources from the authentication token
     * @param token The authentication token
     * @return Array of resource URIs the token grants access to
     */
    function getResources(
        bytes memory token
    ) internal view checkRevokedAuthToken(token) returns (string[] memory) {
        if (token.length == 0) {
            return new string[](0);
        }

        AuthToken memory b = decodeAndValidateToken(token);
        return b.resources;
    }

    /**
     * @notice Helper function to decrypt, decode and validate a token
     * @dev Performs token decoding as well as domain and validation
     * @param token The authentication token
     * @return The decoded and validated AuthToken struct
     */
    function decodeAndValidateToken(
        bytes memory token
    ) internal view virtual returns (AuthToken memory) {
        bytes memory authTokenEncoded = Sapphire.decrypt(
            _authTokenEncKey,
            0,
            token,
            ""
        );
        AuthToken memory b = abi.decode(authTokenEncoded, (AuthToken));

        // Validate domain
        if (keccak256(bytes(b.domain)) != keccak256(bytes(_domain))) {
            revert SiweAuth_DomainMismatch();
        }

        // Validate expiry
        if (b.validUntil < block.timestamp) {
            revert SiweAuth_Expired();
        }

        return b;
    }
}
