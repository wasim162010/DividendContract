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

1. Initial token supply
<img width="686" alt="Pasted Graphic" src="https://user-images.githubusercontent.com/47940538/162893638-335a6bd4-6374-4350-b7c7-a018b0f5d668.png">

2. Minting 100 , address : 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4

<img width="967" alt="Pasted Graphic 1" src="https://user-images.githubusercontent.com/47940538/162893698-38a71830-e3cf-435c-baa4-68d863c5a8eb.png">
<img width="743" alt="Pasted Graphic 2" src="https://user-images.githubusercontent.com/47940538/162893730-fe31ec71-2e8f-45fd-b189-ef9d55bb0afc.png">


3. Minting 500, address : 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
<img width="960" alt="Pasted Graphic 3" src="https://user-images.githubusercontent.com/47940538/162893745-0cc7c481-c91c-4ef3-8261-e8f3683b96cf.png">
<img width="766" alt="Pasted Graphic 4" src="https://user-images.githubusercontent.com/47940538/162893758-07e7ffe4-7a9e-4acf-99b9-eb1ee51a9ad0.png">

4. Calling recordDividend by passing 100000 twice
<img width="972" alt="Pasted Graphic 5" src="https://user-images.githubusercontent.com/47940538/162893768-c52c2f13-1a18-4623-ab07-6982e473841f.png">
<img width="954" alt="Pasted Graphic 6" src="https://user-images.githubusercontent.com/47940538/162893781-6566a06f-9df7-4f85-aba1-cf6866aeadc9.png">

DividendperToken : 994035785288270377
<img width="951" alt="Pasted Graphic 7" src="https://user-images.githubusercontent.com/47940538/162893795-3ba77a11-4bf9-425d-8ab3-70c55f5fc89d.png">
Transferring 10 to account 2 [0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db]  from account 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
<img width="744" alt="Pasted Graphic 8" src="https://user-images.githubusercontent.com/47940538/162893806-edf21e5f-66dd-4776-8491-2d20a405f0f0.png">
<img width="913" alt="Pasted Graphic 9" src="https://user-images.githubusercontent.com/47940538/162893864-fcca39ed-dd2e-4622-a034-c5cb8f282bcb.png">

￼
Checking ‘getWithdrawableDividend’ value post transfer,

<img width="968" alt="Pasted Graphic 15" src="https://user-images.githubusercontent.com/47940538/162894057-0ac82eff-d784-499f-a8f9-f32c2b81f658.png">

￼
Checking value of ‘getxDividendPerToken’
<img width="749" alt="Pasted Graphic 12" src="https://user-images.githubusercontent.com/47940538/162894076-e537efa2-716c-443b-958b-a56ad8e91cf3.png">

<img width="846" alt="Pasted Graphic 13" src="https://user-images.githubusercontent.com/47940538/162894087-4579fd24-d8c6-4966-a7e7-149d17d1b61d.png">

Checking ‘getWithdrawableDividend’ value post transfer,

<img width="944" alt="Pasted Graphic 16" src="https://user-images.githubusercontent.com/47940538/162894106-d1b05c93-60bd-40d2-882a-6d1b55d12eb6.png">

<img width="773" alt="Pasted Graphic 17" src="https://user-images.githubusercontent.com/47940538/162894115-b3c148b2-9af7-492f-9496-b9ee08274980.png">

<img width="944" alt="Pasted Graphic 18" src="https://user-images.githubusercontent.com/47940538/162894125-6a6360ac-6130-4c27-8aa9-334364421ab9.png">

<img width="761" alt="Pasted Graphic 20" src="https://user-images.githubusercontent.com/47940538/162894143-545657eb-81eb-4e78-9b05-3b6300376442.png">



Transferring the withdrawal dividend to the user account

<img width="950" alt="Pasted Graphic 21" src="https://user-images.githubusercontent.com/47940538/162894172-9c09e259-63fa-46e4-ab3b-6e42c1051f32.png">
<img width="782" alt="Pasted Graphic 22" src="https://user-images.githubusercontent.com/47940538/162894192-fd8c1f66-7e2d-4efe-8099-29bbbb22d31b.png">


Verifying  ‘getWithdrawableDividend’ value post withdrawal

<img width="747" alt="Pasted Graphic 23" src="https://user-images.githubusercontent.com/47940538/162894214-d8bac9f3-6172-430a-8844-f77373cc7fec.png">


<img width="938" alt="Pasted Graphic 24" src="https://user-images.githubusercontent.com/47940538/162894225-e93f8482-4e97-4bcf-a7d5-a51d8e0c6b11.png">


