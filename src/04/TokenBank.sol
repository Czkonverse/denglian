// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBaseERC20 {
    function transfer(
        address _to,
        uint256 _value
    ) external returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function allowance(
        address _owner,
        address _spender
    ) external view returns (uint256 remaining);

    function balanceOf(address _owner) external view returns (uint256 balance);
}

contract TokenBank {
    error TokenBank__DepositAmountMustBeGreaterThanZero();
    error TokenBank__DepositUserNotHaveEnoughTokenToDeposit();
    error TokenBank__DepositTransferFromUserToBankFailed();
    error TokenBank__DepositAllowanceCheckFailed();
    error TokenBank__WithdrawAmountMustBeGreaterThanZero();
    error TokenBank__WithdrawAmountGreaterThanDeposit();
    error TokenBank__WithdrawTransferMoneyFailed();

    IBaseERC20 public immutable tokenERC20;

    mapping(address => uint256) public s_deposits;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor(address tokenAddress) {
        tokenERC20 = IBaseERC20(tokenAddress);
    }

    function deposit(uint256 amount) public {
        // deposit threshold, amount must be greater than 0
        if (amount <= 0) {
            revert TokenBank__DepositAmountMustBeGreaterThanZero();
        }
        // check user's token balance
        uint256 userBalanceToken = tokenERC20.balanceOf(msg.sender);
        if (userBalanceToken > amount) {
            revert TokenBank__DepositUserNotHaveEnoughTokenToDeposit();
        }
        // check the allowance of the token
        uint256 allowance = tokenERC20.allowance(msg.sender, address(this));
        if (allowance < amount) {
            revert TokenBank__DepositAllowanceCheckFailed();
        }

        // transfer the token from user to this contract
        bool success = tokenERC20.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        if (!success) {
            revert TokenBank__DepositTransferFromUserToBankFailed();
        }

        // record the amount of deposition
        s_deposits[msg.sender] += amount;

        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        // withraw threshold, amount must be greater than 0
        if (amount <= 0) {
            revert TokenBank__WithdrawAmountMustBeGreaterThanZero();
        }
        // check the amount of withdraw and deposit
        if (amount > s_deposits[msg.sender]) {
            revert TokenBank__WithdrawAmountGreaterThanDeposit();
        }
        // withdraw
        bool success = tokenERC20.transfer(msg.sender, amount);
        if (!success) {
            revert TokenBank__WithdrawTransferMoneyFailed();
        }

        // update the records of bank
        s_deposits[msg.sender] -= amount;

        emit Withdraw(msg.sender, amount);
    }
}
