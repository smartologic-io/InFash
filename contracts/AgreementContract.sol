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

contract AgreementContract {
    
    using SafeMath for uint256;

    enum AgreementStatus { New, Signed, Declined, Terminated }
    AgreementStatus status;

    string public declineReason;
    string public conditions;

    address public model;
    address public owner;
    address public offerAddress;

    uint public agreementCreated;
    uint month = 30 days;

    bool signedByOwner;
    bool signedByModel;

    event AgreementSigned(address by);
    event AgreementDeclined(address by, string reason);

    modifier onlyModelOrOwner() { 
        require(msg.sender == owner || msg.sender == model); 
        _; 
    }

    modifier onlyOwner() { 
        require(msg.sender == owner); 
        _; 
    }

    modifier onlyAfterPeriodExpired() { 
        require (agreementCreated.add(month) <= block.timestamp); 
        _; 
    }

    modifier onlyNew() { 
        require(status == AgreementStatus.New); 
        _; 
    }
    
    modifier onlySigned() { 
        require(status == AgreementStatus.Signed); 
        _; 
    }

    constructor(address _model, address _owner, string memory _conditions) public {
        model = _model;
        owner = _owner;
        offerAddress = msg.sender;
        conditions = _conditions;
        agreementCreated = block.timestamp;
        status = AgreementStatus.New;
    }

    function signAgreement() public onlyModelOrOwner onlyNew {
        if(msg.sender == model) {
            require(signedByOwner == false);
            signedByOwner = true;
            emit AgreementSigned(msg.sender);
            if(signedByModel == true){
                status = AgreementStatus.Signed;
                
            }
        } else {
            require(signedByModel== false);
            signedByModel = true;
            emit AgreementSigned(msg.sender);
            if(signedByOwner == true){
                status = AgreementStatus.Signed;
               
            }
        }
    }

    function declineAgreement(string calldata _reason) external onlyModelOrOwner onlyNew {
        require (status!=AgreementStatus.Declined);
        
        declineReason = _reason;
        status = AgreementStatus.Declined;
        emit AgreementDeclined(msg.sender, _reason);
    }

    function terminateAgreement() external onlyOwner onlySigned {
      require(status == AgreementStatus.Signed);
      
      status = AgreementStatus.Terminated;
    }

    function extendAgreement(string memory _newConditions) public onlyOwner {
        require(status == AgreementStatus.Signed);
        require(bytes(_newConditions).length > 0);

        agreementCreated = block.timestamp;
        
        signedByModel = false;
        signedByOwner = false;

        conditions = _newConditions;

        status = AgreementStatus.New;
    } 
}