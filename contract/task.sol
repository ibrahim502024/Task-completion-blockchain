
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TaskRewardGenerator {
    struct Milestone {
        uint256 id;
        string description;
        uint256 rewardAmount;
        bool claimed;
    }

    address public owner;
    mapping(uint256 => Milestone) public milestones;
    mapping(address => uint256[]) public userMilestones;
    
    uint256 public nextMilestoneId;
    uint256 public totalRewardPool;

    event MilestoneAdded(uint256 id, string description, uint256 rewardAmount);
    event RewardClaimed(address user, uint256 milestoneId, uint256 rewardAmount);
    event RewardPoolUpdated(uint256 newAmount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // Function to add a new milestone
    function addMilestone(string memory _description, uint256 _rewardAmount) public onlyOwner {
        milestones[nextMilestoneId] = Milestone({
            id: nextMilestoneId,
            description: _description,
            rewardAmount: _rewardAmount,
            claimed: false
        });
        emit MilestoneAdded(nextMilestoneId, _description, _rewardAmount);
        nextMilestoneId++;
    }

    // Function to fund the reward pool
    function fundRewardPool() public payable onlyOwner {
        totalRewardPool += msg.value;
        emit RewardPoolUpdated(totalRewardPool);
    }

    // Function to claim reward for a specific milestone
    function claimReward(uint256 _milestoneId) public {
        require(milestones[_milestoneId].rewardAmount > 0, "Milestone does not exist");
        require(!milestones[_milestoneId].claimed, "Reward already claimed");
        require(totalRewardPool >= milestones[_milestoneId].rewardAmount, "Insufficient reward pool");

        // Mark milestone as claimed
        milestones[_milestoneId].claimed = true;

        // Transfer reward to user
        payable(msg.sender).transfer(milestones[_milestoneId].rewardAmount);

        // Update reward pool
        totalRewardPool -= milestones[_milestoneId].rewardAmount;

        emit RewardClaimed(msg.sender, _milestoneId, milestones[_milestoneId].rewardAmount);
    }

    // Function to check the balance of the reward pool
    function getRewardPoolBalance() public view returns (uint256) {
        return totalRewardPool;
    }

    // Function to get details of a specific milestone
    function getMilestone(uint256 _milestoneId) public view returns (Milestone memory) {
        return milestones[_milestoneId];
    }
}
