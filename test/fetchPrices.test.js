const { expect } = require("chai")
const { ethers } = require("hardhat");
const { int } = require("hardhat/internal/core/params/argumentTypes");

const TOKENS = [
    "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", // Ether Token
    "0x4Fabb145d64652a948d72533023f6E7A623C7C53", // BUSD Token
    "0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0", //MATIC Token
    "0x4d224452801ACEd8B2F0aebE155379bb5D594381", // APE Token
    "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984", // UNI Token
    "0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9", // AAVE token
    
];
const BASE_TOKEN = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"; // WETH
const FEE = 3000

beforeEach( async () => {
    accounts = await ethers.getSigners();
    const contractFactory = await ethers.getContractFactory("fetchPrices");
    contract = await contractFactory.deploy(
        BASE_TOKEN,
        FEE
    );
    await contract.deployed();
    for(let i=0; i<TOKENS.length; i++){
        await contract.addTokenToIndex(TOKENS[i]);
    }

});

describe("fetchPrices", () => {

    it("add tokens", async () => {
        const tokens = await contract.getAssets();
        expect(tokens).to.deep.equal(TOKENS);
    });

    it("get prices using multicall", async () => {
        const prices = await contract.getAllPrices();
        for(let i=0; i<prices.length; i++){
            console.log(`The token of address (${TOKENS[i]}) price is : ${parseInt(prices[i], 16)} WETH as the base Token`);
        }
    });
})