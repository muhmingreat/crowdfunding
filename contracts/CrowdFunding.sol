// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrowdFunding {
    struct Campaign {
        address owner;
        uint256 goal;
        uint256 totalFunds;
        bool isGoalReached;
    }

    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public contributions;
    uint256 public campaignCount;

    event CampaignCreated(uint256 indexed campaignId, address indexed owner, uint256 goal);
    event Contributed(uint256 indexed campaignId, address indexed contributor, uint256 amount);
    event GoalReached(uint256 indexed campaignId, uint256 totalFunds);
    event FundsWithdrawn(uint256 indexed campaignId, address indexed owner, uint256 amount);

    // Create a new campaign
    function createCampaign(uint256 _goal) external {
        require(_goal > 0, "Goal must be greater than zero");
        
        campaigns[campaignCount] = Campaign({
            owner: msg.sender,
            goal: _goal,
            totalFunds: 0,
            isGoalReached: false
        });
        
        emit CampaignCreated(campaignCount, msg.sender, _goal);
        campaignCount++;
    }

    // Contribute to a campaign
    function contribute(uint256 _campaignId) external payable {
        require(_campaignId < campaignCount, "Invalid campaign ID");
        require(msg.value > 0, "Contribution must be greater than zero");
        
        Campaign storage campaign = campaigns[_campaignId];
        require(!campaign.isGoalReached, "Goal already reached");

        contributions[_campaignId][msg.sender] += msg.value;
        campaign.totalFunds += msg.value;

        // Check if the campaign goal is reached
        if (campaign.totalFunds >= campaign.goal) {
            campaign.isGoalReached = true;
            emit GoalReached(_campaignId, campaign.totalFunds);
        }

        emit Contributed(_campaignId, msg.sender, msg.value);
    }

    // Withdraw funds for the campaign owner if the goal is reached
    function withdrawFunds(uint256 _campaignId) external {
        require(_campaignId < campaignCount, "Invalid campaign ID");
        
        Campaign storage campaign = campaigns[_campaignId];
        require(msg.sender == campaign.owner, "Only the campaign owner can withdraw");
        require(campaign.isGoalReached, "Goal not reached yet");
        
        uint256 amount = campaign.totalFunds;
        campaign.totalFunds = 0; // Reset the total funds before transferring
        payable(campaign.owner).transfer(amount);

        emit FundsWithdrawn(_campaignId, campaign.owner, amount);
    }
}
