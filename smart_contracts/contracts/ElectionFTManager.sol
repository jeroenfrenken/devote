// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ElectionFT.sol";

contract ElectionFTManager is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    ElectionFT public ft;

    constructor(string memory name_, string memory symbol_, uint256 cap_) {
        _setupRole(ADMIN_ROLE, msg.sender);
        createNewElection(name_, symbol_, cap_);
    }

    /**
     * @dev Checks if the sender has admin role assigned
     */
    modifier isAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not a ADMIN_ROLE");
        _;
    }

    /**
     * @dev Since we don't allow unpausing an ElectionFT we can use the pause function to pause all activity going forward
     */
    function stopActiveElection() public {
        ft.pause();
    }

    /**
     * @dev Create new election
     */
    function createNewElection(string memory name_, string memory symbol_, uint256 cap_) isAdmin public {
        ft = new ElectionFT(name_, symbol_, cap_);
        ft.addManager(msg.sender);
    }
}