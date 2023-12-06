// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

library Creator {
    enum Rating {
        Unrated,
        Everyone,
        Teen,
        Mature,
        Adult
    }

    enum Status {
        Unavailable,
        Reviewing,
        Active,
        Inactive,
        Blocked,
        Banned
    }

    struct Detail {
        string name;
        string description;
        string location;
        Rating rating;
        Status status;
    }
}
