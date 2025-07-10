// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

abstract contract InvestorProfileParams {
    enum InvestorCategory {
        CONSERVATIVE,
        BALANCED,
        AGGRESIVE,
        HIGHRISK
    }

    enum Tier {
        SILVER,
        GOLD,
        PLATINUM
    }

    struct AddInvestorParams {
        bytes32 investorId;
        InvestorCategory category;
        string wallet;
        string twitter;
        string youtube;
        string discord;
        string telegram;
    }

    struct InvestorView {
        bytes32 investorId;
        Tier otcOperator;
        Tier signalSeeker;
        Tier strategicSuit;
        Tier nodeMaximalist;
        Tier realworldRaider;
        Tier launchpadLoyalist;
        InvestorCategory category;
    }
}
