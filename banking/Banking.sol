// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract Banking {


    modifier onlyAddress(address target) {
        require(msg.sender == target, "Caller is not the target address");
        _;
    }

    modifier hasBalance(uint amount) {
        require(userbalances[msg.sender] >= amount, "Insufficient Balance");
        _;
    }

    mapping(address => uint256) public userbalances;

    function deposit() payable public {
        require(msg.value > 0);
        userbalances[msg.sender] += msg.value;

    }

    function withdraw(address payable receiver, uint256 amount) public onlyAddress(receiver) hasBalance(amount){
        userbalances[receiver] -= amount;
        receiver.transfer(amount);
    }

    function transfer(address to, uint256 amount) public hasBalance(amount){
        userbalances[msg.sender] -= amount;
        userbalances[to] += amount;
    }


}