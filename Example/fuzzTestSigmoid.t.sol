// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";
import {wineNFT} from "../NFTContract.sol";
import {marketPlace} from "../marketPlace.sol";
import {Usdc} from "../mock/USDC.sol";
import {SigmoidFormula} from "../fuzzTest.sol";
import "../libraries/structLib.sol";

contract NFTContractTest is DSTest {
    // wineNFT public NFTContract;
    // marketPlace public marketPlaceContract;
    // Usdc public usdcContract;
    SigmoidFormula public sigmoidFormula;

    Vm internal immutable vm = Vm(HEVM_ADDRESS);
    Utilities internal utils;
    address payable[] internal users;
    address internal wineryAddress;

    function setUp()public{
        utils = new Utilities();
        users = utils.createUsers(10);
        wineryAddress = users[5];

        // NFTContract = new wineNFT();
        sigmoidFormula = new SigmoidFormula();
    }

    function testContract(uint256 a,uint256 b,uint256 c)public{
        uint256 ret = sigmoidFormula.calculatePurchaseReturnContinousToken(a, b, c);
        console.log("----------------------------------------------",ret);
    }
}