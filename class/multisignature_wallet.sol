// SPDX-License-Identifier:MIT
pragma solidity ^0.8.8;

// A MultiSig wallet is a digital wallet that operates with multisignature addresses. 
//  multiple senders -> single receiver
contract MultiSignWallet {

    // creating the events
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransactions(
        address indexed owner,
        uint indexed txIndexed,
        address indexed to,
        uint values,
        bytes data
    );

    event ConfirmTransactions(address indexed owner, uint indexed txIndex);
    event RevokeTransactions(address indexed owner, uint indexed txIndex);
    event ExecuteTransactions(address indexed owner, uint indexed txIndex);

    address[] public owners;
    mapping(address=> bool) public isOwner;
    uint public numConfirmationsRequired; // how many confirmations are required for signing the transactions

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }

    mapping(uint=> mapping(address=>bool)) public isConfirmed; // for checking the status of a particular transactions
    // herer uint = transactions_id, address = owner, bool = approve or not approve 

    Transaction[] public transactions;  // converting the struct into array

    // declaring the modifiers
    // 1. for checking owners or only the owner can call
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not the owner");
        _;
    }

    // 2. modifier to check the existance of the transactions
    modifier txExists(uint _txIndex){
        require(_txIndex < transactions.length, "Transactions doesn't exists.");
        // transactions array lengh is 4 and searching to _txIndex = 5 => This error will shown
        _;
    }

    // 3. For check the status of executed transactions
    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "Transactions already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "Tx already confirmed");
        _;
    }

    // In constructor setting the owner and number of Confirmations Required for the transactions
    constructor(address[] memory _owners, uint _numConfirmationRequired) {
        require(_owners.length > 0, "At least one owner required");
        require(_numConfirmationRequired > 0 && _numConfirmationRequired >= owners.length, "Invalid number of required confirmations in constructor"); // _numConfirmationRequired should be greater than the 0 to less than the total owners

        for(uint i=0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");

            // for owner uniqueness
            require(!isOwner[owner], "Owner not unique");
            isOwner[owner] = true;
            owners.push(owner); 
        }
        numConfirmationsRequired = _numConfirmationRequired;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function confirmTransaction(uint _txIndex) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) 
        notConfirmed(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations +=1; // ++transaction.numConfirmations
        isConfirmed[_txIndex][msg.sender] = true;
        emit ConfirmTransactions(msg.sender, _txIndex);
    }

    function submitTransaction(address _to, uint _value, bytes memory _data) public onlyOwner {
        uint txIndex = transactions.length;
        transactions.push(
            Transaction({
                to : _to, 
                value : _value,
                data : _data, 
                executed : false,
                numConfirmations : 0
            })   
        );

        emit SubmitTransactions(msg.sender, txIndex, _to, _value, _data);
    } 

    function excecuteTransaction(uint _txIndex) public onlyOwner 
    txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];
        // require(transaction.numConfirmations >= numConfirmationsRequired, "Cannot execute tansactions");
        transaction.executed = true;
        (bool success, )  = transaction.to.call{value :transaction.value}(transaction.data);
        require(success, "Transaction Failed");
        emit ExecuteTransactions(msg.sender, _txIndex);
    }

    function revokConfirmation(uint _txIndex) public 
        onlyOwner txExists(_txIndex) notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        require(isConfirmed[_txIndex][msg.sender], "Transaction is not confirmed");
        transaction.numConfirmations -=1;
        isConfirmed[_txIndex][msg.sender] = false;
        emit RevokeTransactions(msg.sender, _txIndex);
    }


    function getOwners() public view returns(address[] memory) {
        return owners;
    }

    function getTransactionCount() public view returns(uint) {
        return transactions.length;
    }

    function getTransaction(uint _txIndex) public view 
    returns(address to, uint value, bytes memory data, bool executed, uint numConfirmations) {
        Transaction storage transaction = transactions[_txIndex]; 
        return(transaction.to, transaction.value, transaction.data, transaction.executed, transaction.numConfirmations);
    }

}


// ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2"]