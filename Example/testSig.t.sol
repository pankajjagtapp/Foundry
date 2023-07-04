// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import "../lib/forge-std/Test.sol";
import {DSTest} from "ds-test/test.sol";
import "../marketPlace.sol";
import "../NFTContract.sol";
import "../mock/USDC.sol";
import "../libraries/structLib.sol";
import {Utilities} from "./utils/Utilities.sol";
import {Vm} from "forge-std/Vm.sol";
import {console} from "./utils/Console.sol";


contract MarketPlaceTest is DSTest {
    bytes32 internal DOMAIN_SEPARATOR = 0xed9028b32b3fc3a1100820d06428606d4052ac05cda099dc214b640a069befd7;


    bytes32 public constant PERMIT_TYPEHASH =
        0xef3f6c8acc75df7b432c69082176bb4db86ffbe750d0e5310b8c650fad7d3a04;

    struct Permit {
        address owner;
        address spender;
        uint256 value;
        uint256 nonce;
        uint256 deadline;
    }
    struct NFTSell {
        address winery;
        address seller;
        uint256 tokenId;
        uint256 price;
        bytes signature; 
    }
    struct NFTSell2 {
        address winery;
        address seller;
        uint256 tokenId;
        uint256 price;
    }

    






    marketPlace public market;
    // marketPlace public market2;
    wineNFT public nft;
    Usdc public usdc;
    Utilities internal utils;
    address payable[] internal users;
    Vm internal immutable vm = Vm(HEVM_ADDRESS);

    function setUp() public {
        utils = new Utilities();
        users = utils.createUsers(5);
        market = new marketPlace();
        nft = new wineNFT();
        usdc = new Usdc();
         market.initialize(
         address(nft),
         users[0],
         address(usdc)
        );
        nft.initialize(address(market),users[0]);
        usdc.mint(users[2],30000);
        usdc.mint(users[3],1000);
        usdc.mint(users[4],1000000000000000000000000000000000000000);
      
    }





    function testRevert_ExpiredPermit() public {
        NFTSell2 memory permit3 = NFTSell2({
            winery: users[1],
            seller: 0xb90F789eD58e7cF3eFc0421Ed87bb79f53B0f984,
            tokenId: 1, 
            price: 10
        });

        bytes32 digest = getTypedDataHash(permit3);
        emit log_named_bytes32("digest",digest);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0x1aa00af2249c90ddef8565fb073e682e361699fd802b46b2efc867198ffbc71c, digest);
        // vm.startPrank(0xb90F789eD58e7cF3eFc0421Ed87bb79f53B0f984);
        bytes memory sig = abi.encodePacked(r, s, v);

        Struct.NFTSell memory permit2 = Struct.NFTSell({
            winery: users[1],
            seller: 0xb90F789eD58e7cF3eFc0421Ed87bb79f53B0f984,
            tokenId: 1, 
            price: 10,
            signature:sig
        });
        // vm.startPrank(users[1]);
        market.buyNFT(permit2);
    }


    function getStructHash(NFTSell2 memory _permit)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    "NFTSell(address winery,address seller,uint256 tokenId,uint256 price)",
                    _permit.winery,
                    _permit.seller,
                    _permit.tokenId,
                    _permit.price
                )
            );
    }

    // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
    function getTypedDataHash(NFTSell2 memory _permit)
        public
        view
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    getStructHash(_permit)
                )
            );
    }

}


// contract SigUtils {
//     bytes32 internal DOMAIN_SEPARATOR = 0x51578850e098d13a094707a5ac92c49e129a0105cf9dd73242d806c6226cb33b;

//     // constructor(bytes32 _DOMAIN_SEPARATOR) {
//     //     DOMAIN_SEPARATOR = _DOMAIN_SEPARATOR;
//     // }

//     // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
//     bytes32 public constant PERMIT_TYPEHASH =
//         0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

//     struct Permit {
//         address owner;
//         address spender;
//         uint256 value;
//         uint256 nonce;
//         uint256 deadline;
//     }
//     struct NFTSell {
//         address winery;
//         address seller;
//         uint256 tokenId;
//         uint256 price;
//         bytes signature; 
//     }
//     struct NFTSell2 {
//         address winery;
//         address seller;
//         uint256 tokenId;
//         uint256 price;
//     }


//     // computes the hash of a permit
//     function getStructHash(NFTSell2 memory _permit)
//         internal
//         pure
//         returns (bytes32)
//     {
//         return
//             keccak256(
//                 abi.encode(
//                     "function buyNFT(Struct.NFTSell calldata sell)",
//                     _permit.winery,
//                     _permit.seller,
//                     _permit.tokenId,
//                     _permit.price
//                 )
//             );
//     }

//     // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
//     function getTypedDataHash(Permit memory _permit)
//         public
//         view
//         returns (bytes32)
//     {
//         return
//             keccak256(
//                 abi.encodePacked(
//                     "\x19\x01",
//                     DOMAIN_SEPARATOR,
//                     getStructHash(_permit)
//                 )
//             );
//     }
// }
