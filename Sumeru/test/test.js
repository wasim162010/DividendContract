
var assert = require('assert');
// const Div = artifacts.require("Token");
const Div = artifacts.require("DividendContApproachOne");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

contract("Div", function (accounts) {
  var token;


  beforeEach(async () => {
    token = await Div.new()
   
  })

  
  it('has default values', async () => {

    assert.equal(await token.name(),'Test token')
    assert.equal(await token.symbol(),'TEST')
    assert.equal((await token.decimals()).toNumber(), '18')
    assert.equal( (await token.totalSupply()).toNumber(), 100000)

  })
 
  it('can be minted', async () => {
  
     await token.mint({ value: 23 })
     assert.equal(await token.balanceOf(accounts[0]), 23)
     assert.equal((await token.totalSupply()).toNumber(), 100023)
     await token.mint({ value: 50 })
     assert.equal(await token.balanceOf(accounts[0]), 73)
     assert.equal((await token.totalSupply()).toNumber(), 100073) 
     assert.equal(await token.getBalance(token.address),73) 
     await token.mint({ value: 50, from: accounts[1] })
     assert.equal(await token.balanceOf(accounts[0]), 73)
     assert.equal(await token.balanceOf(accounts[1]), 50)
     assert.equal((await token.totalSupply()).toNumber(), 100123) 
     assert.equal(await token.getBalance(token.address), 123)

  })

  it('can be burnt', async () => {

    await token.mint({ value: '23' })
    await token.mint({ value: '50', from: accounts[1] })
    assert.equal(await token.getBalance(token.address), 73)

    const preBal = await token.balanceOf(accounts[9]) //balance will be zero
    //this burning token will not have any effect as the token balance of account[9] is zero right now
    await token.burn(accounts[9])

    //should be 73 as tokens
    assert.equal(await token.getBalance(token.address), 73)
    const postBal = await token.getBalance(accounts[9])

    const diff = postBal - preBal

  })
  
  
  describe('once minted', () => {
    
    beforeEach(async () => {
      await token.mint({ value: 50 })
      await token.mint({ from: accounts[1], value: 50 })
    })
    
    it('can be transferred directly', async () => {
      
      await token.transfer(accounts[2], 1, { from: accounts[1] })
      assert.equal(await token.balanceOf(accounts[1]), 49)
      assert.equal(await token.balanceOf(accounts[2]),1)
      assert.equal((await token.totalSupply()).toNumber(), 100100) 
      assert.rejects(token.transfer(accounts[1], 2, { from: accounts[2] }))

    })
    
    it('can be transferred indirectly', async () => {

      await token.approve(accounts[1], 5)
      assert.equal(await token.allowance(accounts[0], accounts[1]) ,5) 

      await token.approve(accounts[1], 10)
      assert.equal(await token.allowance(accounts[0], accounts[1]), 10) 
      await token.transferFrom(accounts[0], accounts[2], 9, { from: accounts[1] })
      assert.equal(await token.balanceOf(accounts[0]),41)
      assert.equal(await token.balanceOf(accounts[1]), 50)
      assert.equal(await token.balanceOf(accounts[2]), 9)
      assert.equal(await token.allowance(accounts[0], accounts[1]), 1)
      await token.transferFrom(accounts[0], accounts[1], 1, { from: accounts[1] })
      assert.equal(await token.balanceOf(accounts[0]), 40)
      assert.equal(await token.balanceOf(accounts[1]), 51)
      assert.equal(await token.balanceOf(accounts[2]), 9)
      assert.equal(await token.allowance(accounts[0], accounts[1]), 0)
  
    })

  })


  describe('can generate dividend', () => {
    
    beforeEach(async () => {
      await token.mint({ value: 100 })
      await token.mint({ from: accounts[1], value: 500 })
      await token.recordDividend({ from: accounts[0], value: 100000 })
    })

  
    it('can generate dividend while minting', async () => {
    
        //using toString() to accomondate large values
      assert.equal((await token.getWithdrawableDividend(accounts[0])).toString(),'99403578528827037700')
      assert.equal((await token.getWithdrawableDividend(accounts[1])).toString(),'497017892644135188500')

      await token.transfer(accounts[2], 10, { from: accounts[0] })
          //using toString() to accomondate large values
      assert.equal((await token.getUserDividendPerToken(accounts[0])).toString(),'994035785288270377')
      assert.equal((await token.getUserDividendPerToken(accounts[2])).toString(),'994035785288270377')
      assert.equal((await token.getUserDividendPerToken(accounts[1])).toString(),'0')
      assert.equal(await token.balanceOf(accounts[2]), 10)
    
    })

    it('can withdraw dividend', async () => {
      
      await token.withdrawDividend(accounts[0])
      await token.withdrawDividend(accounts[1])
      //using toString() to accomondate large values
      assert.equal((await token.getWithdrawableDividend(accounts[0])).toString(),'0')
      assert.equal((await token.getWithdrawableDividend(accounts[1])).toString(),'0')

    })
  
  })

  describe('can gnerate/update dividend on burning token', () => {
    
    beforeEach(async () => {
      await token.mint({ from: accounts[0],value: 100 })
      await token.recordDividend({ from: accounts[0], value: 100000 })
    })

  
    it('can burn total and update dividend', async () => {
      
      await token.burn(accounts[0]);

          //using toString() to accomondate large values
      assert.equal((await token.getUserDividendPerToken(accounts[0])).toString(),'999000999000999000')
 
    
    })
  
  })

});




