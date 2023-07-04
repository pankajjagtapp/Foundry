// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import "src/tokenA.sol";
import "forge-std/Test.sol";
import "src/kyvu.sol";
import "src/NFT.sol";
import "src/Struct.sol";

/// Example for how to PASS STRUCT Foundry Test Cases


interface CheatCodes {
    function addr(uint256) external returns (address);
}

// interface KyvuNFT {
//     struct NFTVoucher {
//         uint256 minPrice;
//         string uri;
//         bytes signature;
//     }
// }

contract TestKyvu is DSTest {
    // WETH9 weth = new WETH9();
    tokenA weth = new tokenA();
    MyNFT nft = new MyNFT();
    KyvuNFT nftContract = new KyvuNFT(address(weth));

    // struct NFTVoucher {
    //     uint256 minPrice;
    //     string uri;
    //     bytes signature;
    // }

    address owner;
    address addr1;
    address addr2;
    address addr3;
    address addr4;

    address addr5 = address(5);

    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    Vm internal immutable vm = Vm(HEVM_ADDRESS);

    function setUp() public {
        owner = address(this);
        addr1 = cheats.addr(1);
        addr2 = cheats.addr(2);
        addr3 = cheats.addr(3);
        addr4 = cheats.addr(4);

        nft.safeMint(addr1, "First NFT");
        // addr1.balance;
        console.log(addr1.balance);
    }

    function testFailChangeActiveAmount() public {
        nftContract.changeActiveAmount(95);
    }

    function testMakeOffer() public {
        console.log("address(nftContract): ", address(nftContract));
        vm.startPrank(addr2);
        weth.approve(address(nftContract), 1e18);
        nftContract.makeOffer(addr1, "First NFT", 1676469034, 1e18);
        vm.stopPrank();
    }

    function testContractFlow() public {
        console.log("address(nftContract): ", address(nftContract));
        console.log("address(addr1): ", addr1);
        console.log("addr5: ", addr5);

        vm.startPrank(addr2);
        weth.mint(addr3, 3e18);
        weth.approve(address(nftContract), 1e18);
        nftContract.makeOffer(addr1, "First NFT", 1676469034, 1e18);
        vm.stopPrank();

        vm.startPrank(addr3);
        weth.mint(addr3, 3e18);
        weth.approve(address(nftContract), 2e18);
        nftContract.makeOffer(addr1, "First NFT", 1676469034, 2e18);
        vm.stopPrank();

        vm.startPrank(addr1);
        // weth.approve(address(nftContract), 2e18);
        // nftContract.acceptOffer(addr1, "First NFT", 1);

        Struct.NFTVoucher memory voucher = Struct.NFTVoucher({
            minPrice: 0,
            uri: "spoof_uri",
            signature: "0xb3ea9b4b54c41c686eff45d0502fef36a9c1303dba70b2c5d10f6f975b3ee22b436180dd41cc22b4438060dd0b913142ee7d433adb11efc9b85495aa0f1de2271b"
        });

        // nftContract.redeem([{
        //     minPrice: 0,
        //     uri: "spoof_uri2",
        //     signature: "0x8d0ced0819927665495ca7bfb49f603ffceff195fef539d76ac21f7480f2d13143336d08fcb2037d5e0dc4bda9864f64fd67c421dd3cb1462873ec1e199c3ecc1b"
        // }]);
        // [0, "spoof_uri", "0xb3ea9b4b54c41c686eff45d0502fef36a9c1303dba70b2c5d10f6f975b3ee22b436180dd41cc22b4438060dd0b913142ee7d433adb11efc9b85495aa0f1de2271b"]

        nftContract.redeem(voucher);
    }
}
