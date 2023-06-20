// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

contract Dappazon {
    address public owner;

    struct Item {
        uint256 id;
        string name;
        string category;
        string image;
        uint256 cost;
        uint256 rating;
        uint256 stock;
    }

    struct Order {
        uint256 time;
        Item item;
    }

    mapping(uint256 => Item) public items;
    mapping(address => mapping(uint256 => Order)) public orders;
    mapping(address => uint256) public orderCount;

    event Buy(address buyer, uint256 orderId, uint256 itemId);
    event List(string name, uint256 cost, uint256 quantity);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function list(
        uint256 _id,
        string memory _name,
        string memory _category,
        string memory _image,
        uint256 _cost,
        uint256 _rating,
        uint256 _stock
    ) public onlyOwner {
        Item memory item = Item(
            _id,
            _name,
            _category,
            _image,
            _cost,
            _rating,
            _stock
        );
        items[_id] = item;
        emit List(_name, _cost, _stock);
    }

    function buy(uint256 _id) public payable {
        Item memory item = items[_id];                       // Fetch item
        require(msg.value >= item.cost);                     // Require enough ether to buy item
        require(item.stock > 0);                             // Require item is in stock
        Order memory order = Order(block.timestamp, item);   // Create order
        // Add order for user
        orderCount[msg.sender]++; // <-- Order ID
        orders[msg.sender][orderCount[msg.sender]] = order;
        items[_id].stock = item.stock - 1;                    // Subtract stock
        emit Buy(msg.sender, orderCount[msg.sender], item.id);
    }

    function withdraw() public onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success);
    }
}