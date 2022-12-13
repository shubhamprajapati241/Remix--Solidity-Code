//SPDX-License-Identifier:MIT
pragma solidity 0.8.7;

contract structure{
    struct Book{
        string title;
        string author;
        uint256 bookID;
        uint256 price;
    }

    // define a struct- name of the struct variable to represent the struct
    Book book;

    function setBook() public {
        book= Book("Blokchain for beginners","Ineuron",4,1000);
    }

    function getBookId() public view returns(uint) {
        return book.bookID;
    }

    function getprice() public view returns(uint){
        return book.price;
    }   

    function getTitle() public view returns(string memory){
        return book.title;
    }

    function getauthor() public view returns(string memory){
        return book.author;
    }

}