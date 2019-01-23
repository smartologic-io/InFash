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

contract StorageContract {

    using SafeMath for uint256;

    uint requestedProducts;

    struct Product {
      uint id;
      uint price;
      uint unconfirmedRequests;
      address[] buyers;
      mapping (address => bool) isConfirmed;
      address retailer;
      address model;
    }

    Product[] products;

    function addProduct(uint _productId, uint _price) public {
      require(_productId > 0);
      require(_price > 0);
      
      Product memory _product = findProductById(_productId);
      require(_product.id == 0);
      
      _product.id = _productId;
      _product.price = _price;
      _product.retailer = msg.sender;
      _product.model = address(0);
      
      products.push(_product);
    
    }

    function addProducts(uint[] calldata _productIds, uint[] calldata _prices) external {
      require(_productIds.length > 0);
      require(_prices.length > 0);
      require(_productIds.length == _prices.length);

      for(uint i = 0; i < _productIds.length; i++) {
        addProduct(_productIds[i], _prices[i]);
      }
    }

    function isProductExist(uint _productId, address _retailer) external returns(bool res) {
      for(uint i = 0; i < products.length; i++) {
         if(products[i].id == _productId && products[i].retailer == _retailer) {
           return true;
         }
      }

      return false;
    }

    function updateProduct(uint _productId, uint _unconfirmedRequests, address newBuyer) external {
      uint index = findProductIndexById(_productId);
      products[index].unconfirmedRequests = _unconfirmedRequests;
      if(newBuyer != address(0)) {
        products[index].buyers.push(newBuyer);
      }
      products[index].isConfirmed[newBuyer] = false;
    }

    function isBuyerExist(uint _index, address _buyer) public view returns(bool) {
    
      for(uint y = 0; y < products[_index].buyers.length; y++) {
        if(products[_index].buyers[y] == _buyer) {
          return true;
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

    function getProductDetails(uint _productId, address _buyer) public view returns(uint, uint, uint, bool) {
      for(uint i = 0; i < products.length; i++) {
         if(products[i].id == _productId) {
           return (products[i].unconfirmedRequests, products[i].price, i, products[i].isConfirmed[_buyer]);
         }
      }
      
      return (0, 0, 0, false);
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