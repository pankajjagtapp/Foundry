// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";
import "forge-std";
// import "../ERC20.sol";
import "../tokenA.sol";


interface CheatCodes {
   // Gets address for a given private key, (privateKey) => (address)
   function addr(uint256) external returns (address);
}

contract TestTokenA is DSTest {
    // ERC20 token;
    tokenA token;
    uint256 amount1;
    address owner;
    address addr1;
    address addr2;

    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    // Before Each of Hardhat
    function setUp() public {
        amount1 = 1e18;
        token = new tokenA();
        owner = address(this);
        addr1 = cheats.addr(1);
        addr2 = cheats.addr(2);
    }

    function testName() public {
        string memory _name = token.name();
        assertEq(_name, "tokenA");
    }

    function testSymbol() public {
        assertEq(token.symbol(), "TKNA");
    }

    function testTotalSupply() public {
        assertEq(token.totalSupply(), 1e18);
    }

    function testBalanceOf() public {
        assertEq(token.balanceOf(address(this)), 1e18);
    }

    function testTransfer() public {
        token.mint(addr1, 1e18);
        token.transfer(addr1, 1e18);
        assertEq(token.balanceOf(addr1), 2e18);
    }

    function testApprove() public {
        Vm.prank(addr1);
        token.approve(addr2, 1e18);
        assertEq(token.allowance(addr2, owner), 1e18);
    }


}