# TDX Investor Profile

Oasis sapphire contracts for the TDX Investor Profile. The contracts follows UUPS upgradeable patterns to accumulate new changes on the changes and we are using `hardhat-upgrades` package from the `openzeppelin` for implementing the UUPS pattern.

Till now, there are 4 versions of contracts been deployed. The deployment addresses can be found in the [.openzeppelin](./.openzeppelin) folder.

The upgrade access is right now is with

-   On testnet - 0x55ecEb75176fA99d6108a4a1f83766701556867B
-   On mainnet - 0xDFD2168901BD0825d48d44e10A8a387A035aaf2F

## Version 1

This is the base version where we have implemented

1. Investor
2. Investment Option
3. UserInvestment

For a successful user investment registration, the following steps must be followed in order

1. Add the user profile with the investorId (bytes32) - unique to the user with the function `addInvestor`.
2. Add the investment option with the assetId (bytes32) that the investor invested with the function `addAssetOption`.
3. Once the above two are in place, then we can register the user investment with the (investorId, assetId, tokenAmount, assetAmount) with the function `addUserInvestment`.

NOTE: Remember that we only need to add the user and investment option once. We can register as many investment records for the investors after that.

### Roles

This version contains only 2 roles.

1. DEFAULT_ADMIN_ROLE - the default admin provided by the `AccessControlUpgradeable` contract. Only the admin can add investment options on the contract.
2. DATA_MANAGER_ROLE - is a custom role to grant access for investor and investment management.

## Version 2

-   The version 2 is deployed as a patch to add a validation on the user wallet while adding the users.
-   Right now, the tdx app only supports KYC for the users using their main EVM wallet. Other wallets are not supported as the main user wallet.
-   This version check if the wallet address added has a min length of 20 bytes. If so, the check passed and the investment is added.

## Version 3

-   The version 3 has introduced some breaking changes to the contract such as Authenticated View calls and KYC credentials on the investor profile.
-   For the authenticated view calls, users with `DATA_MANAGER_ROLE` must provide the `EIP 712 typed signature` as specified by the function in order to get the data.
-   For the KYC Ids, a new mapping is added to the contract in order to support the existing layout structure.
-   To register the KYC Id of the existing users, we can call the `updateInvestorDetails` function with the `InvestorParamsV3` struct.

## Version 4

-   The version 4 has changes related to the view call authentication.
-   In this version, we are using `SiweAuth` for the authenticated view calls.
-   SiweAuth is a standard EVM protocol and the standard implementation is available in the `@oasisprotocol/sapphire-contracts` package. But I made it into an OZ upgradeable version as required which can be found [here](./contracts/lib/SiweAuthUpgradeable.sol)
