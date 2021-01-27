// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract ElectionNFT is ERC20, Pausable, AccessControl {
    using SafeMath for uint256;

    /**
     * @dev Manager role which can be assigned to addresses
     */
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    /**
     * @dev Total votes
     */
    uint256 private _cap;

    /**
     * @dev Sets up the NFT
     */
    constructor(string memory name_, string memory symbol_, uint256 cap_) ERC20(name_, symbol_) {
        require(cap_ > 0, "ElectionNFT: cap is 0");

        // Only one decimal since you cannot do half votes
        _setupDecimals(1);

        // Add initial manager
        _setupRole(MANAGER_ROLE, msg.sender);

        // Set NFT capacity
        _cap = cap_;
    }

    /**
     * @dev Checks if the user is a manager
     */
    modifier isManager() {
        require(hasRole(MANAGER_ROLE, msg.sender), "Caller is not a MANAGER_ROLE");
        _;
    }

    /**
     * @dev Add another manager to the NFT
     */
    function addManager(address managerAddress) isManager public {
        _setupRole(MANAGER_ROLE, managerAddress);
    }

    /**
     * @dev Returns the cap on the token's total supply. (how many votes this election can have)
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    /**
     * @dev Mints
     */
    function mint(address to) isManager public {
        _mint(to, 1);
    }

    /**
     * @dev Pauses the election
     */
    function pause() isManager public {
        _pause();
    }

    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - minted tokens must not cause the total supply to go over the cap.
     * - the nft is not currently paused
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ElectionNFT: cannot do token transfer while election is paused");

        if (from == address(0)) { // When minting tokens
            require(totalSupply().add(amount) <= _cap, "ERC20Capped: cap exceeded");
        }
    }
}