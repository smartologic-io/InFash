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

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract ProfileContract is Ownable {
    
  using SafeMath for uint256;

  enum Type { Login, FirstName, LastName, Email, Bodyshape }
  
  Type types;

  struct Request {
    uint[] id;
    uint period;
    uint tokenAmount;
  }

  mapping(uint => string) filters;
  mapping(address => mapping(uint => Request)) requests;
  mapping(address => string) encryptedMessages;
  mapping(address => uint) requestAmount;
  
  event GetRequest(uint[] id, uint period, uint tokenAmount);
  
  constructor() public {
  }

  // any user can request personal user data
  function requestData(uint[] calldata _type, uint  _period, uint _tokenAmount) external {
    require(_type.length > 0 && _type.length <= 5);   
    require(_period > 0);
    require(_tokenAmount > 0);

    for(uint i = 0; i < _type.length; i++) {
      require(_type[i] >=0 && _type[i] < 5);
    }

    requestAmount[msg.sender] = requestAmount[msg.sender].add(1);
    requests[msg.sender][requestAmount[msg.sender]] = Request(_type, _period, _tokenAmount);
  }

  function getRequestsFrom(address _addr) public onlyOwner {
    require(requestAmount[_addr] > 0);
    
    for(uint i = 1; i <= requestAmount[_addr]; i++) {
      emit GetRequest(requests[_addr][i].id, requests[_addr][i].period, requests[_addr][i].tokenAmount);
    }
  }

  function agree(address _user, string calldata _encryptedMessage) external onlyOwner {
    encryptedMessages[_user] = _encryptedMessage;
  }
  
  // get encrypted link to data of user
  function getEncryptedData() external view returns(string memory) {
    return encryptedMessages[msg.sender];
  }
}