// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

contract MyWallet {
    error InsufficientBalance(uint available, uint required);

    address public owner;
    uint public restBalance;

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

    receive() external payable {
        restBalance += msg.value;
     }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function setAllowance(address _to, uint _amount) public isOwner{
        if (restBalance < _amount) {
            revert InsufficientBalance({
                available: restBalance,
                required: _amount
            });
        }

        restBalance -= _amount;

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