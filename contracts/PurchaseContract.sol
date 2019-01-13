pragma solidity 0.4.25;

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

contract PurchaseContract {
    
  using SafeMath for uint256;

  IERC20 token;

  struct Product {
    uint id;
    uint price;
    address buyer;
    address retailer;
    address model;
    bool purchased;
  }

  Product[] products;
  
  event Purchase(uint _id, uint _price, address _buyer, address _retailer, address _model);
  
  constructor(address _tokenAddress) public {
    token = IERC20(_tokenAddress);
  }

  function addProduct(uint _productId, uint _price) external {
    require(_productId > 0);
    require(_price > 0);

    products.push(Product(_productId, _price, address(0), msg.sender, address(0), false));
  }
  
  function purchaseRequest(uint _productId) external {
    (Product memory _product, uint index) = findProductById(_productId);
    require(_productId != 1 && _product.id == _productId && _product.purchased == false);
    require(_product.buyer == address(0));
    require(_product.price <= token.balanceOf(msg.sender));
    _product.buyer = msg.sender;
     products[index] = _product;
  }

  function getUnPurchasedProducts() external view returns(uint[]) {
    uint index;
    uint[] memory results = new uint[](products.length);

    for(uint i = 0; i < products.length; i++) {
       if(products[i].buyer == address(0)){
         results[index] = products[i].id;
         index = index.add(1);
       }
    }

    return results;
  }

  function getPurchasedProducts() external view returns(uint[]) {
    uint index;
    uint[] memory results = new uint[](products.length);

    for(uint i = 0; i < products.length; i++) {
       if(products[i].buyer != address(0)){
         results[index] = products[i].id;
         index = index.add(1);
       }
    }

    return results;
  }

  function confirmPurchase(uint _productId, address _model) external {
    require(_productId != 0);

    (Product memory _product, uint index) = findProductById(_productId);

    require(msg.sender == _product.retailer && _product.buyer != address(0)); 

    _product.model = _model;

    token.transferFrom(_product.buyer, _product.retailer, _product.price.mul(90).div(100));
    token.transferFrom(_product.buyer, _product.model, _product.price.mul(6).div(100));
    
    _product.purchased = true;
    
    products[index] = _product;

    emit Purchase(_productId, _product.price, _product.buyer, _product.retailer, _model);
  }

  function findProductById(uint _productId) internal view returns(Product, uint) {
    for(uint i = 0; i < products.length; i++) {
       if(products[i].id == _productId){
         return (products[i], i);
       }
    }
    return (Product(1, 1, address(0), address(0), address(0), false), 0);
    
  }
  
  
}