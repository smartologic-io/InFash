var increaseTimeTo = require('./helpers/increaseTime');
var latestTime = require('./helpers/latestTime');
var advanceBlock = require('./helpers/advanceToBlock');
const BigNumber = web3.BigNumber;

const duration = {
  seconds: function (val) { return val; },
  minutes: function (val) { return val * this.seconds(60); },
  hours: function (val) { return val * this.minutes(60); },
  days: function (val) { return val * this.hours(24); },
  weeks: function (val) { return val * this.days(7); },
  years: function (val) { return val * this.days(365); },
};

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

var chai = require('chai');
var assert = chai.assert;

const StorageContract = artifacts.require('StorageContract');

contract('StorageContract', function () {

    beforeEach(async function () {
      this.contract = await StorageContract.new();
    });

    describe('addProduct', function () {
      it('Should fail due to not owner call', async function () {
        await this.contract.addProduct(1, 100, web3.eth.accounts[1], {from: web3.eth.accounts[1]}).should.be.rejectedWith('revert');
      });

      it('Should fail due to product with same ID already exist', async function () {
        await this.contract.addProduct(1, 100, web3.eth.accounts[1]);
        await this.contract.addProduct(1, 200, web3.eth.accounts[1]).should.be.rejectedWith('revert');
      });

      it('Should pass', async function () {
        let tx = await this.contract.addProduct(1, 100, web3.eth.accounts[1]);
        let events = tx.logs.filter(l => l.event === 'ProductAdded');
        let id = events[0].args.id;
        let price = events[0].args.price;
        let retailerAccount = events[0].args.retailer;
        assert.equal(id, 1);
        assert.equal(price, 100);
        assert.equal(retailerAccount, web3.eth.accounts[1]);
      });
    });

    describe('addProducts', function () {
      it('Should fail due to not owner call', async function () {
        await this.contract.addProducts([1], [100], [web3.eth.accounts[1]], {from: web3.eth.accounts[1]}).should.be.rejectedWith('revert');
      });

      it('Should fail due to product with same ID already exist', async function () {
        await this.contract.addProducts([1], [100], [web3.eth.accounts[1]]);
        await this.contract.addProducts([1], [200], [web3.eth.accounts[1]]).should.be.rejectedWith('revert');
      });

      it('Should fail due to prices.length != ids.length', async function () {
        await this.contract.addProducts([1], [200, 300], [web3.eth.accounts[1]]).should.be.rejectedWith('revert');
      });

      it('Should pass', async function () {
        let tx = await this.contract.addProducts([1], [100], [web3.eth.accounts[1]]);
        let events = tx.logs.filter(l => l.event === 'ProductAdded');
        let id = events[0].args.id;
        let price = events[0].args.price;
        let retailerAccount = events[0].args.retailer;
        assert.equal(id, 1);
        assert.equal(price, 100);
        assert.equal(web3.eth.accounts[1], retailerAccount);
      });
    });

    describe('isProductExist', function () {
      it('Should fail due to product doesn\'t exist', async function () {
        await this.contract.addProduct(1, 100, web3.eth.accounts[1]);
        await this.contract.isProductExist(1, web3.eth.accounts[1]);
      });

      it('Should pass', async function () {
        await this.contract.addProduct(1, 100, web3.eth.accounts[1]);
        await this.contract.isProductExist(1, web3.eth.accounts[1]);
      });
    });

    describe('updateProduct', function () {
      it('Should fail due to product doesnt exist', async function () {
        await this.contract.updateProduct(1, 1, 1, web3.eth.accounts[2], false).should.be.rejectedWith('revert');
      });

      it('Should pass', async function () {
        await this.contract.addProduct(1, 100, web3.eth.accounts[1]);
        await this.contract.updateProduct(1, 1, 1, web3.eth.accounts[2], false);
      });
    });

    describe('getProductPrice', function () {
      it('Should fail due to product doesnt exist', async function () {
        assert.notEqual(await this.contract.getProductPrice(1), 100);
      });

      it('Should pass', async function () {
        await this.contract.addProduct(1, 100, web3.eth.accounts[1]);
        assert.equal(await this.contract.getProductPrice(1), 100);
      });
    });

    describe('getProductRetailer', function () {
      it('Should fail due to product doesnt exist', async function () {
        assert.notEqual(await this.contract.getProductRetailer(1), web3.eth.accounts[1]);
      });

      it('Should pass', async function () {
        await this.contract.addProduct(1, 100, web3.eth.accounts[1]);
        assert.equal(await this.contract.getProductRetailer(1), web3.eth.accounts[1]);
      });
    });

    describe('getProductBuyers', function () {
      it('Should fail due to product doesnt exist', async function () {
        assert.notEqual(await this.contract.getProductBuyers(1), web3.eth.accounts[2]);
      });

      it('Should pass', async function () {
        await this.contract.addProduct(1, 100, web3.eth.accounts[1]);
        await this.contract.updateProduct(1, 1, 1, web3.eth.accounts[2], false);
        assert.equal(await this.contract.getProductBuyers(1), web3.eth.accounts[2]);
      });
    });

    describe('getRequestedProducts', function () {
      it('Should fail', async function () {
        assert.notEqual(await this.contract.getRequestedProducts(), 1);
      });

      it('Should pass', async function () {
        await this.contract.addProduct(1, 100, web3.eth.accounts[1]);
        await this.contract.updateProduct(1, 1, 1, web3.eth.accounts[2], false);
        assert.equal(await this.contract.getRequestedProducts(), 1);
      });
    });

    describe('getRequestedProductsBy', function () {
      it('Should fail', async function () {
        assert.notEqual(await this.contract.getRequestedProductsBy(web3.eth.accounts[2]), 1);
      });

      it('Should pass', async function () {
        await this.contract.addProduct(1, 100, web3.eth.accounts[1]);
        await this.contract.updateProduct(1, 1, 1, web3.eth.accounts[2], false);
        assert.equal(await this.contract.getRequestedProductsBy(web3.eth.accounts[2]), 1);
      });
    });

})
