// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IBank {
    function withdraw() external;
}

contract Admin {
    error Admin__NotOwner();

    address public i_owner;
    IBank public immutable bank;

    constructor(address bankAddress) {
        i_owner = msg.sender;
        bank = IBank(bankAddress);
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Admin__NotOwner();
        }
        _;
    }

    function adminWithdraw() public onlyOwner {
        bank.withdraw();
    }

    receive() external payable {}
}
