// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.5.0 < 0.9.0;

interface ERC20Interface {
    function totalSupply() external view returns (uint); 
    function balanceOf(address tokenOwner) external view returns (uint balance); 
    function transfer(address to, uint tokens) external returns (bool success);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens); 
}


contract Block is ERC20Interface {
    string public name="SpecialToken";  // name of the token
    string public symbol = "STN"; // symbol of the token
    uint public decimal = 0; // upto how many decimal places our token will be divisible.
    // Generally ERC20 token it is upto 18 decimal but for our example we putting zero in it/
    uint public override totalSupply; // Here we provide total supply of our token
    address public founder; // here we store address of the founder of token
    mapping(address=>uint) public balances; // this is keep the track of balances of particular user or address.
    mapping(address=> mapping(address=> uint)) allowed; // Nested mapping
    
    constructor() {
        // Initializing the variable here
        totalSupply = 100000; // total supply as 10000
        founder = msg.sender; // token founder will be msg.sender
        balances[founder] = totalSupply; 
    }

    // For checking the balance token of tokenowner
    function balanceOf(address tokenOwner) public view override returns(uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to,uint tokens) public override returns(bool success){
        require(balances[msg.sender]>=tokens);
        balances[to]+=tokens; //balances[to]=balances[to]+tokens;
        balances[msg.sender]-=tokens;
        emit Transfer(msg.sender,to,tokens);
        return true;
    }

    // Authorizing the user to use the token
    function approve(address spender, uint tokens) public override returns(bool success) {
        require (balances[msg.sender] >= tokens);
        require (tokens > 0);
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view override returns(uint noOfToken) {
        return allowed[tokenOwner][spender];
    }

    function transferFrom(address from, address to, uint tokens) public override returns(bool success) {
        require(allowed[from][to] >= tokens);
        require(balances[from] >= tokens);
        balances[from] -= tokens;
        balances[to] += tokens;
        return true;
    }
   
}