const BigNumber = web3.BigNumber

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

const ProfileContract = artifacts.require('ProfileContract');

contract('ProfileContract', function () {

  beforeEach(async function () {
    this.profile = await ProfileContract.new();
  });

  describe('Request data', async function() {
    it('should fail due to type array length = 0', async function() {
       await this.profile.requestData([], 24, 100).should.be.rejectedWith("revert");
    });

    it('should fail due to type array length > 5', async function() {
       await this.profile.requestData([1, 2, 3, 4, 5, 6], 24, 100).should.be.rejectedWith("revert");
    });

    it('should fail due to period = 0', async function() {
      await this.profile.requestData([1, 2, 3, 4], 0, 100).should.be.rejectedWith("revert");
    });

    it('should fail due to token amount = 0', async function() {
       await this.profile.requestData([1, 2, 3, 4], 24, 0).should.be.rejectedWith("revert");
    });

    it('should pass', async function() {
       await this.profile.requestData([1, 2, 3, 4], 24, 100);
    });
  });

  describe('Get requests from', async function() {
    it('should fail due to not owner call', async function() {
       await this.profile.requestData([1, 2, 3, 4], 24, 100, { from: web3.eth.accounts[1] });
       await this.profile.getRequestsFrom(web3.eth.accounts[1], { from: web3.eth.accounts[2]}).should.be.rejectedWith("revert");
    });

    it('should fail due to requests = 0', async function() {
       await this.profile.getRequestsFrom(web3.eth.accounts[1], { from: web3.eth.accounts[0]}).should.be.rejectedWith("revert");
    });

    it('should pass', async function() {
       await this.profile.requestData([1, 2, 3, 4], 24, 100, { from: web3.eth.accounts[2] });
       await this.profile.getRequestsFrom(web3.eth.accounts[2], { from: web3.eth.accounts[0] });
    });
  });

  describe('Agree', async function() {
    it('should fail due to not owner call', async function() {
       await this.profile.requestData([1, 2, 3, 4], 24, 100, { from: web3.eth.accounts[1] });
       await this.profile.agree(web3.eth.accounts[1], "test", {from: web3.eth.accounts[1]}).should.be.rejectedWith("revert");
    });

    it('should pass', async function() {
       await this.profile.requestData([1, 2, 3, 4], 24, 100, { from: web3.eth.accounts[1] });
       await this.profile.agree(web3.eth.accounts[1], "test", {from: web3.eth.accounts[0]});
    });
  });

  describe('Get encrypted data', async function() {
    it('should pass', async function() {
       await this.profile.requestData([1, 2, 3, 4], 24, 100, { from: web3.eth.accounts[1] });
       await this.profile.agree(web3.eth.accounts[1], "test", { from: web3.eth.accounts[0] });
       await this.profile.getEncryptedData({ from: web3.eth.accounts[1] });
    });
  });
});