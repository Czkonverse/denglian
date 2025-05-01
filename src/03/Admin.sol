// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IBank.sol";

contract Admin {
    error Admin__NotOwner();

    address public i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Admin__NotOwner();
        }
        _;
    }

    function adminWithdraw(IBank bank) public onlyOwner {
        bank.withdraw();
    }

    receive() external payable {}
}
