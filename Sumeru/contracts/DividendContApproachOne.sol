
pragma solidity 0.8.4;

import "./IERC20.sol";
import "./IMintableToken.sol";
import "./IDividends.sol";
// import "./SafeMath.sol";


library SafeMath {
   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }


    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

  
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

  
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract DividendContApproachOne is IERC20, IMintableToken, IDividends {
 
  using SafeMath for uint256;

    uint256 public decimals = 18;
    string public name = "Test token";
    string public symbol = "TEST";

    // to take care of the rounding off error
    uint256 MULTIPLIER = 1000000000000000000;
    address owner;
    uint256 private totalSupply_;
    mapping (address => mapping (address => uint256)) internal allowed;
    mapping(address => uint256) internal balance;

    //Eth share of each token in gwei
    uint256 public dividendPerToken;
    //user share of dividend
    mapping(address => uint256) userDividendPerToken;
    //Amount that should have been withdrawn
    mapping (address => uint256) amt;//credit;

  
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier updateDividend(address addr) {

        uint256 recipientBalance = balance[addr];
        if(recipientBalance != 0) {
            uint256 amount = ( (dividendPerToken - userDividendPerToken[addr]) * recipientBalance / MULTIPLIER);
            amt[addr] += amount;
        }
        userDividendPerToken[addr] = dividendPerToken;
        _;
    }
    constructor() public {

        totalSupply_ = 100000;
        owner = msg.sender;
    }

 
 function transfer(address _to, uint256 _value) updateDividend(msg.sender) updateDividend(_to)  external override returns(bool) {
        require(msg.sender != _to);
        require(_to != address(0));
        require(_value <= balance[msg.sender]);
        balance[msg.sender]= (balance[msg.sender]).sub(_value);
        balance[_to] = (balance[_to]).add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
  }



   function approve(address _spender, uint256 _value) external override returns (bool) {
        (allowed[msg.sender][_spender]) = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    updateDividend(_from)
    updateDividend(_to)
    external
    override
    returns (bool)
  {
      require(_to != _from);
      require(_to != address(0));
      require(_value <= balance[_from]);
      require(_value <= (allowed[_from][msg.sender]));

      balance[_from] = (balance[_from]).sub(_value);
      balance[_to] = (balance[_to]).add(_value);
      (allowed[_from][msg.sender]) = (allowed[_from][msg.sender]).sub(_value);
      emit Transfer(_from, _to, _value);
      return true;
  }



function getUserDividendPerToken(address addr) public view returns(uint256) {
        return userDividendPerToken[addr];
    }

 function getAmt(address addr) public view returns(uint256) {
        return amt[addr];
    }


 function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }


  function allowance(
    address _owner,
    address _spender
   )
    public
    view override
    returns (uint256)
  {
        return (allowed[_owner][_spender]);
  }

   function balanceOf(address _owner) external view override returns(uint256) {
        return balance[_owner];
  }

  function getBalance(address _addr) external view returns(uint256) {
        return address(_addr).balance;
    }
  // IMintableToken

  function mint() updateDividend(msg.sender) external payable override {
        require(msg.value != 0,"Ether passed should be non zero");
        _mint(msg.sender, msg.value);
  }



   function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        totalSupply_ = totalSupply_.add(amount);
        balance[account] = balance[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

   function burn(address _addr) updateDividend(msg.sender) external override{
        _burn(_addr, balance[_addr]);
    }



  // IDividends

  function recordDividend() external onlyOwner payable override {

        require(totalSupply() != 0, "No tokens minted");
        dividendPerToken += msg.value * MULTIPLIER / totalSupply();

  }


   function getWithdrawableDividend(address payee) external  view override returns (uint256) {
   
        uint256 holderBalance = balance[payee];
        require(holderBalance != 0, "DToken: caller possess no shares");
        uint256 amount = ( (dividendPerToken - userDividendPerToken[payee]) * holderBalance );
        amount += amt[payee];
        return amount;
  }

  function withdrawDividend(address payable payee) external override {
        
        uint256 holderBalance = balance[payee];
        require(holderBalance != 0, "Balance is nil");

        uint256 amount = ( (dividendPerToken - userDividendPerToken[payee]) * holderBalance );
        amount += amt[payee];
        amt[payee] = 0;
        userDividendPerToken[payee] = dividendPerToken;

       (bool success, ) = payable(payee).call{value: amount}("");        

    }

function _burn(address account, uint256 amount) internal {
       
        require(account != address(0), "ERC20: burn from the zero address");
        totalSupply_ = totalSupply_.sub(amount);
        balance[account] = balance[account].sub(amount);
        emit Transfer(account, address(0), amount);

    }


//Events
   event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );
    
    event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
    );
}
