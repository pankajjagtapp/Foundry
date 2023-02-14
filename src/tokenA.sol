//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract tokenA is ERC20 {

    constructor() ERC20("tokenA", "TKNA") {
        _mint(msg.sender, 1e18);
    }

    function mint(address to, uint amount) external virtual {
        _mint(to, amount);
    }
}