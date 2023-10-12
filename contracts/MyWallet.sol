// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

contract MyWallet {
    error InsufficientBalance(uint available, uint required);
    error ExceedWithDrawLimit(uint required);

    address public owner;
    uint public restBalance;

    uint public constant withdrawLimit = 3;

    mapping (address => WithdrawTimes) public withdrawTimes;

    struct Allowance {
        uint amount;
        uint updated;
    }

    struct WithdrawTimes {
        uint times;
        uint startAt;
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

        uint timecheck = block.timestamp - 1 days;

        if (timecheck > withdrawTimes[_to].startAt) {
            withdrawTimes[_to].startAt = block.timestamp;
            withdrawTimes[_to].times = 1;
        } else {
            withdrawTimes[_to].times += 1;
        }

        if (withdrawTimes[_to].times > withdrawLimit) {
            revert ExceedWithDrawLimit({
                required: withdrawTimes[_to].times
            });
        }

        allowances[_to].amount -= _amount;
        allowances[_to].updated = block.timestamp;

        _to.transfer(_amount);
    }

}