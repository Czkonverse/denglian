// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {TokenBankMultiToken} from "./TokenBankMultiToken.sol";
import {IERC20Receiver} from "./IERC20Receiver.sol";
import {MyToken} from "./MyToken.sol";

contract TokenBankMultiTokenV2 is TokenBankMultiToken {
    error TokenBankMultiTokenV2__TokenTransferFailed();
    error TokenBankMultiTokenV2__NotOwner();

    // owner of the contract
    address public owner;

    // whitelist token
    mapping(address => bool) public s_whitelist;

    event TokenBankMultiTokenV2Deposit(
        address indexed user,
        address indexed token,
        uint256 amount
    );
    event TokenBankMultiTokenV2AddTokenAddress(
        address indexed token,
        bool isWhitelisted
    );
    event TokenBankMultiTokenV2RemoveTokenAddress(
        address indexed token,
        bool isWhitelisted
    );

    constructor() {
        // add the token to the whitelist
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert TokenBankMultiTokenV2__NotOwner();
        }
        _;
    }

    // add token to the whitelist
    function addTokenToWhitelist(address _token) external onlyOwner {
        s_whitelist[_token] = true;

        emit TokenBankMultiTokenV2AddTokenAddress(_token, true);
    }

    // remove token from the whitelist
    function removeTokenFromWhitelist(address _token) external onlyOwner {
        s_whitelist[_token] = false;

        emit TokenBankMultiTokenV2RemoveTokenAddress(_token, false);
    }

    function tokensReceived(
        address _token,
        address _from,
        uint256 _amount
    ) external {
        // whitelist
        if (!s_whitelist[_token]) {
            revert TokenBankMultiTokenV2__TokenTransferFailed();
        }
        s_deposits[_from][_token] += _amount;
        // emit the event
        emit TokenBankMultiTokenV2Deposit(_from, _token, _amount);
    }

    // check if the token is whitelisted
    function isTokenWhitelisted(address _token) external view returns (bool) {
        return s_whitelist[_token];
    }
}
