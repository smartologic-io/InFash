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

const Token = artifacts.require('Token');
const StorageContract = artifacts.require('StorageContract');
const PurchaseContract = artifacts.require('PurchaseContract');

contract('PurchaseContract', function () {

    beforeEach(async function () {
      this.token = await Token.new("Test token 1", "TT1", 18);
      this.purchase = await PurchaseContract.new(this.token.address);
    });

    describe('addProduct', function () {
      it('Should fail due to product with same ID already exist', async function () {
        await this.purchase.addProduct(1, 100, web3.eth.accounts[1]);
        await this.purchase.addProduct(1, 200, web3.eth.accounts[1]).should.be.rejectedWith('revert');
      });

      it('Should pass', async function () {
        await this.purchase.addProduct(1, 100, web3.eth.accounts[1]);
      });
    });

    describe('addProducts', function () {
      it('Should fail due to product with same ID already exist', async function () {
        await this.purchase.addProducts([1], [100], [web3.eth.accounts[1]]);
        await this.purchase.addProducts([1], [200], [web3.eth.accounts[1]]).should.be.rejectedWith('revert');
      });

      it('Should fail due to prices.length != ids.length', async function () {
        await this.purchase.addProducts([1], [200, 300], [web3.eth.accounts[1]]).should.be.rejectedWith('revert');
      });

      it('Should pass', async function () {
        await this.purchase.addProducts([1], [100], [web3.eth.accounts[1]]);
      });
    });

    describe('purchaseRequest', function () {
      it('Should pass', async function () {
        await this.purchase.addProduct(1, 100, web3.eth.accounts[1]);
        await this.purchase.purchaseRequest(1);
      });
    });

    describe('confirmPurchase', function () {
      it('Should pass', async function () {
        await this.purchase.addProduct(1, 100, web3.eth.accounts[1]);
        await this.purchase.purchaseRequest(1);
        await this.token.approve(this.purchase.address, 100);
        await this.purchase.confirmPurchase(1, web3.eth.accounts[0], web3.eth.accounts[5], {from: web3.eth.accounts[1]});
      });
    });

})
