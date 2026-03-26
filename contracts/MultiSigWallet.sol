// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract MultiSigWallet {
    struct Transaction {
        address to;
        uint value;
        bool executed;
        uint numConfirmations;
    }
    address[] public owners;
    mapping(address => bool) isOwner;
    Transaction[] public transactions;
    uint public required;
    mapping(uint => mapping(address => bool)) public isConfirmed; // txId => owner => confirmed or not

    modifier onlyOwner {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    modifier txExists(uint _txnId) {
        require(_txnId < transactions.length, "Tx does not exists");
        _;
    }
    modifier notConfirmed(uint _txnId) {
        require(!isConfirmed[_txnId][msg.sender], "Already confirmed");
        _;
    }

    modifier notExecuted(uint _txnId) {
        require(!transactions[_txnId].executed, "Already executed");
        _;
    }

    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0, "Owners required");
        require(_required > 0 && _required <= _owners.length, "Invalid required");
        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Duplicate owner");

            owners.push(owner);
            isOwner[owner] = true;
        }

        required = _required;
    }

    function submitTransaction(address _to, uint _value) public returns (uint txnId) {
        require(_to != address(0), "Invalid receiptinet");
        require(_value > 0, "Invalid value");

        txnId = transactions.length;
        transactions.push(Transaction({
            to: _to,
            value: _value,
            executed: false,
            numConfirmations: 0
        }));
    }

    function confirmTransaction(uint _txnId) 
        public onlyOwner txExists(_txnId) notConfirmed(_txnId)
    {    
        transactions[_txnId].numConfirmations++;
        isConfirmed[_txnId][msg.sender] = true;
    }

    function executeTransaction(uint _txnId) 
        public onlyOwner txExists(_txnId) notExecuted(_txnId)
    {
        Transaction storage txn = transactions[_txnId];
        require(txn.numConfirmations >= required, "Not enough confirmations");
        
        txn.executed = true;

        (bool success, ) = payable(txn.to).call{value: txn.value}("");
        require(success, "Tx failed");
    }

    receive() external payable {}
}