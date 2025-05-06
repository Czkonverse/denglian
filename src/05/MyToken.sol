// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {BaseERC20} from "../04/BaseERC20.sol";
import {IERC20Receiver} from "./IERC20Receiver.sol";

contract MyToken is BaseERC20 {
    error MyToken__TransferWithCallbackFailed();

    function transferWithCallback(address _to, uint256 _amount) external {
        // default transfer function
        transfer(_to, _amount);

        // Call the callback function on the receiver
        if (isContract(_to)) {
            try
                IERC20Receiver(_to).tokensReceived(
                    address(this),
                    msg.sender,
                    _amount
                )
            {} catch {
                // If the call fails, revert the transaction
                revert MyToken__TransferWithCallbackFailed();
            }
        }
    }

    // Check if the receiver is a contract
    function isContract(address _addr) internal view returns (bool) {
        return _addr.code.length > 0;
    }
}
