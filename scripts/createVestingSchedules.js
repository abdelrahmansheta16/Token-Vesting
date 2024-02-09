const { ethers } = require('hardhat');
const { tokenVestingAddress, beneficiaries } = require("./constants");


async function main() {

    // Connect to the deployed TokenVesting contract
    const TokenVesting = await ethers.getContractAt('TokenVesting', tokenVestingAddress);
    const getSeconds = (months) => {
        return months * 30 * 24 * 60 * 60;
    }

    const [signer] = await ethers.getSigners();
    for (const { address, start, cliff, duration, slicePeriodSeconds, revocable, amount } of beneficiaries) {
        const tx = await TokenVesting.connect(signer).createVestingSchedule(
            address,
            start,
            cliff,
            duration,
            slicePeriodSeconds,
            revocable,
            amount
        );
        const reciept = await tx.wait();
        console.log(reciept);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
