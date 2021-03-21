const { expect } = require("chai");

describe("KingKong", function() {
  it("should work", async function() {
    function oneEth() {
    	let ret = ethers.BigNumber.from(10);
    	return ret.pow(18);
    }
    let zero = ethers.BigNumber.from(0);
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
    let bound = 14; // looks like correct values for 14. passes for 18
    for (let i = 0; i < bound; i++) {
	console.log(i);
	await kingKong.connect(accounts[2+i]).join({value: pmt});
    } // smoke test

    let afterBalance = await kingKong.getBalance(king.address);
    afterBalance = parseInt(afterBalance);//afterBalance.div(oneEth()));
    console.log(afterBalance, "ETH afterKing");

    for (let i = 0; i < bound; i++) {
	let bal = await kingKong.getBalance(accounts[2+i].address);
	console.log(parseInt(bal));
    }
    let balBefore = await king.getBalance();
    await kingKong.connect(king).withdraw(afterBalance.toString(), king.address);
    expect(await kingKong.getBalance(king.address)).to.equal(zero);
    expect(await king.getBalance()).to.not.equal(balBefore);

    //let testWall = await kingKong.testWall();
	  //console.log({testWall});

    //expect(await greeter.greet()).to.equal("Hello, world!");

    //await greeter.setGreeting("Hola, mundo!");
    //expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
