const { expect } = require("chai");

describe("KingKong", function() {
  it("should work", async function() {
    function oneEth() {
    	let ret = ethers.BigNumber.from(10);
    	return ret.pow(18);
    }
    const accounts = await ethers.getSigners();
    let king = accounts[1];
    const KingKong = await ethers.getContractFactory("KingKong");
    const kingKong = await KingKong.deploy(king.address);
    
    await kingKong.deployed();
    let initialBalance = await kingKong.getBalance(king.address);
    console.log({initialBalance});

    let pmt = oneEth();
	  console.log({pmt});
    //await kingKong.connect(accounts[2]).join({value: pmt}); // smoke test
    let bound = 3; // fails for 3
    for (let i = 0; i < bound; i++) {
	console.log(i);
	await kingKong.connect(accounts[2+i]).join({value: pmt});
    } // smoke test

    let afterBalance = await kingKong.getBalance(king.address);
    console.log({afterBalance});

    let testWall = await kingKong.testWall();
	  console.log({testWall});

    //expect(await greeter.greet()).to.equal("Hello, world!");

    //await greeter.setGreeting("Hola, mundo!");
    //expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
