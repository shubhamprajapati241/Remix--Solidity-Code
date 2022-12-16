//SPDX-License-Identifier:MIT
pragma solidity 0.8.7;

contract structure{
    struct Book{
        string title;
        string author;
        uint256 bookID;
        uint256 price;
    }

    Book book;

    //  Optimise the setBook() function 
    //  Change all public function to exteral function call

    function setBook() external {
        Book memory addBook= Book("Blokchain for beginners","Ineuron",4,1000);
        book = addBook;
    }

    function getBookId() external view returns(uint) {
        return book.bookID;
    }

    function getprice() external view returns(uint){
        return book.price;
    }   

    function getTitle() external view returns(string memory){
        return book.title;
    }

    function getAuthor() external view returns(string memory){
        return book.author;
    }

}