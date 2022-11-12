const hre = require("hardhat");

async function getBalance(address) {
  const balanceBigInt = await hre.ethers.provider.getBalance(address);
  return hre.ethers.utils.formatEther(balanceBigInt);
}

async function printBalances(addresses) {
  let idx = 0;
  for (const address of addresses) {
    console.log(`Address ${idx} (${address}) balance: `, await getBalance(address))
    idx ++;
  }
}

// Logs the memos stored on-chain from coffee purchases.
async function printMemos(memos) {
  for (const memo of memos) {
    const timestamp = memo.timestamp;
    const tipper = memo.name;
    const tipperAddress = memo.from;
    const message = memo.message;
    console.log(`At ${timestamp}, ${tipper} (${tipperAddress}) said: "${message}"`);
  }
}

async function main() {
  const [owner, tipper, tipper2, tipper3] = await hre.ethers.getSigners();

  const BuyMeACoffee = await hre.ethers.getContractFactory("BuyMeACoffee")
  const buyMeACoffee = await BuyMeACoffee.deploy()

  await buyMeACoffee.deployed()
  console.log(`BuyMeACoffee deployed to ${buyMeACoffee.address}`)

  const addresses = [owner.address, tipper.address, buyMeACoffee.address]
  console.log("== start ==")
  await printBalances(addresses)

  
  const tip = { value: hre.ethers.utils.parseEther("1") }
  await buyMeACoffee.connect(tipper).buyCoffee("Carolina", "You're the best!", tip)
  await buyMeACoffee.connect(tipper2).buyCoffee("Vitto", "Amazing teacher", tip);
  await buyMeACoffee.connect(tipper3).buyCoffee("Kay", "I love my Proof of Knowledge", tip);

  const largeTip = { value: hre.ethers.utils.parseEther("0.003") }
  await buyMeACoffee.connect(tipper).buyLargeCoffee("Alex", "Caffeination nation", largeTip);

  // Check balances after the coffee purchase.
  console.log("== bought coffee ==");
  await printBalances(addresses);

  // Withdraw.
  await buyMeACoffee.connect(owner).withdrawTips();

  // Check balances after withdrawal.
  console.log("== withdrawTips ==");
  await printBalances(addresses);

  // Check out the memos.
  console.log("== memos ==");
  const memos = await buyMeACoffee.getMemos();
  printMemos(memos);

  console.log("== Ownership ==");
  let currentOwner = await buyMeACoffee.connect(tipper).getOwner();
  console.log(`Account currently owned by ${JSON.stringify(currentOwner, null, 2)}`);
  await buyMeACoffee.connect(owner).transferOwnership(tipper.address);
  currentOwner = await buyMeACoffee.connect(tipper).getOwner();
  console.log(`Account currently owned by ${JSON.stringify(currentOwner, null, 2)}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
