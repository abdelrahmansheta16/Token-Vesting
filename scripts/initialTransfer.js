const { ethers } = require('hardhat');
const {tokenVestingAddress,initialReceivers}  = require("./constants");
async function main() {

    // Connect to the deployed TokenVesting contract
    const TokenVesting = await ethers.getContractAt('TokenVesting', tokenVestingAddress);

    const [signer] = await ethers.getSigners();
    console.log(signer)
    const tx = await TokenVesting.connect(signer).initialTransfer(initialReceivers);
    const reciept = await tx.wait();
    console.log(reciept);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
