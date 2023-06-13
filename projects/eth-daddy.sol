// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// To Dos :
// 1. List Domains
// 2. Buy Domains
// 3. Get Paid

contract ETHDaddy is ERC721 {

    address public owner;
    uint256 public maxSupply;
    uint56 public totalSupply; // total no of supply till now

    struct Domain {
        string name;
        uint256 cost;
        bool isOwned;
    }

    mapping(uint256=>Domain) domains;

    modifier onlyOwner() {
         require(msg.sender == owner, "Must be owner"); 
         _;
    }

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        owner = msg.sender;
    }

    function list(string memory _name, uint256 _cost) public onlyOwner  {
        // [X] 3. update total domain count
         maxSupply++;
        // [X] 1. Model a domain using struct
        domains[maxSupply] = Domain(_name, _cost, false);
        // [X] 2. save the domain into map
    }

    // For getting domain details
    function getDomains(uint256 _id) public view returns(Domain memory) {
        return domains[_id];
    }

    // For getting domain balance
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function mint(uint256 _id) public payable {

        require(_id > 0, "ID cant be zero");
        require(_id <= maxSupply, "ID can't be more than max supply");
        require(domains[_id].isOwned == false, "Domain is alreay owned"); // Is domains already owned ?
        require(msg.value >= domains[_id].cost, "Buying amount should be greater than or equal to the Domain amount"); // msg.value should be greater or equal to domain cost

        
        //  After minting user will owned the domains thats why isOwned will be setas 
        domains[_id].isOwned = true;
        totalSupply++;
        _safeMint(msg.sender, _id);
    }

    // Owner withdrawing the amount from the smart contract
    function withDraw() public onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "WithDraw failed");
    }


}
