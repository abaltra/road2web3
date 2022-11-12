const hre = require("hardhat");
const abi = require("../artifacts/contracts/BuyMeACoffee.sol/BuyMeACoffee.json");


async function getBalance(provider, address) {
  const balanceBigInt = await provider.getBalance(address);
  return hre.ethers.utils.formatEther(balanceBigInt);
}

async function main() {
  const contractAddress = "0xCc63005a9040663290B8A8287f727410CEfaDEEc";
  const contractABI = abi.abi;

  const provider = new hre.ethers.providers.AlchemyProvider("goerli", process.env.GOERLI_API_KEY);
  const signer = new hre.ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const buyMeACoffeeContract = new hre.ethers.Contract(contractAddress, contractABI, signer)

  console.log(`Current balance of owner: ${await getBalance(provider, signer.address)} ETH`)
  const contractBalance = await getBalance(provider, buyMeACoffeeContract.address);
  console.log(`Current balance of contract: ${contractBalance} ETH`)

  if (contractBalance !== "0.0") {
    console.log(`Withdrawing ${contractBalance} ETH`)
    const withdrawTxn = await buyMeACoffeeContract.withdrawTips()
    await withdrawTxn.wait()
  } else {
    console.log("No tips to withdraw")
  }

  console.log(`Current balance of owner: ${await getBalance(provider, signer.address)} ETH`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
