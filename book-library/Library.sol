// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./BookRepository.sol";

contract Library {

    BookRepository public bookRepo;
    mapping(address => Member) public members;
    uint256 totalBalance;

    uint256 public constant MEMBERSHIPFEE = 5 ether;
    uint256 public constant FINEFORTENMINUTES = 1 ether;
    uint256 public constant FINEFORTHIRTYMINUTES  = 5 ether;

    struct Member {
        bool registered;
        uint8 noOfBooks;
        uint256 balance;
    }

    constructor(address _bookRepo) {
        bookRepo = BookRepository(_bookRepo);
        bookRepo.setLibrary();
    }

    modifier onlyMember {
        require(members[msg.sender].registered, "Not a member");
        _;
    }

    function becomeMember() payable public {
        require(msg.value == MEMBERSHIPFEE, "Please send amount equal to membership fee");
        require(members[msg.sender].registered, "Already a member");
        Member memory member = Member({
            registered: true,
            noOfBooks: 0,
            balance: msg.value
        });

        members[msg.sender] = member;
        totalBalance += msg.value;
    }

    function borrow(uint256 _bookId, uint256 _timeInMs) public onlyMember{
        require(members[msg.sender].noOfBooks <=2, "Max books borrowed");
        members[msg.sender].noOfBooks++;
        bookRepo.borrow(msg.sender, _bookId, _timeInMs);
    }

    function returnBook(uint256 _bookId) public onlyMember {
        (,,,,,uint256 dueDate) = (bookRepo.books(_bookId - 1));
        uint256 totalFine = calculateFine(dueDate, block.timestamp);
        if (totalFine > 0) {
            bookRepo.returnBook(msg.sender, _bookId);
            Member memory  member = members[msg.sender];
            member.balance -= totalFine;
            member.noOfBooks--;
            members[msg.sender] = member;
        }  
    }

    
    function cancelMembership() public payable onlyMember{
        Member memory  member = members[msg.sender];
        require(member.noOfBooks == 0, "Books still rented");
        require(member.balance > 0, "Insufficient balance");
        uint256 balance = member.balance;
        delete members[msg.sender];
        payable(msg.sender).transfer(balance);
    }

    function calculateFine(uint256 dueBy, uint256 timestamp) private pure returns(uint256){
        if(dueBy>timestamp) 
            return 0;
        else {
            uint256 totalDelay = (timestamp - dueBy);
            if (totalDelay < 1000*60*10)
                return 0;
            else if (totalDelay < 1000*60*30)
                return FINEFORTENMINUTES;
            else
                return FINEFORTHIRTYMINUTES;
        }
    }




}