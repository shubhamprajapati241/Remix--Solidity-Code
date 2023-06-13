// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Contract {
	struct User {
		uint balance;
		bool isActive;
	}

	mapping(address => User) public users;

    function createUser() external {
        // require(!users[msg.sender][isActive]);
        User memory u =  User(100, true);
        users[msg.sender] = u;
    }

    function isUserActive() external view returns(bool) {
        User memory u = users[msg.sender];
        

        return u.isActive;
    }

}


	// function createUser() external {
	// 	require(users[msg.sender][isActive], "Already exists");
	// 	// User memory u = new User("100", true);
	// 	// users[msg.sender] = u;
	// }
