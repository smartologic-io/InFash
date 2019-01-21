/*
 * NB: since truffle-hdwallet-provider 0.0.5 you must wrap HDWallet providers in a 
 * function when declaring them. Failure to do so will cause commands to hang. ex:
 * ```
 * mainnet: {
 *     provider: function() { 
 *       return new HDWalletProvider(mnemonic, 'https://mainnet.infura.io/<infura-key>') 
 *     },
 *     network_id: '1',
 *     gas: 4500000,
 *     gasPrice: 10000000000,
 *   },
 */

module.exports = {
  networks: {
	  development: {
	    host: "127.0.0.1",
	    port: 8545,
	    network_id: "*"
	  }
	  //live: {
	    //host: "178.25.19.88", // Random IP for example purposes (do not use)
	    //port: 80,
	    //network_id: 1,        // Ethereum public network
	    // optional config values:
	    // gas
	    // gasPrice
	    // from - default address to use for any transaction Truffle makes during migrations
	    // provider - web3 provider instance Truffle should use to talk to the Ethereum network.
	    //          - function that returns a web3 provider instance (see below.)
	    //          - if specified, host and port are ignored.
	    // skipDryRun: - true if you don't want to test run the migration locally before the actual migration (default is false)
	    // timeoutBlocks: - if a transaction is not mined, keep retrying for this number of blocks (default is 50)
	  //}
	}
};
