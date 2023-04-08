// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract CrowdFunding {

    modifier objectiveExist(uint256 objectiveId) {
        require(objectives.length-1 >= objectiveId, "Objective not found");
        _;
    } 

    modifier fundRaisingClosed(uint objectiveId, bool checkAmountRaised) {
        Objective memory objective = objectives[objectiveId];
        require(objective.endTime > block.timestamp, "Fund Raising closed");
        if(checkAmountRaised) {
            require(objective.amountRaised < objective.amountToBeRaised, "Fund Raising closed");
        }
        _;
    } 

    mapping(uint => mapping(address => uint256)) contributionsByObjective;

    struct Objective {
        string name;
        address fundAddress;
        uint256 amountRaised;
        uint256 amountToBeRaised;
        uint256 endTime;
        address[] contributors;
    }

    Objective[] objectives;

    function raiseFund(string memory purpose, address fundAddress, uint256 amountToBeRaised, uint256 end) public{
        
         Objective memory newObjective = Objective({
            name: purpose,
            fundAddress: fundAddress,
            amountRaised: 0,
            amountToBeRaised: amountToBeRaised,
            endTime: end,
            contributors: new address[](0)
        });
        objectives.push(newObjective);
    }


    function contribute(uint256 objectiveId) payable public objectiveExist(objectiveId) fundRaisingClosed(objectiveId,true) {
        require(msg.value > 0, "> 0 ether contribution needed");
        Objective memory objective = objectives[objectiveId];
        if(!isExistingContributor(objective.contributors, msg.sender)) {
            objectives[objectiveId].contributors.push(msg.sender);
        }  
        contributionsByObjective[objectiveId][msg.sender] += msg.value;
        objective.amountRaised += msg.value;
    }


    function releaseUnmetObjectiveFunds(uint256 objectiveId) public objectiveExist(objectiveId) fundRaisingClosed(objectiveId,false){
        Objective memory objective = objectives[objectiveId];
        require(objective.amountRaised < objective.amountToBeRaised, "Objective was met");

        address[] memory contributors = objective.contributors;
        for (uint256 i = 0; i < contributors.length; i++) {
            address contributor = contributors[i];
            uint256 amount = contributionsByObjective[objectiveId][contributor];
            contributionsByObjective[objectiveId][contributor] = 0;
            if(amount > 0)
                (payable(contributor)).transfer(amount);
        }

        while(objectives[objectiveId].contributors.length > 0) {
            objectives[objectiveId].contributors.pop();
        }

    }

    function claimObjectiveFunds(uint256 objectiveId) public objectiveExist(objectiveId){
        Objective memory objective = objectives[objectiveId];
        require(msg.sender == objective.fundAddress, "Not Authorized");
        require(objective.amountRaised > 0, "No Fund Reminaing");
        require(objective.endTime < block.timestamp, "Fund Raising still ongoing");
        uint256 amountRaised = objective.amountRaised;
        require(amountRaised > objective.amountToBeRaised, "Not Enough Fund Raised");
        objective.amountRaised = 0;
        objectives[objectiveId] = objective;
        payable(objective.fundAddress).transfer(amountRaised);
    }

    function isExistingContributor(address[] memory contributors, address newContributor) private pure returns(bool){
        bool contributorExist = false;
        for (uint256 i = 0; i < contributors.length; i++) {
            if(contributors[i] == newContributor) {
                contributorExist = true;
                break;
            }
        }
        return contributorExist;
    }


}