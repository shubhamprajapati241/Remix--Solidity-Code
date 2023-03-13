// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransactionVariables{
    event loguint(uint);
    event logbytes(bytes);
    event logaddress(address);
    event logbyte4(bytes4);
    event logblock(bytes32);

    function showBlockVariables() public payable{
        emit logaddress(block.coinbase);
        emit loguint(block.difficulty);
        emit loguint(block.gaslimit);
        emit loguint(gasleft());
        emit loguint(tx.gasprice);
        emit loguint(block.number);
        emit loguint(block.timestamp);
        emit logbytes(msg.data);
        emit logbyte4(msg.sig);
        emit logaddress(msg.sender);
        emit loguint(msg.value);
        emit logaddress(tx.origin);
        emit logblock(blockhash(block.number));
    }
}
