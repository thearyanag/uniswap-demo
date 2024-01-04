// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract Swap {
    ISwapRouter public immutable swapRouter;

    uint24 public constant poolFee = 3000;

    constructor(ISwapRouter _swapRouter) {
        swapRouter = _swapRouter;
    }

    /// @notice Swap exact amount of tokenIn for as much tokenOut as possible, along the current price curve
    /// @param tokenIn The token being sold
    /// @param tokenOut The token being bought
    /// @param amountIn The exact amount of tokenIn being sold
    /// @param amountOutMinimum The minimum amount of tokenOut to buy, which sets the maximum slippage of the swap
    /// @return amountOut The amount of tokenOut bought
    function swapExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMinimum,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountOut) {
        // Transfer tokenIn to this contract
        TransferHelper.safeTransferFrom(
            tokenIn,
            msg.sender,
            address(this),
            amountIn
        );

        // Approve the router to spend tokenIn
        // TODO : implement a check to see if the tokenIn is approved or not
        TransferHelper.safeApprove(tokenIn, address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                // In prod, price will be set from an oracle
                amountOutMinimum: amountOutMinimum,
                // In prod, sqrtPriceLimitX96 will be set from an oracle which gives an optimal value
                sqrtPriceLimitX96: sqrtPriceLimitX96
            });

        amountOut = swapRouter.exactInputSingle(params);
        TransferHelper.safeApprove(tokenIn, address(swapRouter), 0);
    }

    /// @notice Swap as little tokenIn as possible for exact amount of tokenOut, along the current price curve
    /// @param tokenIn The token being sold
    /// @param tokenOut The token being bought
    /// @param amountOut The exact amount of tokenOut to buy
    /// @param amountInMaximum The maximum amount of tokenIn to sell, which sets the maximum slippage of the swap
    /// @return amountIn The amount of tokenIn sold
    function swapExactOutputSingle(
        address tokenIn,
        address tokenOut,
        uint256 amountOut,
        uint256 amountInMaximum,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountIn) {
        // Transfer tokenIn to this contract
        TransferHelper.safeTransferFrom(
            tokenIn,
            msg.sender,
            address(this),
            amountInMaximum
        );

        // Approve the router to spend tokenIn
        // TODO : implement a check to see if the tokenIn is approved or not
        TransferHelper.safeApprove(
            tokenIn,
            address(swapRouter),
            amountInMaximum
        );

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter
            .ExactOutputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOut,
                // In prod, price will be set from an oracle
                amountInMaximum: amountInMaximum,
                // In prod, sqrtPriceLimitX96 will be set from an oracle which gives an optimal value
                sqrtPriceLimitX96: sqrtPriceLimitX96
            });

        amountIn = swapRouter.exactOutputSingle(params);

        // Transfer any leftover tokenIn back to msg.sender
        if (amountIn < amountInMaximum) {
            TransferHelper.safeTransfer(
                tokenIn,
                msg.sender,
                amountInMaximum - amountIn
            );
            // revoke approval
            TransferHelper.safeApprove(tokenIn, address(swapRouter), 0);
        }
    }
}
