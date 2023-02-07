# Multicall_ClampAssignment

Given Problem :

To Develop a solution that utilizes the concept of multi calls to fetch prices from Uniswap. The solution should allow for the retrieval of multiple token prices in a single call, rather than multiple separate API requests. The objective is to improve efficiency by reducing the number of calls to the blockchain node. The user should be able to input an index of the desired token prices, and the solution should return the prices in a single call.

Solution: 
Have uploaded a snapshot of the final output --> in this link https://ibb.co/ccBGrTX
Had imported the IUniswapV3Factory library and the oracleLibrary for the solution and
Implemented the Multicall function and used it in retrieving multiple token prices.

Steps to run this project:
All you have to do is just run these commands to run the project.
```shell
npm install
npx hardhat compile
npx hardhat test
```

ps: Instead of creating a .env file I have placed my ethereum mainnets Https key on to the hardhat.config file


