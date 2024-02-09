
export const tokenVestingAddress = '0xcF92d90733A70672305115F0C4B0E77004577Fd7';

export const initialReceivers = [{
    receiver: '0x1cf5CB74FfD10d39f6737136145aCBdD76649041',
    amount: 6624000
}, {
    receiver: '0x70997970C51812dc3A010C7d01b50e0d17dc79C8',
    amount: 6624000
}, {
    receiver: '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC',
    amount: 24012000
}, {
    receiver: '0x90F79bf6EB2c4f870365E785982E1f101E93b906',
    amount: 2484000
}, {
    receiver: '0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65',
    amount: 0
}, {
    receiver: '0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc',
    amount: 0
}, {
    receiver: '0x14dC79964da2C08b23698B3D3cc7Ca32193d9955',
    amount: 193200
}, {
    receiver: '0x976EA74026E726554dB657fA54763abd0C3a0aa9',
    amount: 0
}, {
    receiver: '0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f',
    amount: 0
}, {
    receiver: '0xa0Ee7A142d267C1f36714E4a8F75612F20a79720',
    amount: 0
}, {
    receiver: '0xFABB0ac9d68B0B445fB7357272Ff202C5651694a',
    amount: 33616800
}];

export const beneficiaries = [{
    beneficiary: '0x1cf5CB74FfD10d39f6737136145aCBdD76649041',
    start: 1707868800,
    cliff: getSeconds(1),
    duration: getSeconds(10),
    slicePeriodSeconds: getSeconds(1),
    revocable: true,
    amount: 76176000
}, {
    receiver: '0x70997970C51812dc3A010C7d01b50e0d17dc79C8',
    start: 1707868800,
    cliff: getSeconds(0),
    duration: getSeconds(5),
    slicePeriodSeconds: getSeconds(1),
    revocable: true,
    amount: 48576000

}, {
    receiver: '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC',
    start: 1707868800,
    cliff: getSeconds(0),
    duration: getSeconds(3),
    slicePeriodSeconds: getSeconds(1),
    revocable: true,
    amount: 96048000

}, {
    receiver: '0x90F79bf6EB2c4f870365E785982E1f101E93b906',
    start: 1707868800,
    cliff: getSeconds(0),
    duration: getSeconds(5),
    slicePeriodSeconds: getSeconds(1),
    revocable: true,
    amount: 18216000

}, {
    receiver: '0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65',
    start: 1707868800,
    cliff: getSeconds(6),
    duration: getSeconds(40),
    slicePeriodSeconds: getSeconds(1),
    revocable: true,
    amount: 110400000

}, {
    receiver: '0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc',
    start: 1707868800,
    cliff: getSeconds(6),
    duration: getSeconds(30),
    slicePeriodSeconds: getSeconds(1),
    revocable: true,
    amount: 110400000

}, {
    receiver: '0x14dC79964da2C08b23698B3D3cc7Ca32193d9955',
    start: 1707868800,
    cliff: getSeconds(0),
    duration: getSeconds(48),
    slicePeriodSeconds: getSeconds(1),
    revocable: true,
    amount: 91806800

}, {
    receiver: '0x976EA74026E726554dB657fA54763abd0C3a0aa9',
    start: 1707868800,
    cliff: getSeconds(3),
    duration: getSeconds(4),
    slicePeriodSeconds: getSeconds(1),
    revocable: true,
    amount: 92000000

}, {
    receiver: '0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f',
    start: 1707868800,
    cliff: getSeconds(3),
    duration: getSeconds(24),
    slicePeriodSeconds: getSeconds(1),
    revocable: true,
    amount: 82800000

}, {
    receiver: '0xa0Ee7A142d267C1f36714E4a8F75612F20a79720',
    start: 1707868800,
    cliff: getSeconds(3),
    duration: getSeconds(24),
    slicePeriodSeconds: getSeconds(1),
    revocable: true,
    amount: 73600000

}, {
    receiver: '0xFABB0ac9d68B0B445fB7357272Ff202C5651694a',
    start: 1707868800,
    cliff: getSeconds(1),
    duration: getSeconds(12),
    slicePeriodSeconds: getSeconds(1),
    revocable: true,
    amount: 46423200

}];

module.exports = {
    tokenVestingAddress,
    initialReceivers,
    beneficiaries
};