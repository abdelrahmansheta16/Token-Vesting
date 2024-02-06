// contracts/TokenVesting.sol
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

// OpenZeppelin dependencies
import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {Owned} from "solmate/src/auth/Owned.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";
import {ReentrancyGuard} from "solmate/src/utils/ReentrancyGuard.sol";

/**
 * @title TokenVesting
 */
contract TokenVesting is Owned, ReentrancyGuard {
    struct InitialReceiver {
        address receiverAddress;
        uint amount;
    }

    // address of the ERC20 token
    ERC20 private immutable _token;

    address private beneficiary_;
    uint256 private start_;
    uint256 private released_;
    uint256 private cliff_;
    uint256 private duration_;
    uint256 private slicePeriodSeconds_;
    bool private revocable_;
    bool private revoked_;
    uint256 private amountTotal_;

    uint256 private vestingSchedulesTotalAmount;

    /**
     * @dev Reverts if the vesting schedule does not exist or has been revoked.
     */
    modifier onlyIfVestingScheduleNotRevoked() {
        require(!revoked_);
        _;
    }

    /**
     * @dev Creates a vesting contract.
     * @param token_ address of the ERC20 token contract
     */
    constructor(address token_) Owned(tx.origin) {
        // Check that the token address is not 0x0.
        require(token_ != address(0x0));
        // Set the token address.
        _token = ERC20(token_);
    }

    /**
     * @notice Creates a new vesting schedule for a beneficiary.
     * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
     * @param _start start time of the vesting period
     * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
     * @param _duration duration in seconds of the period in which the tokens will vest
     * @param _slicePeriodSeconds duration of a slice period for the vesting in seconds
     * @param _revocable whether the vesting is revocable or not
     * @param _amount total amount of tokens to be released at the end of the vesting
     */
    function initialize(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _slicePeriodSeconds,
        bool _revocable,
        uint256 _amount
    ) external onlyOwner {
        require(
            getWithdrawableAmount() >= amountTotal_,
            "TokenVesting: cannot create vesting schedule because not sufficient tokens"
        );
        require(_duration > 0, "TokenVesting: duration must be > 0");
        require(_amount > 0, "TokenVesting: amount must be > 0");
        require(
            _slicePeriodSeconds >= 1,
            "TokenVesting: slicePeriodSeconds must be >= 1"
        );
        require(_duration >= _cliff, "TokenVesting: duration must be >= cliff");

        uint256 cliff = _start + _cliff;

        beneficiary_ = _beneficiary;
        start_ = _start;
        cliff_ = cliff;
        duration_ = _duration;
        slicePeriodSeconds_ = _slicePeriodSeconds;
        revocable_ = _revocable;
        amountTotal_ = _amount;
    }

    /**
     * @notice Revokes the vesting schedule for given identifier.
     */
    function revoke() external onlyOwner onlyIfVestingScheduleNotRevoked {
        require(revocable_, "TokenVesting: vesting is not revocable");
        uint256 vestedAmount = _computeReleasableAmount();
        if (vestedAmount > 0) {
            release(vestedAmount);
        }
        uint256 unreleased = amountTotal_ - released_;
        vestingSchedulesTotalAmount = vestingSchedulesTotalAmount - unreleased;
        revoked_ = true;
    }

    /**
     * @notice Withdraw the specified amount if possible.
     * @param amount the amount to withdraw
     */
    function withdraw(uint256 amount) external nonReentrant onlyOwner {
        require(
            getWithdrawableAmount() >= amount,
            "TokenVesting: not enough withdrawable funds"
        );
        /*
         * @dev Replaced owner() with msg.sender => address of WITHDRAWER_ROLE
         */
        SafeTransferLib.safeTransfer(_token, msg.sender, amount);
    }

    /**
     * @notice Release vested amount of tokens.
     * @param amount the amount to release
     */
    function release(
        uint256 amount
    ) public nonReentrant onlyIfVestingScheduleNotRevoked {
        bool isBeneficiary = msg.sender == beneficiary_;

        bool isReleasor = (msg.sender == owner);
        require(
            isBeneficiary || isReleasor,
            "TokenVesting: only beneficiary and owner can release vested tokens"
        );
        uint256 vestedAmount = _computeReleasableAmount();
        require(
            vestedAmount >= amount,
            "TokenVesting: cannot release tokens, not enough vested tokens"
        );
        released_ = released_ + amountTotal_;
        address payable beneficiaryPayable = payable(beneficiary_);
        vestingSchedulesTotalAmount =
            vestingSchedulesTotalAmount -
            amountTotal_;
        SafeTransferLib.safeTransfer(_token, beneficiaryPayable, amountTotal_);
    }

    /**
     * @notice Returns the total amount of vesting schedules.
     * @return the total amount of vesting schedules
     */
    function getVestingSchedulesTotalAmount() external view returns (uint256) {
        return vestingSchedulesTotalAmount;
    }

    /**
     * @dev Returns the address of the ERC20 token managed by the vesting contract.
     */
    function getToken() external view returns (address) {
        return address(_token);
    }

    /**
     * @notice Computes the vested amount of tokens for the given vesting schedule identifier.
     * @return the vested amount
     */
    function computeReleasableAmount()
        external
        view
        onlyIfVestingScheduleNotRevoked
        returns (uint256)
    {
        return _computeReleasableAmount();
    }

    /**
     * @dev Returns the amount of tokens that can be withdrawn by the owner.
     * @return the amount of tokens
     */
    function getWithdrawableAmount() public view returns (uint256) {
        return _token.balanceOf(address(this)) - vestingSchedulesTotalAmount;
    }

    /**
     * @dev Computes the releasable amount of tokens for a vesting schedule.
     * @return the amount of releasable tokens
     */
    function _computeReleasableAmount() internal view returns (uint256) {
        // Retrieve the current time.
        uint256 currentTime = getCurrentTime();
        // If the current time is before the cliff, no tokens are releasable.
        if ((currentTime < cliff_) || revoked_) {
            return 0;
        }
        // If the current time is after the vesting period, all tokens are releasable,
        // minus the amount already released.
        else if (currentTime >= start_ + duration_) {
            return amountTotal_ - released_;
        }
        // Otherwise, some tokens are releasable.
        else {
            // Compute the number of full vesting periods that have elapsed.
            uint256 timeFromStart = currentTime - start_;
            uint256 secondsPerSlice = slicePeriodSeconds_;
            uint256 vestedSlicePeriods = timeFromStart / secondsPerSlice;
            uint256 vestedSeconds = vestedSlicePeriods * secondsPerSlice;
            // Compute the amount of tokens that are vested.
            uint256 vestedAmount = (amountTotal_ * vestedSeconds) / duration_;
            // Subtract the amount already released and return.
            return vestedAmount - released_;
        }
    }

    /**
     * @dev Returns the current time.
     * @return the current timestamp in seconds.
     */
    function getCurrentTime() internal view virtual returns (uint256) {
        return block.timestamp;
    }
}
