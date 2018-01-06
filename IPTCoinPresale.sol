pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// IPT Coins emission and presale. version 1.0
//
// Enjoy. (c) Slava Brall / Begemot-Begemot Ltd 2017. The MIT Licence.
// ----------------------------------------------------------------------------
 
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}
/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}
contract IPTCoin is StandardToken {

  string public name = "IPT Coin";
  string public symbol = "IPTC";
  uint256 public decimals = 3;
  uint256 public INITIAL_SUPPLY = 45278654;

  /**
   * @dev Contructor that gives msg.sender all of existing tokens.
   */
  function IPTCoin() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}

contract EmissionCenter is Ownable {
 //   using SafeMath for uint256;

    IPTCoin public token = new IPTCoin();
    
    address public presaleAddress = address(0);
    address public crowdsaleAddress = address(0);
	
	event PresaleAddressIsSet(uint _time);
	event CrowdsaleAddressIsSet(uint _time);
	event TokensTransfered(address to, uint tokenAmount);
    
    function setPresaleAddress(address _presaleAddress) public onlyOwner {
		require (presaleAddress == address(0));
        require (_presaleAddress != address(0));
        presaleAddress = _presaleAddress;
		PresaleAddressIsSet(now);
    }
    
   /**
    * contract addresses could be set only once
    */
    function setCrowdsaleAddress(address _crowdsaleAddress) public onlyOwner {
		require (crowdsaleAddress == address(0));
        require (_crowdsaleAddress != address(0));
        crowdsaleAddress = _crowdsaleAddress;
		CrowdsaleAddressIsSet(now);
    }
    
   /**
    * contract addresses could be set only once
    */
    function secureTransfer(address _to, uint256 _amount) public returns (bool){
        require (msg.sender == presaleAddress || msg.sender == crowdsaleAddress);
		uint tokenAmount = _amount/10**15;    //because of token decimals=3 but ether decimals = 18
		TokensTransfered(_to, tokenAmount);
        return (token.transfer(_to, tokenAmount));  
    }
}

contract IPTCoinPresale is Ownable {
    using SafeMath for uint256;

    string public name = "IPT Coin Presale";

    EmissionCenter public emissionCenter;

    address public organizerAddress = address(0xa56B96235903b1631BC355DC0CFD8511F31D883b);
    address public secondFounderAddress = address(0xd6788DD387d1Eb833E42a2765b62D9700273bE9e);
    address public thirdFounderAddress = address(0x407c58B5b7807a6c611bB8A65D2860E7F003E528);
        
    
   /**
    * fund allocation shares in persents
    */
    
    uint public organizerShare = 3; //in persents
    //uint public firstShare = 39; owner will get the rest
    uint public secondShare = 29;
    uint public thirdShare = 29;
    
    uint public hardCapTokens = 1000000; //tokens to sell
    uint public softCapUsd = 250000;
    //uint public softCapUsd = 500; //only for testing purposes
	
    uint public collected = 0; //in ETH
    uint public priceETH = 470;//in USD
    
    uint public tokensPerETH = 1000;//how much tokens we can buy on 1 ether
    uint public hardCapETH;
    uint public softCapETH;
    uint public softCapTokens;

    uint public investorCount = 0;
    uint public weiRefunded = 0;

    uint public startTime = 0;
    uint public endTime = 0;
    uint public withdrawalTime;
    //uint public timeToDelay = 10 minutes; //for testing purposes only!
    uint public timeToDelay = 5 days;

    bool public softCapReached = false;
    bool public presaleFinished = false;

    mapping (address => bool) refunded;
    mapping (address => uint256) saleBalances ;
    mapping (address => bool) claimed;

    event GoalReached(uint amountRaised);
    event SoftCapReached(uint softCap);
    event NewContribution(address indexed holder, uint256 etherAmount);
    event Refunded(address indexed holder, uint256 amount);
    event LogClaim(address indexed holder, uint256 tokens);
    event PresaleFinish(uint _presaleEnd);
	event EmissionCenterIsSet(uint _time);
  
   /**
    * constructor with the only parameter set the actual Ether price 
    */
    function IPTCoinPresale(uint _priceETH) public{
        require(_priceETH > 200 && _priceETH <600);
        
        priceETH = _priceETH;
        
        hardCapETH = hardCapTokens / tokensPerETH;
        softCapETH = softCapUsd / priceETH;
        softCapTokens = softCapUsd / priceETH /tokensPerETH;
		startTime = now;
    }  
  
   /**
    * checks how much the investor has payed 
    */
    function saleBalanceOf(address _owner) public view returns (uint256) {
      return saleBalances[_owner];
    }

   /**
    * checks if investor got tokens already 
    */
    function claimedOf(address _owner) public view returns (bool) {
      return claimed[_owner];
    }
    
   /**
    * we do not accept payments less then one token 
    */
    function () public payable{
        assert (msg.value >= 1 ether / tokensPerETH);
        if(msg.value >= 1 ether / tokensPerETH) doPurchase(msg.sender);
    }

   /**
    * main payments handling function 
    */
    function doPurchase(address _owner) private  {
	   /**
		* without this check, after funding could be set incorrect emissionCenter with not appropriate parameters
		*/
		require (emissionCenter != EmissionCenter(address(0))); 
        require(presaleFinished == false);

        require (collected.add(msg.value) <= hardCapETH * 10**18);

        if (!softCapReached && collected < softCapETH * 10**18 && collected.add(msg.value) >= softCapETH * 10**18) {
            softCapReached = true;
            SoftCapReached(softCapETH);
        }

        if (saleBalances[_owner] == 0) investorCount++;

        collected = collected.add(msg.value);

        saleBalances[_owner] = saleBalances[_owner].add(msg.value);   
        NewContribution(_owner, msg.value);

        if (collected == hardCapETH * 10**18) {
            presaleFinished = true;
            GoalReached(hardCapETH);
            endTime = now;
            PresaleFinish(endTime);
        }
    }

   /**
    * finish the presale manually
    */
    function presaleFinish() public onlyOwner{
        require (!presaleFinished);
        presaleFinished = true;
        endTime = now;
        PresaleFinish(endTime);
    }


   /**
    * investors ask their tokens after presale is finised
    */
    function claim() public {    				
        require (presaleFinished);
		require (softCapReached);
		require (saleBalances[msg.sender] != 0);
        require (!claimed[msg.sender]);
        require (emissionCenter != address(0));

        uint tokens = saleBalances[msg.sender] * tokensPerETH;

        require(emissionCenter.secureTransfer(msg.sender, tokens));
        claimed[msg.sender] = true;
        LogClaim(msg.sender, tokens/10**15);
    }
    

   /**
    * funds withdrawal after five days delay since presale is finished successfully
    */
    function withdraw() public onlyOwner {    
        require (softCapReached);
        require (presaleFinished);
        require (endTime + timeToDelay < now);
		
        require (organizerAddress.send(collected.mul(organizerShare).div(100)));
        require (secondFounderAddress.send(collected.mul(secondShare).div(100)));
        require (thirdFounderAddress.send(collected.mul(thirdShare).div(100)));
        require (owner.send(this.balance));                 
    }
    
   /**
    * refund investors payments in case of softcap is not reached 
    */
    function refund() public  { 
        require (presaleFinished);
        require (!softCapReached);
        require (!refunded[msg.sender]);
        require (saleBalances[msg.sender] != 0) ;

        uint amount = saleBalances[msg.sender];
        require (msg.sender.send(amount));
        refunded[msg.sender] = true;
        weiRefunded = weiRefunded.add(amount);
        Refunded(msg.sender, amount);
    }

 
   /**
    * emission center is the only tokens provider for presale and crowdsale contracts. All tokens 
    * transfers are goint throw it. 
    */
  function setEmissionCenter(address _center) public onlyOwner {
      require (_center != address(0));
	  require (emissionCenter == EmissionCenter(address(0))); //check syntacsis here
      emissionCenter = EmissionCenter(_center);
	  EmissionCenterIsSet(now);
  }

}

