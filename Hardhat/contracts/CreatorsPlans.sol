// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Interfaces/IBlockfans.sol";
import "./Interfaces/ICreators.sol";
import "./Interfaces/ICreatorsPlans.sol";
import "./Structures/Creator.sol";
import "./Structures/Plan.sol";
import "./Structures/Subscription.sol";

contract CreatorsPlans is Ownable, ICreatorsPlans {
    IBlockfans private blockFansContract;
    ICreators private creatorsContract;

    address payable private blockFansAddress;

    uint256 public nextPlanId = 1;
    uint256 public nextSubscriptionId = 1;

    mapping(uint256 => Plan.Detail) private plans;
    mapping(address => uint256[]) private creatorPlans;
    mapping(address => uint256[]) private publicPlans;

    mapping(uint256 => Subscription.Detail) public subscriptions;
    mapping(uint256 => uint256) private soldUnitsPerPlan;

    constructor() ERC721("BlockfansPlans", "BFP") {
        blockFansAddress = payable(address(0));
        blockFansContract = IBlockfans(address(0));
        creatorsContract = ICreators(address(0));
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable {
        emit Received(msg.sender, msg.value);
    }

    function _removePlanIdFromCreator(address creator, uint256 planId) private {
        uint256 length = creatorPlans[creator].length;
        for (uint i = 0; i < length; i++) {
            if (creatorPlans[creator][i] == planId) {
                creatorPlans[creator][i] = creatorPlans[creator][length - 1];
                creatorPlans[creator].pop();
                break;
            }
        }
    }

    function _removePlanIdFromPublic(address creator, uint256 planId) private {
        uint256 length = publicPlans[creator].length;
        for (uint i = 0; i < length; i++) {
            if (publicPlans[creator][i] == planId) {
                publicPlans[creator][i] = publicPlans[creator][length - 1];
                publicPlans[creator].pop();
                break;
            }
        }
    }

    function _mintPlan(uint256 planId) internal returns (uint256) {
        Plan.Detail memory plan = plans[planId];

        uint256 newSubscriptionId = nextSubscriptionId++;

        Subscription.Detail memory newSubscription = Subscription.Detail(
            newSubscriptionId,
            plan.planId,
            block.timestamp,
            plan.duration
        );

        subscriptions[newSubscriptionId] = newSubscription;

        return newSubscriptionId;
    }

    function setBlockFans(address blockFans) external onlyOwner {
        blockFansAddress = payable(blockFans);
        blockFansContract = IBlockfans(blockFans);
    }

    function setCreators(address creatorsAddress) external onlyOwner {
        creatorsContract = ICreators(creatorsAddress);
    }

    function setPlan(
        string memory name,
        string memory description,
        string memory external_url,
        uint256 duration,
        uint256 price,
        uint256 units
    ) public override {
        require(creatorsContract.isCreator(msg.sender), "Not a creator");

        uint256 newPlanId = nextPlanId++;

        Plan.Detail memory newPlan = Plan.Detail(
            newPlanId,
            msg.sender,
            name,
            description,
            external_url,
            duration,
            price,
            units,
            Plan.Status.Available
        );

        plans[newPlanId] = newPlan;
        creatorPlans[msg.sender].push(newPlanId);
        publicPlans[msg.sender].push(newPlanId);
    }

    function getPlansByCreator()
        public
        view
        override
        returns (uint256[] memory)
    {
        return creatorPlans[msg.sender];
    }

    function getPlanDetailsByCreator()
        public
        view
        override
        returns (Plan.Detail[] memory)
    {
        uint256[] memory planIds = creatorPlans[msg.sender];
        Plan.Detail[] memory planDetails = new Plan.Detail[](planIds.length);

        for (uint i = 0; i < planIds.length; i++) {
            planDetails[i] = plans[planIds[i]];
        }

        return planDetails;
    }

    function getPublicPlansByCreator(
        address creator
    ) public view override returns (uint256[] memory) {
        return publicPlans[creator];
    }

    function getPublicPlanDetailsByCreator(
        address creator
    ) public view override returns (Plan.Detail[] memory) {
        uint256[] memory planIds = publicPlans[creator];
        Plan.Detail[] memory planDetails = new Plan.Detail[](planIds.length);

        for (uint i = 0; i < planIds.length; i++) {
            planDetails[i] = plans[planIds[i]];
        }

        return planDetails;
    }

    function getSoldUnitsPerPlan(
        uint256 planId
    ) public view override returns (uint256) {
        return soldUnitsPerPlan[planId];
    }

    function deletePlan(uint256 planId) public override {
        require(plans[planId].creator == msg.sender, "Not the creator");
        require(
            plans[planId].status == Plan.Status.Pending ||
                plans[planId].status == Plan.Status.Available,
            "Not Available"
        );

        plans[planId].status = Plan.Status.Trashed;

        _removePlanIdFromPublic(msg.sender, planId);
    }

    function permanentDeletePlan(uint256 planId) public override {
        require(plans[planId].creator == msg.sender, "Not the creator");
        require(plans[planId].status == Plan.Status.Trashed, "Not Available");

        delete plans[planId];

        _removePlanIdFromCreator(msg.sender, planId);
        _removePlanIdFromPublic(msg.sender, planId);
    }

    function restorePlan(uint256 planId) public override {
        require(plans[planId].creator == msg.sender, "Not the creator");

        plans[planId].status = Plan.Status.Available;

        publicPlans[msg.sender].push(planId);
    }

    function buyPlan(uint256 planId) external override {
        Plan.Detail storage plan = plans[planId];

        require(
            plan.units == 0 || soldUnitsPerPlan[planId] < plan.units,
            "Sold Out"
        );
        require(plan.status == Plan.Status.Available, "Not Available");
        require(
            blockFansContract.allowance(msg.sender, address(this)) >=
                plan.price * 10 ** 18,
            "Allowance not set"
        );
        require(
            blockFansContract.transferFrom(
                msg.sender,
                blockFansAddress,
                plan.price * 10 ** 18
            ),
            "Transfer failed"
        );

        uint256 newCardId = _mintPlan(planId);

        soldUnitsPerPlan[planId]++;

        if (plan.units != 0 && soldUnitsPerPlan[planId] >= plan.units) {
            plan.status = Plan.Status.SoldOut;
        }

        emit NFTTransferred(msg.sender, newCardId);
    }

    function withdraw(
        address tokenAddress,
        uint256 amountOrTokenId
    ) external onlyOwner {
        if (tokenAddress == address(0)) {
            require(
                address(this).balance >= amountOrTokenId,
                "Insufficient ETH balance in contract"
            );
            payable(owner()).transfer(amountOrTokenId);
            emit Recovered(msg.sender, tokenAddress, amountOrTokenId);
        } else {
            try IERC20(tokenAddress).transfer(owner(), amountOrTokenId) {
                emit Recovered(msg.sender, tokenAddress, amountOrTokenId);
                return;
            } catch {}

            try
                IERC721(tokenAddress).safeTransferFrom(
                    address(this),
                    owner(),
                    amountOrTokenId
                )
            {
                emit Recovered(msg.sender, tokenAddress, amountOrTokenId);
                return;
            } catch {}

            revert("Token type not supported or insufficient balance");
        }
    }
}
