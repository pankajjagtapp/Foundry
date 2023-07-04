// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";
import {wineNFT} from "../NFTContract.sol";
import {marketPlace} from "../marketPlace.sol";
import {Usdc} from "../mock/USDC.sol";
import "../libraries/structLib.sol";

contract NFTContractTest is DSTest {
    wineNFT public NFTContract;
    marketPlace public marketPlaceContract;
    Usdc public usdcContract;

    Vm internal immutable vm = Vm(HEVM_ADDRESS);
    Utilities internal utils;
    address payable[] internal users;
    address internal wineryAddress;

    function setUp()public{
        utils = new Utilities();
        users = utils.createUsers(10);
        wineryAddress = users[5];

        NFTContract = new wineNFT();
        marketPlaceContract = new marketPlace();
        usdcContract = new Usdc();

        NFTContract.initialize(address(marketPlaceContract),users[0]);
        marketPlaceContract.initialize(address(NFTContract),users[0],address(usdcContract));
    }

    // function testinitialize_zeroAddress() public
    // {
    //   NFTContract.initialize(address(0),address(0));
    // }

    function testSetInitialize()public{
        vm.expectRevert(abi.encodePacked("AI"));
        NFTContract.initialize(address(marketPlaceContract),users[0]);
    }

    function testBulkMint() public {

        vm.startPrank(address(marketPlaceContract));

        Struct.NFTData memory bulkMintStruct = Struct.NFTData({ winery:wineryAddress,releaseDate: 1671690668,amount:10,royaltyAmount:10,URI:"NFTOne"});
        NFTContract.bulkMint(bulkMintStruct);
        assertEq(NFTContract.balanceOf(wineryAddress),10);
        assertEq(NFTContract.checkDeadline(1),1679580668);

        vm.stopPrank();
    }

    function testBulkMintReverts()public{
        Struct.NFTData memory bulkMintStruct = Struct.NFTData({ winery:wineryAddress,releaseDate: 1671690668,amount:10,royaltyAmount:10,URI:"NFTOne"});
        vm.expectRevert(abi.encodePacked("IC"));
        NFTContract.bulkMint(bulkMintStruct);
    }

    function testBulkMintBug()public{
        vm.startPrank(address(marketPlaceContract));

        Struct.NFTData memory bulkMintStruct = Struct.NFTData({ winery:wineryAddress,releaseDate: 1569101112,amount:10,royaltyAmount:10,URI:"NFTOne"});
        NFTContract.bulkMint(bulkMintStruct);  

        vm.stopPrank();
    }

    function testMultipleBulkMints()public{

        testBulkMint();
        vm.startPrank(address(marketPlaceContract));

        Struct.NFTData memory bulkMintStruct = Struct.NFTData({ winery:wineryAddress,releaseDate: 1671690768,amount:15,royaltyAmount:11,URI:"NFTTwo"});
        NFTContract.bulkMint(bulkMintStruct);
        assertEq(NFTContract.balanceOf(wineryAddress),25);
        assertEq(NFTContract.checkDeadline(15),1679580768);
        // assertEq(NFTContract.checkReleaseDate(15),1671690768);

        vm.stopPrank();
    }

    function testIncreaseDeadline() public{
        testBulkMint();
        vm.startPrank(address(marketPlaceContract));

        NFTContract.increaseDeadline(5,5000);
        assertEq(NFTContract.checkDeadline(5),1679580668+5000);
        assertEq(NFTContract.checkDeadline(4),1679580668);

        vm.stopPrank();
    }

    function testIncreaseDeadline_OnlyOperator() public{
        testBulkMint();
        vm.expectRevert(abi.encodePacked("IC"));
        NFTContract.increaseDeadline(5,5000);
    }

    
    function testIncreaseDeadlineRevert()public{
        testBulkMint();
        vm.startPrank(address(marketPlaceContract));
        vm.expectRevert(abi.encodePacked("IT"));
        NFTContract.increaseDeadline(50,5000);
        vm.stopPrank();
    }

    
    function testChangeReleaseDate()public
    {
        testBulkMint();
        vm.startPrank(address(marketPlaceContract));
        NFTContract.changeReleaseDate(5,1672000000);
        vm.stopPrank();
    }

    
    function testChangeReleaseDate_onlyOperator() public
    {   
       testBulkMint();
       vm.expectRevert(abi.encodePacked("IC"));
       NFTContract.changeReleaseDate(5,1672000000);

    }

    function testChangeReleaseDateRevert()public{
        testBulkMint();

        vm.startPrank(address(marketPlaceContract));
        vm.expectRevert(abi.encodePacked("ID"));
        NFTContract.changeReleaseDate(5,1671690568);

        vm.stopPrank();
    }

    function testSetDeadline()public{
        testBulkMint();
        console.log(NFTContract.checkDeadline(1));
        vm.startPrank(address(marketPlaceContract));
        NFTContract.setDeadline(5,1771690568);
        assertEq(NFTContract.checkDeadline(5),1771690568);
    }

    function testSetDeadline_OnlyOperator() public 
    {
        testBulkMint();
        console.log(NFTContract.checkDeadline(1));
        vm.expectRevert(abi.encodePacked("IC"));
        NFTContract.setDeadline(5,1771690568);
    
    }

    function testsetDeadlineBug() public
    {
         testBulkMint();
        console.log(NFTContract.checkDeadline(1));
        vm.startPrank(address(marketPlaceContract));
        NFTContract.setDeadline(5,0);
        assertEq(NFTContract.checkDeadline(5),0);
    }


    

}
