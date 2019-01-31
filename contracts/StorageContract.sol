pragma solidity 0.5.2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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

contract StorageContract is Ownable {

    using SafeMath for uint256;

    uint requestedProducts;

    struct Product {
      uint id;
      uint price;
      uint unconfirmedRequests;
      address[] buyers;
      mapping (address => bool) isConfirmed;
      address retailer;
    }

    Product[] products;

    event ProductAdded(uint id, uint price, address retailer);
    
    function addProduct(uint _productId, uint _price, address _retailer) public onlyOwner {
      require(_productId > 0);
      require(_price > 0);
      
      Product memory _product = findProductById(_productId);
      require(_product.id == 0);
      
      _product.id = _productId;
      _product.price = _price;
      _product.retailer = _retailer;

      products.push(_product);
      
      emit ProductAdded(_productId, _price, _retailer);
    }

    function addProducts(uint[] calldata _productIds, uint[] calldata _prices, address[] calldata _retailers) external onlyOwner {
      require(_productIds.length > 0);
      require(_prices.length > 0);
      require(_productIds.length == _prices.length && _productIds.length == _retailers.length);

      for(uint i = 0; i < _productIds.length; i++) {
        addProduct(_productIds[i], _prices[i], _retailers[i]);
      }
    }

    function isProductExist(uint _productId, address _retailer) external view returns(bool res) {
      for(uint i = 0; i < products.length; i++) {
         if(products[i].id == _productId && products[i].retailer == _retailer) {
           return true;
         }
      }

      return false;
    }

    function updateProduct(uint _productId, uint _unconfirmedRequests, uint _requestedProducts, address buyer, bool isConfirmed) external onlyOwner {
      require(products.length > 0);
      requestedProducts = _requestedProducts;
      
      uint index = findProductIndexById(_productId);
      
      products[index].unconfirmedRequests = _unconfirmedRequests;
      if(buyer != address(0) && !isBuyerExist(index, buyer)) {
        products[index].buyers.push(buyer);
      }
      products[index].isConfirmed[buyer] = isConfirmed;
    }

    function isBuyerExist(uint _index, address _buyer) public view returns(bool) {
      if(products[_index].buyers.length > 0){
        for(uint y = 0; y < products[_index].buyers.length; y++) {
          if(products[_index].buyers[y] == _buyer) {
            return true;
          }
        }
      }
      
      return false;
    
    }

    function getProductPrice(uint _productId) external view returns(uint) {
      Product memory _product = findProductById(_productId);
      return _product.price;
    }

    function getProductRetailer(uint _productId) external view returns(address) {
      Product memory _product = findProductById(_productId);
      return _product.retailer;
    }
    
    function getProductBuyers(uint _productId) public view returns(address[] memory) {
      Product memory _product = findProductById(_productId);
      return _product.buyers;
    }

    function getRequestedProducts() public view returns(uint[] memory) {
      uint index;
      uint[] memory results = new uint[](requestedProducts);
      for(uint i = 0; i < products.length; i++) {
          if(products[i].unconfirmedRequests > 0) {
              results[index] = products[i].id;
              index = index.add(1);
          }
      }
      return results;
    }

    function getRequestedProductsBy(address _buyer) public view returns(uint[] memory) {
      uint index;
      
      for(uint i = 0; i < products.length; i++) {
          if(products[i].unconfirmedRequests > 0 && isBuyerExist(i, _buyer) && products[i].isConfirmed[_buyer] == false) {
              index = index.add(1);
          }
      }
      
      uint[] memory results = new uint[](index);
      index = 0;
      
      for(uint i = 0; i < products.length; i++) {
          if(products[i].unconfirmedRequests > 0 && isBuyerExist(i, _buyer) && products[i].isConfirmed[_buyer] == false) {
              results[index] = products[i].id;
              index = index.add(1);
          }
      }
      return results;
    }
  
    function getProductBuyersWithUnconfirmedRequests(uint _productId) external view returns(address[] memory) {
      uint index;
      (Product memory _product, uint i) = findProductAndIndexById(_productId);
      address[] memory buyers = getProductBuyers(_productId);
      address[] memory results = new address[](_product.unconfirmedRequests);
      
      for(uint y = 0; y < buyers.length; y++) {
        if(!products[i].isConfirmed[buyers[y]]) {
          results[index] = buyers[y];
          index = index.add(1);
        }
      }
      
      return results;
    }

    function findProductAndIndexById(uint _productId) internal view returns(Product memory, uint) {
      for(uint i = 0; i < products.length; i++) {
         if(products[i].id == _productId){
           return (products[i], i);
         }
      }
      
      Product memory product;
      
      return (product, 0);
    }

    function getProductDetails(uint _productId, address _buyer) public view returns(uint, uint, uint, address[] memory, bool, address) {
      for(uint i = 0; i < products.length; i++) {
         if(products[i].id == _productId) {
           return (products[i].unconfirmedRequests, products[i].price, i, products[i].buyers, products[i].isConfirmed[_buyer], products[i].retailer);
         }
      }
      
      return (0, 0, 0, new address[](0), false, address(0));
    }
  
    function findProductIndexById(uint _productId) public view returns(uint) {
      for(uint i = 0; i < products.length; i++) {
         if(products[i].id == _productId){
           return i;
         }
      }
      
      return 0;
    }

    function findProductById(uint _productId) internal view returns(Product memory) {
      for(uint i = 0; i < products.length; i++) {
         if(products[i].id == _productId){
           return products[i];
         }
      }
      
      Product memory product;
      
      return product;
    }

}