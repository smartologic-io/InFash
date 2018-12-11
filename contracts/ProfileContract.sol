pragma solidity 0.4.25;

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

  enum Type { Login, FirstName, LastName, Email, Bodyshape };
  
  Type types;

  struct Request {
  	uint[] type,
  	uint period,
  	uint tokenAmount
  }

  mapping(uint => string) filters;
  mapping(address => mapping(uint => Request)) requests;
  mapping(address => string) encryptedMessages;
  mapping(address => uint) requestAmount;
  
  event Request(uint[] indexed type, uint indexed period, uint indexed tokenAmount);
  
  constructor(string _login, string _firstName, string _lastName, string _email, string _bodyshape) public {
    filters[types.Login] = _login;
    filters[types.FirstName] = _firstName;
    filters[types.LastName] = _lastName;
    filters[types.Email] = _email;
    filters[types.Bodyshape] = _bodyshape;
  }

  // any retailer can request personal user data
  function requestData(uint[] _type, uint _period, uint _tokenAmount) external {
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
  	for(uint i = 1; i <= requestAmount[_addr]; i++)	{
  		emit GetRequest(requests[_addr][i].type, requests[_addr][i].period, requests[_addr][i].tokenAmount);
  	}
  }

  function agree(address _user, string _encryptedMessage) external onlyOwner {
  	encryptedMessages[_user] = _encryptedMessage;
  }
  
  // get encrypted link to data of user
  function getEncryptedData() external view returns(string) {
  	return encryptedMessages[msg.sender];
  }
}
