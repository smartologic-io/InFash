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

const AgreementContract = artifacts.require('AgreementContract');

contract('AgreementContract', function () {

    beforeEach(async function () {
      this.contract = await AgreementContract.new(web3.eth.accounts[1], web3.eth.accounts[2], "testConditions");
    });

    describe('signAgreement', function () {
      it('Should fail due to not model or owner call', async function () {
        await this.contract.signAgreement().should.be.rejectedWith('revert');
      });

      it('Should fail due to Agreement not new', async function () {
        await this.contract.signAgreement({from: web3.eth.accounts[1]});
        await this.contract.signAgreement({from: web3.eth.accounts[2]});
        await this.contract.signAgreement({from: web3.eth.accounts[2]}).should.be.rejectedWith('revert');
      });

      it('Should pass', async function () {
        let tx = await this.contract.signAgreement({from: web3.eth.accounts[1]});
        let events = tx.logs.filter(l => l.event === 'AgreementSigned');
        let signedBy = events[0].args.by;
        assert.equal(web3.eth.accounts[1], signedBy);
        tx = await this.contract.signAgreement({from: web3.eth.accounts[2]});
        events = tx.logs.filter(l => l.event === 'AgreementSigned');
        signedBy = events[0].args.by;
        assert.equal(web3.eth.accounts[2], signedBy);
      });
    });

    describe('declineAgreement', function () {
      it('Should fail due to not model or owner call', async function () {
        await this.contract.declineAgreement("test reason").should.be.rejectedWith('revert');
      });

      it('Should fail due to Agreement not new', async function () {
        await this.contract.signAgreement({from: web3.eth.accounts[1]});
        await this.contract.signAgreement({from: web3.eth.accounts[2]});
        await this.contract.declineAgreement("test reason", {from: web3.eth.accounts[1]}).should.be.rejectedWith('revert');
      });

      it('Should fail due to Agreement alreaady declined', async function () {
        await this.contract.declineAgreement("test reason", {from: web3.eth.accounts[1]});
        await this.contract.declineAgreement("test reason", {from: web3.eth.accounts[1]}).should.be.rejectedWith('revert');
      });

      it('Should pass', async function () {
        let tx = await this.contract.declineAgreement("test reason", {from: web3.eth.accounts[1]});
        let events = tx.logs.filter(l => l.event === 'AgreementDeclined');
        let by = events[0].args.by;
        let reason = events[0].args.reason;
        assert.equal(web3.eth.accounts[1], by);
        assert.equal("test reason", reason);
      });
    });

    describe('terminateAgreement', function () {
      it('Should fail due to Agreement not signed', async function () {
        await this.contract.terminateAgreement({from: web3.eth.accounts[2]}).should.be.rejectedWith('revert');
      });

      it('Should fail due to not owner call', async function () {
        await this.contract.signAgreement({from: web3.eth.accounts[1]});
        await this.contract.signAgreement({from: web3.eth.accounts[2]});
        await this.contract.terminateAgreement().should.be.rejectedWith('revert');
      });

      it('Should pass', async function () {
        await this.contract.signAgreement({from: web3.eth.accounts[1]});
        await this.contract.signAgreement({from: web3.eth.accounts[2]});
        await this.contract.terminateAgreement({from: web3.eth.accounts[2]});
      });
    });

    describe('extendAgreement', function () {
      it('Should fail due to Agreement not signed', async function () {
        await this.contract.extendAgreement("new test reason", {from: web3.eth.accounts[2]}).should.be.rejectedWith('revert');
      });

      it('Should fail due to not model or owner call', async function () {
        await this.contract.signAgreement({from: web3.eth.accounts[1]});
        await this.contract.signAgreement({from: web3.eth.accounts[2]});
        await this.contract.extendAgreement("new test reason").should.be.rejectedWith('revert');
      });

      it('Should pass', async function () {
        await this.contract.signAgreement({from: web3.eth.accounts[1]});
        await this.contract.signAgreement({from: web3.eth.accounts[2]});
        await this.contract.extendAgreement("new test reason", {from: web3.eth.accounts[2]});
      });
    });
})
