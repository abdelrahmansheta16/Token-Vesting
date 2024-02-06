// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {Owned} from "solmate/src/auth/Owned.sol";

import "./TokenVesting.sol";

contract VestingScheduleFactory is Owned {
    event VestingScheduleCreated(
        address indexed beneficiary,
        address vestingContract
    );

    struct InitialReceiver {
        address receiverAddress;
        uint amount;
    }

    // address of the ERC20 token
    ERC20 private immutable _token;

    // AggregatorV3Interface internal priceFeed; // Chainlink AVAX/USD Price Feed
    address public immutable vestingScheduleIpml;

    mapping(address => address[]) private _vestingSchedules;

    constructor(
        address token_,
        InitialReceiver[] memory _initialReceivers
    ) Owned(msg.sender) {
        // Check that the token address is not 0x0.
        require(token_ != address(0x0));
        // Set the token address.
        _token = ERC20(token_);

        initialTransfer(_initialReceivers);

        vestingScheduleIpml = address(new TokenVesting(token_));
    }

    function initialTransfer(
        InitialReceiver[] memory _initialReceivers
    ) private {
        for (uint256 i = 0; i < _initialReceivers.length; i++) {
            SafeTransferLib.safeTransfer(
                _token,
                _initialReceivers[i].receiverAddress,
                _initialReceivers[i].amount
            );
        }
    }

    function createVestingSchedule(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _slicePeriodSeconds,
        bool _revocable,
        uint256 _amount
    ) external onlyOwner {
        bytes32 salt = keccak256(
            abi.encodePacked(msg.sender, _vestingSchedules[msg.sender].length)
        );

        address vestingScheduleNew = Clones.cloneDeterministic(
            vestingScheduleIpml,
            salt
        );

        _vestingSchedules[msg.sender].push(vestingScheduleNew);

        TokenVesting(vestingScheduleNew).initialize(
            _beneficiary,
            _start,
            _cliff,
            _duration,
            _slicePeriodSeconds,
            _revocable,
            _amount
        );

        emit VestingScheduleCreated(_beneficiary, vestingScheduleNew);
    }

    function getNumAidroppers(address owner) external view returns (uint256) {
        return _vestingSchedules[owner].length;
    }

    function getAidroppers(
        uint256 cursor,
        uint256 howMany,
        address owner
    )
        external
        view
        returns (address[] memory vestingSchedules, uint256 newCursor)
    {
        unchecked {
            address[] storage _vestingSchedulesByOwner = _vestingSchedules[
                owner
            ];
            uint256 numVestingSchedules = _vestingSchedulesByOwner.length;
            if (numVestingSchedules == 0) {
                return (new address[](0), 0);
            }
            if (cursor >= numVestingSchedules) {
                return (new address[](0), numVestingSchedules);
            }

            uint256 length = numVestingSchedules - cursor;
            if (length > howMany) {
                length = howMany;
            }

            vestingSchedules = new address[](length);
            for (uint256 i; i != length; ++i) {
                vestingSchedules[i] = _vestingSchedulesByOwner[cursor];
                ++cursor;
            }

            newCursor = cursor;
        }
    }
}
