// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20Receiver {
    function tokensReceived(
        address _token,
        address _from,
        uint256 _amount
    ) external;
}
