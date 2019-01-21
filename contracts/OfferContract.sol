pragma solidity 0.5.2;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract OfferContract {

    using SafeMath for uint256;

    enum OfferStatus { New, Accepted, Booked }
    OfferStatus status;

    mapping (address => uint) newProposedPrices;
    mapping (address => uint) bookedAt;

    address public owner;
    address public bookedFor;

    uint public price;
    uint public activeDuration;
    uint public creationDate;
    uint public bookingTime = 30 minutes;

    event AgreementCreated(address retailer, address customer, uint price);
    event OfferPriceChangeRequested(address by, uint newPrice);
    event PriceChangeRequestAccepted(address from, uint newPrice);

    modifier onlyOwner() { 
        require(msg.sender == owner); 
        _; 
    }

    modifier onlyInActiveDuration() { 
        require(creationDate.add(activeDuration) >= block.timestamp); 
        _; 
    }
    
    constructor (uint _price, uint _activeDuration) public {
        require(_activeDuration > 0);

        owner = msg.sender;
        price = _price;
        creationDate = block.timestamp;
        activeDuration = _activeDuration.mul(1 days);
    }

    function acceptOffer() public onlyInActiveDuration {
        require(msg.sender != owner);
        require(status == OfferStatus.New || status == OfferStatus.Booked);

        if(status == OfferStatus.Booked && bookedAt[bookedFor].add(bookingTime) >= block.timestamp){
            require(msg.sender == bookedFor);
        }
        
        //AgreementContract agreement = new AgreementContract(msg.sender, owner, price);
        emit AgreementCreated(owner, msg.sender, price);
        status = OfferStatus.Accepted;
    }

    function priceChangeRequest(uint _newPrice) public onlyInActiveDuration {
        newProposedPrices[msg.sender] = _newPrice;
        emit OfferPriceChangeRequested(msg.sender, _newPrice);
    }

    function acceptPriceChangeRequestFrom(address _tenant) public onlyOwner onlyInActiveDuration {
        require(newProposedPrices[_tenant] > 0);
        price = newProposedPrices[_tenant];
        emit PriceChangeRequestAccepted(_tenant, price);

        status = OfferStatus.Booked;
        bookedAt[_tenant] = block.timestamp;
        bookedFor = _tenant;
        activeDuration.add(2 hours);
    }
    
}