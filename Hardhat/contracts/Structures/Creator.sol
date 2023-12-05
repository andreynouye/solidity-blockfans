// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

library Creator {
    enum Status {
        Unavailable,
        Reviewing,
        Active,
        Inactive,
        Blocked,
        Banned
    }

    struct Detail {
        Status status;
    }
}
