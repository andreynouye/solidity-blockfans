// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../Structures/Plan.sol";
import "../Structures/Subscription.sol";

interface ICreatorsPlans {
    event NFTTransferred(address indexed buyer, uint256 nftId);
    event Received(address indexed from, uint256 amount);
    event Recovered(
        address indexed sender,
        address tokenAddress,
        uint256 amountOrTokenId
    );

    function setPlan(
        string memory name,
        string memory description,
        string memory external_url,
        uint256 duration,
        uint256 price,
        uint256 units
    ) external;

    function getPlansByCreator() external view returns (uint256[] memory);

    function getPlanDetailsByCreator()
        external
        view
        returns (Plan.Detail[] memory);

    function getPublicPlansByCreator(
        address creator
    ) external view returns (uint256[] memory);

    function getPublicPlanDetailsByCreator(
        address creator
    ) external view returns (Plan.Detail[] memory);

    function getSoldUnitsPerPlan(
        uint256 planId
    ) external view returns (uint256);

    function deletePlan(uint256 planId) external;

    function permanentDeletePlan(uint256 planId) external;

    function restorePlan(uint256 planId) external;

    function buyPlan(uint256 planId) external;
}
