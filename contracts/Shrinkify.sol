// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract Shrinkify is ERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;

    uint256 public burnFee = 2;
    uint256 public liqFee = 8;

    uint256 private minTokensToAddLiquidity = SafeMath.mul(500000, 10**uint(decimals()));
    uint256 public maxTxAmount = SafeMath.mul(5000000, 10**uint(decimals()));

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool inSwapAndLiquify;

    constructor() ERC20("The Purge", "PURGE") {

        _mint(msg.sender, 1000000000 * 10**uint(decimals())); //mint adds minted value to _totalSupply

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xbdd4e5660839a088573191A9889A262c0Efc0983);

        //creates liquidity pair
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

    }

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }

    function calculatePercentage(uint256 amount, uint256 percentage) private pure returns (uint256){

        return amount.div(100).mul(percentage);

    }

    //Overrides _transfer method to add burn and liq functionality
    function _transfer(address sender, address recipient, uint256 amount) internal virtual override{

        require(amount <= maxTxAmount, "ERC20: transfer amount exceeds limit");

        uint256 tokenBalance = balanceOf(address(this));

        if(tokenBalance >= maxTxAmount){

            tokenBalance = maxTxAmount; //only consider maxtxamount if balance>max

        }

        if(tokenBalance >= minTokensToAddLiquidity && sender != uniswapV2Pair && !inSwapAndLiquify) { //is balance > min && tx is not from univ2pair

            swapAndLiquify(tokenBalance); //adds liquidity if the token balance of this contract is enough (>=minTokensToAddLiquidity)

        }

        uint256 tokensToBurn = calculatePercentage(amount, burnFee);
        uint256 tokensToLock = calculatePercentage(amount, liqFee);
        uint256 tokensToTransfer = amount.sub(tokensToBurn).sub(tokensToLock);

        _burn(sender, tokensToBurn); //removes tokensToBurn from _totalSupply and burns them

        super._transfer(sender, address(this), tokensToLock); //adds tokensToLock to contract balance for liquidity
        super._transfer(sender, recipient, tokensToTransfer); //transfer what remains

    }

    modifier swapLock {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function swapAndLiquify(uint256 tokenBalance) private swapLock{

        uint256 half = tokenBalance.div(2);
        uint256 otherHalf = tokenBalance.sub(half);

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half);

        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);

    }

    function swapTokensForEth(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);

    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        //approve the transfer
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        //add liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(address(this), tokenAmount, 0, 0, owner(), block.timestamp); //owner is invalid address when ownership renounced, so LP tokens are locked

    }

   receive() external payable {}

}
