//SPDX-License-Identifier:MIT
pragma solidity 0.8.7;

contract structure{
   
    // Contact gas Cost = 77126
    struct Book{
        string title;
        string author;
        uint bookID;
        uint price;
    }

    // After defining struct = 77126
    
    Book book;

    function setBook() public {
        book= Book("Blokchain for beginners","Ineuron",4,1000);
    }

    // ----------- 1 --------------
    // Total Gas cost till setBook = 209044 
    // i. e. 209044 - 77126 = 1,31,918 for setBook()

    function getBookId() public view returns(uint) {
        return book.bookID;
    }

    // ----------- 2 --------------
    // Total Gas cost till getBookId = 235050  
    // i. e. 235050 - 209044 = 26,006 for getBookId()

    function getprice() public view returns(uint){
        return book.price;
    }   

    // ----------- 3 --------------
    // Total Gas cost till getprice = 248161   
    // i. e. 248161 - 235050 = 13,111 for getprice()


    function getTitle() public view returns(string memory){
        return book.title;
    }

    // ----------- 4 --------------
    // Total Gas cost till getTitle = 341437    
    // i. e. 341437 - 248161 = 93,276 for getTitle()

    function getauthor() public view returns(string memory){
        return book.author;
    }

    // ----------- 5 --------------
    // Total Gas cost till getauthor = 388579     
    // i. e. 388579 - 341437  = 47,142 for getauthor()

}