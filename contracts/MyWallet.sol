// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

contract MyWallet {
    error InsufficientBalance(uint available, uint required);

    address public owner;
    uint public balances;

    struct Allowance {
        uint amount;
        uint updated;
    }

    mapping (address=>Allowance) public allowances;

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner, aborting...");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    receive() external payable { }

    function deposit() public payable isOwner{
        balances += msg.value;
    }

    function setAllowance(address _to, uint _amount) public isOwner{
        if (balances < _amount) {
            revert InsufficientBalance({
                available: balances,
                required: _amount
            });
        }

        balances -= _amount;

        allowances[_to] = Allowance({
            updated: block.timestamp,
            amount: allowances[_to].amount + _amount
        });
    }

    function withdraw(address payable _to, uint _amount) public isOwner{
        require(allowances[_to].amount >= _amount, "Allowance is not enough");

        allowances[_to].amount -= _amount;
        allowances[_to].updated = block.timestamp;

        _to.transfer(_amount);
    }

}