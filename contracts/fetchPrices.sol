//SPDX-License-Identifier: MIT
pragma solidity ^0.7.6; 
pragma abicoder v2;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

contract fetchPrices {

    address[] public assets;       
    address[] public assetPools;  
    address public UniswapFactory   = 0x1F98431c8aD98523631AE4a59f267346ea31F984; //Uniswapv3FactoryAddress
    address public baseToken        = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;   // WETH contract address
    uint24  public fee               = 3000;                                         // Fee


    constructor(address _baseToken, uint24 _fee) {
        baseToken = _baseToken; 
        fee = _fee;             
    }

    function getAssets() external view returns (address[] memory) {
        return assets;
    }

    /**
     * @dev Add a token to the index
     * Fetches the uniswap liquidity pool address for 
     * the token and base token, reverts if the pool doesn't exist
     * @param _token address of the token to be added
     */
    function addTokenToIndex(address _token) external {
        address tokenpool = IUniswapV3Factory(UniswapFactory).getPool(
            _token,
            baseToken,
            fee
        );
        require(tokenpool != address(0), "The pool does not exist");
        assets.push(_token);
        assetPools.push(tokenpool);
    }

    /**
     * @dev This returns the price of a single token at a particular index
     * and returns the price of the token
     *  @notice Calculates time-weighted means of tick and liquidity for a given Uniswap V3 pool
     */
    function getQuoteOfSingleToken(uint _tokenIndex) external view returns (uint) {
        (int24 tick, ) = OracleLibrary.consult(assetPools[_tokenIndex], 10);
        uint quoteAmount = OracleLibrary.getQuoteAtTick(
            tick,
            1 ether,
            assets[_tokenIndex],
            baseToken
        );
        return quoteAmount;
    }

    /**
     * @dev Generates the calldata for a single token price at a particular index
     * @param _tokenIndex index of the token
     * @return bytes calldata for the token price function
     */
    function getCallData(uint _tokenIndex) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(this.getQuoteOfSingleToken.selector, _tokenIndex);
    }

    /**
     * @dev Executes multiple static calls in a single transaction
     * @param targets array of addresses to call
     * @param data array of calldata for each call
     * @return bytes[] array of results
     */
    function multiCall(
        address[] memory targets,
        bytes[] memory data
    ) internal view returns (bytes[] memory) {
        require(targets.length == data.length, "target length != data length");

        bytes[] memory results = new bytes[](data.length);

        for (uint i; i < targets.length; i++) {
            (bool success, bytes memory result) = targets[i].staticcall(data[i]);
            require(success, "call failed");
            results[i] = result;
        }

        return results;
    }

    /**
     * @dev Returns the price of all the tokens in the index
     * and uses the multicall function
     * for @return bytes[] array of results
     */
    function getAllPrices() external view returns (bytes[] memory) {
        address[] memory targets = new address[](assets.length);
        bytes[] memory data = new bytes[](assets.length);

        for (uint i; i < assets.length; i++) {
            targets[i] = address(this);
            data[i] = getCallData(i);
        }

        return multiCall(targets, data);
    }
}