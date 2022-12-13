// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract structDemo {

    struct Book {
        string title;
        string author;
        uint bookId;
        uint price;
    }

    Book book;

    function setBook() public {
        book = Book("Blockchain Book","Shubham", 101, 1000);
    }    

    function getBook() public view returns(Book memory) {
        return book;
    }

    function getBookId() public view returns(uint) {
        return book.bookId;
    }

    function getBookName() public view returns(string memory) {
        return book.title;
    }
}