// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

contract MyBoolean {
    bool MyBool;

    constructor() payable  {}

    function setMyBool(bool _MyBool) public payable  {
        MyBool = _MyBool;
    }

    function sendto(address payable _to) public payable {
        _to.transfer(msg.value);
    }
}