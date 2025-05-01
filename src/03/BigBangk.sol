// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IBank.sol";

contract Bank is IBank {
    error Bank__SendZeroMoney();
    error Bank__NotOwner();
    error Bank__WithdrawMoneyFailed();

    address public i_owner;
    uint256 public constant LEAST_MONEY = 0 ether;

    uint private s_recordsCount;
    uint256 private s_mimimumDeposit = 0;
    mapping(address payer => uint money) private s_records;
    address[] public s_top3Users;

    event BankDeposit(address indexed payer);
    event Top3Updated(address[] top3Users);

    constructor() {
        i_owner = msg.sender;
    }

    function deposit() public payable virtual {
        if (msg.value <= LEAST_MONEY) {
            revert Bank__SendZeroMoney();
        }

        s_records[msg.sender] += msg.value;
        emit BankDeposit(msg.sender);

        updateTop3(msg.sender);
    }

    function updateTop3(address user) public {
        for (uint8 i = 0; i < s_top3Users.length; i++) {
            if (s_top3Users[i] == user) return;
        }

        if (s_top3Users.length < 3) {
            s_top3Users.push(user);
        } else {
            address[4] memory candidates;

            for (uint8 i = 0; i < 3; i++) {
                candidates[i] = s_top3Users[i];
            }
            candidates[3] = user;

            for (uint8 i = 0; i < 4; i++) {
                for (uint8 j = i + 1; j < 4; j++) {
                    if (s_records[candidates[j]] > s_records[candidates[i]]) {
                        (candidates[i], candidates[j]) = (
                            candidates[j],
                            candidates[i]
                        );
                    }
                }
            }

            for (uint8 i = 0; i < 3; i++) {
                s_top3Users[i] = candidates[i];
            }
        }

        emit Top3Updated(s_top3Users);
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert Bank__NotOwner();
        _;
    }

    function withdraw() public virtual onlyOwner {
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!callSuccess) {
            revert Bank__WithdrawMoneyFailed();
        }
    }
}

contract BigBank is Bank {
    error BigBank__TooSmallDeposit();
    error BigBank__NotAdmin();

    uint256 public constant LEAST_DEPOSIT_MONEY = 0.001 ether;
    address public i_admin;

    constructor() {
        i_admin = msg.sender;
    }

    // 最小存款检查 0.001 ether
    modifier minDeposit() {
        if (msg.value <= LEAST_DEPOSIT_MONEY) {
            revert BigBank__TooSmallDeposit();
        }
        _;
    }

    // Admin检查
    modifier onlyAdmin() {
        if (msg.sender != i_admin) revert BigBank__NotAdmin();
        _;
    }

    function deposit() public payable override minDeposit {
        super.deposit();
    }

    function transferAdmin(address newAdmin) public onlyAdmin {
        i_admin = newAdmin;
    }

    function withdraw() public override onlyOwner {
        super.withdraw();
    }
}
