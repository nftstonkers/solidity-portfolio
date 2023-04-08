// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract BookRepository {

    address public librarian;
    Book[] public books;
    uint256 totalBooks;
    address public libraryContract;
    bool public librarySet;

    constructor() {
        librarian = msg.sender;
    }


    modifier onlyLibrarian() {
        require(msg.sender == librarian, "Not Authorized");
        _;
    }

    modifier onlyLibrary() {
        require(msg.sender == libraryContract, "Not Authorized");
        _;
    }

    modifier bookExist(uint256 id) {
        require(id > 0 && id <= totalBooks, "Invalid book id");
        _;
    }

    modifier canbeBorrowed(uint256 id) {
        require(!books[id-1].isBorrowed, "Book is already borrowed");
        _;
    }


   

    struct Book {
        uint256 id;
        string name;
        string author;
        bool isBorrowed;
        address borrowedBy;
        uint256 dueBy;
    }

    function add(string memory _name, string memory _author) public onlyLibrarian{
        require(msg.sender == librarian, "Not Authorized");
        totalBooks+=1;
        Book memory book = Book({
            id : totalBooks+1,
            name: _name,
            author: _author,
            isBorrowed: false,
            borrowedBy: address(0),
            dueBy: 0
        });
        books.push(book);
    }

    function burn(uint256 _bookId) public onlyLibrarian bookExist(_bookId) canbeBorrowed(_bookId) {
        delete books[_bookId-1];
        totalBooks--;
    }

    function borrow(address borrower, uint256 _bookId, uint256 timeInMs) external onlyLibrary bookExist(_bookId) canbeBorrowed(_bookId) {
        Book memory book = books[_bookId-1];
        book.isBorrowed = true;
        book.borrowedBy = borrower;
        book.dueBy = block.timestamp + timeInMs;
        books[_bookId-1] = book;
    }

    function returnBook(address borrower, uint256 _bookId) external bookExist(_bookId) onlyLibrary{
        Book memory book = books[_bookId-1];
        require(book.borrowedBy == borrower, "Invalid Borrower");
        require(book.isBorrowed, "Book isn't borrowed");
        book.isBorrowed = false;
        book.borrowedBy = address(0);
        book.dueBy = 0;
        books[_bookId-1] = book;
    }

    function getAllBooks() public view returns(Book[] memory) {
        return books;
    }

    function setLibrary() external {
        require(!librarySet, "Library already set");
        librarySet = true;
        libraryContract = msg.sender;
    }


}