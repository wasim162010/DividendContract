
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

contract DividendContApproachTwo is IERC20, IMintableToken, IDividends {
 
    using SafeMath for uint256;

    uint256 public decimals = 18;
    string public name = "Test token";
    string public symbol = "TEST";

    uint256 totalDividendPoints = 0;
    uint256 unclaimedDividends = 0;
    uint256 pointMultiplier = 1000000000000000000;
    address owner;
 
     uint256 private totalSupply_;
    mapping (address => mapping (address => account)) internal allowed;
    struct account{
         uint256 balance;
         uint256 lastDividend;
     }
    mapping(address => account) public balances;

    modifier updateDividend(address investor) {
        uint256 owing = dividendsOwing(investor);
        if(owing > 0) {
            unclaimedDividends = unclaimedDividends.sub(owing);
            balances[investor].balance = balances[investor].balance.add(owing);
            balances[investor].lastDividend = totalDividendPoints;
            }
        _;
    }
    
 
    
    modifier onlyOwner() {
        require(msg.sender == owner);
    _;
    }

    constructor() public {

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
        return (allowed[_owner][_spender]).balance;
  }

 function transfer(address _to, uint256 _value) updateDividend(msg.sender) updateDividend(_to) external override returns(bool) {
        require(msg.sender != _to);
        require(_to != address(0));
        require(_value <= balances[msg.sender].balance);
        balances[msg.sender].balance = (balances[msg.sender].balance).sub(_value);
        balances[_to].balance = (balances[_to].balance).add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
  }

function balanceOf(address _owner) external view override returns(uint256) {
        return balances[_owner].balance;
  }

   function approve(address _spender, uint256 _value) external override returns (bool) {
        (allowed[msg.sender][_spender]).balance = _value;
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
      require(_value <= balances[_from].balance);
      require(_value <= (allowed[_from][msg.sender]).balance);

      balances[_from].balance = (balances[_from].balance).sub(_value);
      balances[_to].balance = (balances[_to].balance).add(_value);
      (allowed[_from][msg.sender]).balance = (allowed[_from][msg.sender]).balance.sub(_value);
      emit Transfer(_from, _to, _value);
      return true;
  }

  // IMintableToken

  function mint() external payable override {
        require(msg.value != 0,"Ether passed should be non zero");
        _mint(msg.sender, msg.value);
  }

  function getBalance(address _addr) external view returns(uint256) {
        return address(_addr).balance;
    }

  function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        totalSupply_ = totalSupply_.add(amount);
        balances[account].balance = balances[account].balance.add(amount);
        emit Transfer(address(0), account, amount);
    }

  function burn(address _addr) public override{

        _burn(_addr, balances[_addr].balance);
    }

   
   function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        totalSupply_ = totalSupply_.sub(amount);
        balances[account].balance = balances[account].balance.sub(amount);
        emit Transfer(account, address(0), amount);
    }

  // IDividends

  function recordDividend() external payable override {

     totalDividendPoints = totalDividendPoints.add((msg.value.mul(pointMultiplier)).div(totalSupply_));
     totalSupply_ = totalSupply_.add(msg.value);
     unclaimedDividends =  unclaimedDividends.add(msg.value);

  }

  function getWithdrawableDividend(address payee) external view override returns (uint256) {
      
        uint256 newDividendPoints = totalDividendPoints.sub(balances[payee].lastDividend);
        return (balances[payee].balance.mul(newDividendPoints)).div(pointMultiplier);
  }

  function withdrawDividend(address payable dest) external override {
       uint256 newDividendPoints = totalDividendPoints.sub(balances[dest].lastDividend);
       uint tobeTransferred  = (balances[dest].balance.mul(newDividendPoints)).div(pointMultiplier);
       unclaimedDividends= unclaimedDividends.sub(tobeTransferred);
       (bool success, ) = payable(dest).call{value: tobeTransferred}(""); 
  }

function dividendsOwing(address investor) internal returns(uint256) {
        uint256 newDividendPoints = totalDividendPoints.sub(balances[investor].lastDividend);
        return (balances[investor].balance.mul(newDividendPoints)).div(pointMultiplier);
    }

function disburse(uint256 amount)  onlyOwner public{
        totalDividendPoints = totalDividendPoints.add((amount.mul(pointMultiplier)).div(totalSupply_));
        totalSupply_ = totalSupply_.add(amount);
        unclaimedDividends =  unclaimedDividends.add(amount);
   
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