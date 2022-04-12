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

Screenshots of dividend calculations:
