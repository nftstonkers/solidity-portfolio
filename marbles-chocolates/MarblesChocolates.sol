// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


abstract contract ExchangableItem {
    uint8 public immutable initialbalance;
    bool public exchangeSet;
    address public contractAddress;
    mapping(address => bool) public accountOpened;
    mapping(address => uint256) public balances;

    constructor(uint8 bal) {
        initialbalance = bal;
    }

    function open() public{
        require(!accountOpened[msg.sender], "Account already opened");
        accountOpened[msg.sender] = true;
        balances[msg.sender] += initialbalance;
    }

    function updateBalance(address account, uint256 newBalance) external {
        require(exchangeSet && msg.sender == contractAddress, "Only Exchange contract can update balance");
        balances[account] = newBalance;
    }

    function setContractAddress() external{
        require(!exchangeSet, "Exchange already set");
        exchangeSet = true;
        contractAddress = msg.sender;
    }
}


contract Marble is ExchangableItem(100) {
    
}

contract Chocolate is ExchangableItem(5) {

}


contract Exchange {



    Marble public marbleContract;
    Chocolate public chocolateContract;
    uint256 public etherToMarbleRate;
    uint256 public etherToChocolateRate;

    constructor(
        address _marbleContract,
        address _chocolateContract,
        uint256 _etherToMarbleRate,
        uint256 _etherToChocolateRate
    ) {
        marbleContract = Marble(_marbleContract);
        chocolateContract = Chocolate(_chocolateContract);
        marbleContract.setContractAddress();
        chocolateContract.setContractAddress();
        etherToMarbleRate = _etherToMarbleRate;
        etherToChocolateRate = _etherToChocolateRate;
    }



    function buy(bool isMarble) payable public {
        require(msg.value > 0 , "> 0 ether required");
        if(isMarble) {
            uint256 newMarbles = etherToMarbleRate * msg.value;
            marbleContract.updateBalance(msg.sender,marbleContract.balances(msg.sender) + newMarbles);
        } else {
            uint256 newChocolates = etherToChocolateRate * msg.value;
            chocolateContract.updateBalance(msg.sender,chocolateContract.balances(msg.sender) + newChocolates);
        }
    }


     function exchangeMarblesForChocolates(uint256 marblesAmount) public {
        uint256 senderMarbleBalance = marbleContract.balances(msg.sender);
        uint256 senderChocolateBalance = chocolateContract.balances(msg.sender);

        require(senderMarbleBalance >= marblesAmount, "Not enough marbles to exchange");

        uint256 chocolatesAmount = marblesAmount * (etherToChocolateRate/etherToMarbleRate);

        marbleContract.updateBalance(msg.sender, senderMarbleBalance - marblesAmount);
        chocolateContract.updateBalance(msg.sender, senderChocolateBalance + chocolatesAmount);
    }


}
