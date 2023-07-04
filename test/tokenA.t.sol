// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import "../src/tokenA.sol";
import "forge-std/Test.sol";

interface CheatCodes {
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
    Vm internal immutable vm = Vm(HEVM_ADDRESS);

    // Before Each of Hardhat
    function setUp() public {
        amount1 = 1e18;
        token = new tokenA();
        owner = address(this);
        addr1 = cheats.addr(1);
        addr2 = cheats.addr(2);
    }

    function consoleLogThis() public view {
        console.log(
            "Deployed and verified token Contract at 0x441a72705221E336d31E9578071ad7Bb0965E91D"
        );
        console.log("Important Commands Below");
        console.log(
            "forge test --match-test testFuzzMint --match-contract TestTokenA -vv"
        );
        console.log(
            "forge script script/tokenA.s.sol:MyScript --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv"
        );
        console.log("forge test --gas-report");
    }

    // Basic Tests

    function testName() public {
        string memory _name = token.name();
        assertEq(_name, "tokenA");
    }

    function testSymbol() public {
        assertEq(token.symbol(), "TKNA");
    }

    function testTotalSupply() public {
        token.mint(addr1, 1e18);
        assertEq(token.totalSupply(), 1e18);
    }

    function testBalanceOf() public {
        token.mint(addr1, 1e18);
        assertEq(token.balanceOf(addr1), 1e18);
    }

    function testTransfer() public {
        vm.startPrank(addr1);
        token.mint(addr1, 1e18);
        token.transfer(addr2, 1e18);
        assertEq(token.balanceOf(addr2), 1e18);
    }

    function testApprove() public {
        vm.startPrank(addr1);
        token.approve(addr2, 1e18);
        assertEq(token.allowance(addr1, addr2), 1e18);
        vm.stopPrank();
    }

    function testTransferFrom() public {
        vm.startPrank(addr1);
        token.mint(addr1, 1e18);
        token.approve(addr1, 1e18);
        token.transferFrom(addr1, addr2, 1e18);
        assertEq(token.balanceOf(addr1), 0);
        assertEq(token.balanceOf(addr2), 1e18);
    }

    // Failure Tests
    function testFailMintToZero() external {
        token.mint(address(0), 1e18);
    }

    function testFailTransferFromZero() external {
        token.transferFrom(address(0), addr1, 1e18);
    }

    // Fuzzing
    function testFuzzMint(address to, uint256 amount) external {
        vm.assume(to != address(0));
        token.mint(to, amount);
        assertEq(token.totalSupply(), token.balanceOf(to));
    }

    function testApprove(address spender, uint256 amount) external {
        vm.assume(spender != address(0));
        vm.startPrank(spender);
        assertTrue(token.approve(addr1, amount));
        assertEq(token.allowance(spender, addr1), amount);
    }
}

contract TestTransferFunction is DSTest {

    address owner;
    address addr1;
    address addr2;
    tokenA token = new tokenA();

    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    Vm internal immutable vm = Vm(HEVM_ADDRESS);

    function setUp() public {
        // token = new tokenA();
        owner = address(this);
        addr1 = cheats.addr(1);
        addr2 = cheats.addr(2);
    }

    function testFailIfAddressToZero() external {
        token.transfer(address(0), 1e18);
    }

    function testFailBalanceLow() external {
        vm.startPrank(addr1);
        token.mint(addr1, 1e18);
        token.transfer(addr2, 2e18);
    }

    // event Transfer(address indexed from, address indexed to, uint256 amount);
    // event Mint(address indexed to, uint256 amount);

    // function expectEmit(
    // bool checkTopic1,
    // bool checkTopic2,
    // bool checkTopic3,
    // bool checkData) public virtual;


    // function testEvent() external {
    //     // ExpectEmit emitter = new ExpectEmit();
    //     expectEmit(true, true, true, true);

    //     vm.startPrank(addr1);
    //     // token.mint(addr1, 1e18);

    //     emit token.Mint(addr1, 1e18);
    //     token.mint(addr1, 1e18);
    //     // token.transfer(addr2, 1e18);
    // }
}
