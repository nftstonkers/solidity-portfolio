// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract Lottery {

    enum LotteryState { NotStarted, InProgress, Closed }

    address public owner;
    uint256 public totalReward = 0;
    address[] public participants;
    LotteryState public lotteryState;

    address winner;

    event WinnerDecided(address winner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Not Authorized");
        _;
    }


    function startLottery() public onlyOwner{
        require(lotteryState == LotteryState.NotStarted, "Not allowed");
        lotteryState = LotteryState.InProgress;
    }

    function decideWinner() public onlyOwner{
        require(lotteryState == LotteryState.InProgress, "Not allowed");
        if(participants.length > 0) {
            uint256 randomIndex = random() % participants.length;
            winner = participants[randomIndex];
            emit WinnerDecided(winner);
            lotteryState = LotteryState.Closed;
        } else {
            lotteryState = LotteryState.NotStarted;
            totalReward = 0;
        }
    }

    function resetLottery() public onlyOwner {
        require(lotteryState == LotteryState.Closed, "Not allowed");
        if(totalReward > 0 ) {
            uint256 reward = totalReward;
            totalReward = 0;
            (payable(winner)).transfer(reward);
        }
        while (participants.length > 0) {
            participants.pop();
        }

        lotteryState = LotteryState.NotStarted;
    }

    function enter() payable public {
        require(lotteryState == LotteryState.InProgress, "Lottery not open");
        require(msg.value == 0.01 ether, "Pls send exactly 0.01 ether");
        for (uint256 i = 0; i < participants.length; i++) {
            if (participants[i] == msg.sender) {
                revert("Already participated");
            }
        }
        participants.push(msg.sender);
        totalReward += msg.value;
    }

    function claimReward() payable public {
        require(msg.sender == winner, "You aren't the winner");
        require(lotteryState == LotteryState.Closed, "Lottery isn't closed yet");
        require(totalReward > 0, "No reward available");
        uint256 reward = totalReward;
        totalReward = 0;
        (payable(winner)).transfer(reward);
    }

     function random() private view returns(uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }

}