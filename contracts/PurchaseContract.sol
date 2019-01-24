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

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

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

interface Storage {

  function addProduct(uint _productId, uint _price) external;

  function addProducts(uint[] calldata _productIds, uint[] calldata _prices) external;

  function getProductPrice(uint _productId) external view returns(uint);

  function getProductRetailer(uint _productId) external view returns(address);

  function getProductBuyers(uint _productId) external view returns(address[] memory);

  function getRequestedProducts() external view returns(uint[] memory);

  function getRequestedProductsBy(address _buyer) external view returns(uint[] memory);

  function getProductBuyersWithUnconfirmedRequests(uint _productId) external view returns(address[] memory);  

  function updateProduct(uint _productId, uint _unconfirmedRequests, address buyer, bool isConfirmed) external;

  function isBuyerExist(uint _index, address _buyer) external view returns(bool);

  function getProductDetails(uint _productId, address _buyer) external view returns(uint, uint, uint, address[] memory, bool, address);

  function findProductAndIndexById(uint _productId) external view returns(uint, uint);

  function findProductIndexById(uint _productId) external view returns(uint);
  
}

contract PurchaseContract {
    
  using SafeMath for uint256;
  
  uint requestedProducts;
  
  address applicationAddress = 0x8eDE6C5CDfFd4C6a8e6Da2157A37CE45A0602dB0;

  IERC20 token;

  Storage _storage;
  
  event Purchase(uint _id, uint _price, address _buyer, address _retailer, address _model);
  
  constructor(address _tokenAddress, address __storage) public {
    token = IERC20(_tokenAddress);
    _storage = Storage(__storage);
  }

  function addProduct(uint _productId, uint _price) external {
    _storage.addProduct(_productId, _price);
  }

  function addProducts(uint[] calldata _productIds, uint[] calldata _prices) external {
    _storage.addProducts(_productIds, _prices);
  }
  
  function purchaseRequest(uint _productId) external {
    (uint unconfirmedRequests, uint price, uint index, address[] memory buyers, bool isConfirmed, address retailer) = _storage.getProductDetails(_productId, msg.sender);

    require(_productId != 0);
    require(price <= token.balanceOf(msg.sender));
    
    if(unconfirmedRequests == 0) {
       requestedProducts = requestedProducts.add(1);
    }
    
    if(!_storage.isBuyerExist(index, msg.sender)) {
        _storage.updateProduct(_productId, unconfirmedRequests.add(1), msg.sender, false);
    } else if(isConfirmed) {
        _storage.updateProduct(_productId, unconfirmedRequests.add(1), address(0), false);
    }
    
  }

  function getProductPrice(uint _productId) external view returns(uint) {
    return _storage.getProductPrice(_productId);
  }

  function getProductRetailer(uint _productId) external view returns(address) {
    return _storage.getProductRetailer(_productId);
  }
  
  function getProductBuyers(uint _productId) public view returns(address[] memory) {
    return _storage.getProductBuyers(_productId);
  }
  
  function getRequestedProducts() public view returns(uint[] memory) {
    return _storage.getRequestedProducts();
  }
  
  function getRequestedProductsBy(address _buyer) public view returns(uint[] memory) {
    return _storage.getRequestedProductsBy(_buyer);
  }
  
  function getProductBuyersWithUnconfirmedRequests(uint _productId) external view returns(address[] memory) {
    return _storage.getProductBuyersWithUnconfirmedRequests(_productId);
  }
  
  function confirmPurchase(uint _productId, address _buyer, address _model) external {
    require(_productId != 0);

    (uint unconfirmedRequests, uint price, uint index, address[] memory buyers, bool isConfirmed, address retailer) = _storage.getProductDetails(_productId, _buyer);
    
    require(msg.sender == retailer && buyers.length != 0 && _storage.isBuyerExist(index, _buyer) && !isConfirmed && token.allowance(_buyer, address(this)) >= price);

    token.transferFrom(_buyer, retailer, price.mul(90).div(100));
    token.transferFrom(_buyer, _model, price.mul(4).div(100));
    token.transferFrom(_buyer, applicationAddress, price.mul(5).div(100));
    
    unconfirmedRequests = unconfirmedRequests.sub(1);
    _storage.updateProduct(_productId, unconfirmedRequests, _buyer, true);
    if(unconfirmedRequests == 0){
       requestedProducts = requestedProducts.sub(1);
    }
    
    emit Purchase(_productId, price, _buyer, retailer, _model);
  }
  
}