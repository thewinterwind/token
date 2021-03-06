pragma solidity ^0.4.11;

import './HealthToken.sol';
import './zeppelin/math/SafeMath.sol';
import './zeppelin/ownership/Ownable.sol';

contract Crowdsale is Ownable {
  using SafeMath for uint256;

  uint256 public constant TOTAL_SUPPLY = 1200000000 ether;          //amount of tokens (not ETH), ether = * 10^18
  uint256 public constant FOUNDATION_SUPPLY = TOTAL_SUPPLY*80/100;
  uint256 public constant FOUNDER_SUPPLY = TOTAL_SUPPLY*20/100;
  uint256 public partnerBonus = 2; //percent of referral partner bonus
  uint256 public referralBonus = 4; //percent of referrer bonus


  address public foundationAddress;
  uint256 public price; //how many HLT we will send for 1 ETH; To finish crowdsale set price to 0

  HealthToken public hlt;

  /**
   * Event for token purchase logging
   * @param purchaser Who paid for the tokens
   * @param beneficiary Who got the tokens
   * @param value Weis paid for purchase
   * @param amount Amount of tokens purchased
   */ 
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  function Crowdsale(address _foundationAddress, address _founderAddress){
    foundationAddress = _foundationAddress;
    hlt = new HealthToken();
    hlt.init(foundationAddress, FOUNDATION_SUPPLY, _founderAddress, FOUNDER_SUPPLY);
  }

  function setPrice(uint256 _price) public onlyOwner {
    price = _price;
  }
  
  function() payable {
    saleTo(msg.sender, 0x0);
  }

  function saleTo(address buyer, address partner) public payable {
    require(price > 0);
    uint256 tokens  = msg.value.mul(price);
    if(partner == 0x0){
      hlt.send(foundationAddress, buyer, tokens);
      TokenPurchase(msg.sender, buyer, msg.value, tokens);
    }else{
      uint256 partnerTokens   = tokens.mul(partnerBonus).div(100);
      uint256 referralTokens  = tokens.mul(referralBonus).div(100);
      uint256 totalBuyerTokens = tokens.add(referralTokens);
      assert(hlt.send(foundationAddress, buyer, totalBuyerTokens));
      assert(hlt.send(foundationAddress, partner, partnerTokens));
      TokenPurchase(msg.sender, buyer, msg.value, totalBuyerTokens);
    }
    foundationAddress.transfer(msg.value);
  }

  function tokensAvailable() public constant returns(uint256){
    return hlt.getBalance(foundationAddress); 
  }

  function setFoundation(address newFoundationAddress) onlyOwner {
    uint256 oldFoundationTokens = hlt.getBalance(foundationAddress);
    assert(hlt.send(foundationAddress, newFoundationAddress, oldFoundationTokens));
    foundationAddress = newFoundationAddress;
  }

  function setReferralBonus(uint256 _referralBonus ) onlyOwner {
     referralBonus = _referralBonus;
  }

  function setPartnerBonus(uint256  _partnerBonus) onlyOwner {
     partnerBonus = _partnerBonus;
  }

}