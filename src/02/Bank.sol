// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Bank {
    error Bank__SendZeroMoney();
    error Bank__NotOwner();
    error Bank__WithdrawMoneyFailed();

    address public immutable i_owner;
    uint256 private constant ZERO_MONEY = 0;

    uint private s_recordsCount;
    uint256 private s_mimimumDeposit = 0;
    mapping(address payer => uint money) private s_records;
    address[] public s_top3Users;

    event BankDeposit(address indexed payer);
    event Top3Updated(address[] top3Users);

    constructor() {
        // onwer
        i_owner = msg.sender;
    }

    function deposit() public payable {
        // deposit money > 0
        if (msg.value <= ZERO_MONEY) {
            revert Bank__SendZeroMoney();
        }

        s_records[msg.sender] += msg.value;
        emit BankDeposit(msg.sender);

        updateTop3(msg.sender);
    }

    function updateTop3(address user) public {
        // check if user is already in top3
        for (uint8 i = 0; i < s_top3Users.length; i++) {
            if (s_top3Users[i] == user) {
                return;
            }
        }

        if (s_top3Users.length < 3) {
            s_top3Users.push(user);

            emit Top3Updated(s_top3Users);
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

            // update top3
            for (uint8 i = 0; i < 3; i++) {
                s_top3Users[i] = candidates[i];
            }
        }
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Bank__NotOwner();
        }
        _;
    }

    function withdraw() public onlyOwner {
        // Withdraw logic
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!callSuccess) {
            revert Bank__WithdrawMoneyFailed();
        }
    }
}
