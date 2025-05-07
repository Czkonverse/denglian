// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {TokenBankMultiToken} from "./TokenBankMultiToken.sol";
import {IERC20Receiver} from "./IERC20Receiver.sol";
import {MyToken} from "./MyToken.sol";

contract TokenBankMultiTokenV2 is TokenBankMultiToken {
    error TokenBankMultiTokenV2__TransferFailed();

    event TokenBankMultiTokenV2Deposit(
        address indexed user,
        address indexed token,
        uint256 amount
    );

    function tokensReceived(
        address _token,
        address _from,
        uint256 _amount
    ) external {
        // whitelist
        // Bank是支持多种toeken的，怎么进行token合约的确认呢？ # TODO: 如何确认token的合约地址 - 后续考虑升级白名单
        if (msg.sender != _token) {
            revert TokenBankMultiTokenV2__TransferFailed();
        }
        s_deposits[_from][_token] += _amount;
        // emit the event
        emit TokenBankMultiTokenV2Deposit(_from, _token, _amount);
    }
}
