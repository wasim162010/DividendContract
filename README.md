# SumeruDividendContract

#I have created 2 smart contracts, containing approaches on how to store and calculate the dividends.

As a part of my approach, I have created 2 smart contracts, namely ‘DividendContApproachOne.sol’ and ‘DividendContApproachTwo.sol’ . 

# These two smart contract differ in the way the data related to Dividend is saved and when and how the logic to calculate the dividend is called.

# I went ahead and opted for for ‘DividendContApproachOne.sol’ and wrote test cased focusing it in mind.

# I have written my own test cases when it comes to testing Dividend logic, and in it focused on calculating dividend during token balance change due to various operations and also to transfer it to the user.
 
			DividendContApproachOne.sol : -					
# IDividend function implementations

Below implementation modify the value of dividendPerToken on receiving ethers.
  function recordDividend() external payable override {

        require(totalSupply() != 0, "No tokens minted");
        dividendPerToken += msg.value * MULTIPLIER / totalSupply();

  }

This function calculates and return the dividend that user can transfer to the account
  function getWithdrawableDividend(address payee) external  view override returns (uint256) {
   
        uint256 holderBalance = balance[payee];
        require(holderBalance != 0, "DToken: caller possess no shares");
        uint256 amount = ( (dividendPerToken - userDividendPerToken[payee]) * holderBalance );
        amount += amt[payee];
        return amount;
  }

It lets user to transfer the dividend ,
function withdrawDividend(address payable payee) external override {
        
        uint256 holderBalance = balance[payee];
        require(holderBalance != 0, “Balance is nil");

        uint256 amount = ( (dividendPerToken - userDividendPerToken[payee]) * holderBalance );
        amount += amt[payee];
        amt[payee] = 0;
        userDividendPerToken[payee] = dividendPerToken;

       (bool success, ) = payable(payee).call{value: amount}("");        

    }

# IMintableToken.sol function implementations :

 function mint() updateDividend(msg.sender) external payable override {
        require(msg.value != 0,"Ether passed should be non zero");
        _mint(msg.sender, msg.value);
  }


function burn(address _addr) updateDividend(msg.sender) external override{
        _burn(_addr, balance[_addr]);
    }

function _burn(address account, uint256 amount) internal {
       
        require(account != address(0), "ERC20: burn from the zero address");
        totalSupply_ = totalSupply_.sub(amount);
        emit Transfer(account, address(0), amount);

    }

# modifier updateDividend(address addr)

This modifiers purpose is to calculate/update the dividend owed by an account. And this modified is mentioned in all the functions which changes the account balance.
   modifier updateDividend(address addr) {

        uint256 recipientBalance = balance[addr];
        if(recipientBalance != 0) {
            uint256 amount = ( (dividendPerToken - userDividendPerToken[addr]) * recipientBalance / MULTIPLIER);
            amt[addr] += amount;
        }
        userDividendPerToken[addr] = dividendPerToken;
        _;
    }

—

Few Screenshots :


1. Initial token supply
<img width="686" alt="Pasted Graphic" src="https://user-images.githubusercontent.com/47940538/162895293-7dde9795-f691-4992-84aa-4fd1b18091db.png">

2. Minting 100 , address : 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
 <img width="967" alt="Pasted Graphic 1" src="https://user-images.githubusercontent.com/47940538/162895343-6b27501c-ba4a-45db-8005-74486409f02b.png">
 <img width="743" alt="Pasted Graphic 2" src="https://user-images.githubusercontent.com/47940538/162895371-bb4827ec-25d7-43a6-92a7-f7bbc26363a1.png">

3. Minting 500, address : 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
<img width="960" alt="Pasted Graphic 3" src="https://user-images.githubusercontent.com/47940538/162895420-ec3da323-cc97-4170-ab24-7a3da0e237df.png">

<img width="766" alt="Pasted Graphic 4" src="https://user-images.githubusercontent.com/47940538/162895432-d9c2ea6f-9e85-4933-aac9-9ab58ced384e.png">

4. Calling recordDividend by passing 100000 twice
 <img width="972" alt="Pasted Graphic 5" src="https://user-images.githubusercontent.com/47940538/162895468-5e80f7a0-c813-4f44-8875-aaf7737c1155.png">
 <img width="954" alt="Pasted Graphic 6" src="https://user-images.githubusercontent.com/47940538/162895514-0dd9a670-2341-466d-b00c-ea368b298f8f.png">

5. checking DividendperToken and userdividend per token
<img width="1156" alt="image" src="https://user-images.githubusercontent.com/47940538/162898510-a4ca6faf-eb99-4eab-b75c-f42ebfe70206.png">
<img width="1013" alt="image" src="https://user-images.githubusercontent.com/47940538/162898608-b3185d9a-885c-496c-a217-26b1cb5a717f.png">



8. Transferring 10 to '0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db' from '0x5B38Da6a701c568545dCfcB03FcB875f56beddC4'
<img width="1012" alt="image" src="https://user-images.githubusercontent.com/47940538/162898775-06862d0b-e4cf-4ee6-9c75-19927d1c8952.png">

9. Checking withdrawabale dividend and user dividend per token
<img width="687" alt="image" src="https://user-images.githubusercontent.com/47940538/162899101-004e23e2-242b-4fc3-906f-066b1ecca85c.png">

10. Withdrawing the withdrawable dividend 
<img width="669" alt="image" src="https://user-images.githubusercontent.com/47940538/162899257-0bc2c26c-692a-411d-88d5-98e9f519204a.png">
<img width="1004" alt="image" src="https://user-images.githubusercontent.com/47940538/162899287-dac45d65-80c6-41eb-8b6c-9b45b9f0bf80.png">

11. Verifying withdrawable dividend post withdraw
<img width="675" alt="image" src="https://user-images.githubusercontent.com/47940538/162899589-cf6bc6fc-2a37-4ea7-974e-d60ad6670b12.png">

Testing screenshots of the console log :
<img width="495" alt="image" src="https://user-images.githubusercontent.com/47940538/162899862-327d9ce2-5f1d-4c98-a17b-3020c64149f9.png">








 

