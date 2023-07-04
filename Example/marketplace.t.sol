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
    marketPlace public market;
    marketPlace public market2;
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

    function testShouldNotWork()public{
        market.initialize(address(nft),users[0],address(usdc));
    }

    function testaddress() public {

        emit log_address(address(market));
        emit log_address(address(nft));
        emit log_address(address(usdc));        
     
    }

    function testinitialize() public 
    {
        market.initialize(
         address(nft),
         users[0],
         address(usdc)
        );
    }

    function testinitialize_zeroAddressNFT() public
    {   vm.expectRevert(abi.encodePacked("ZA"));
        market.initialize(address(0),users[0],
         address(usdc));
    }

     function testinitialize_zeroAddressAdmin() public
    {   vm.expectRevert(abi.encodePacked("ZA"));
        market.initialize(address(nft),address(0),
         address(usdc));
    }

    function testinitialize_zeroAddressUSDC() public
    {   vm.expectRevert(abi.encodePacked("ZA"));
        market.initialize(address(nft),users[0],
         address(0));
    }

     function testinitialize_zeroAddressAll() public
    {   vm.expectRevert(abi.encodePacked("ZA"));
        market.initialize(address(0),address(0),
         address(0));
    }


    function testcreateNFT() public
    {  

        vm.startPrank(users[0]);
        Struct.NFTData memory t1 = Struct.NFTData({ winery:users[1],releaseDate: 1671690768,amount:11,royaltyAmount:10,URI:"NFTOne" });
        market.createNFT(t1);
        uint balance = nft.balanceOf(users[1]);
        assertEq(balance, 11);
        vm.stopPrank();

    }

    function testcreateNFT_onlyAdmin() public
    {
         
        Struct.NFTData memory t1 = Struct.NFTData({ winery:users[1],releaseDate: 1671690768,amount:11,royaltyAmount:10,URI:"NFTOne" });
        vm.expectRevert(abi.encodePacked("NA"));
        market.createNFT(t1);

    }

    function testCreatNFTRevert()public{
        vm.startPrank(users[0]);
        Struct.NFTData memory t1 = Struct.NFTData({winery:0x0000000000000000000000000000000000000000,releaseDate: 1671690768,amount:11,royaltyAmount:10,URI:"NFTOne"});
        vm.expectRevert(abi.encodePacked("ZA"));
        market.createNFT(t1);
        vm.stopPrank();
    }

 
    function testBuyNFTprimary() public // primary sell 
    {
        testcreateNFT();
      
       
        // vm.stopPrank();
        vm.startPrank(users[1]);
         nft.setApprovalForAll(address(market), true);

        vm.stopPrank();
        
        vm.startPrank(users[2]);
        usdc.approve(address(market), 1000000);
        uint[] memory arr = new uint[](3);
        arr[0] = 1;
        arr[1] = 2;
        arr[2] = 3;
        Struct.NFTSell memory t2 = Struct.NFTSell({winery:users[1],seller:users[1],tokenIds: arr ,price:100,amount: 3});
        market.buyNFT(t2,3);
        uint balance = usdc.balanceOf(users[0]);
        assertEq(balance, 300);
        address _owner = nft.ownerOf(1);
        assertEq(_owner, users[2]);
        address _owner2 = nft.ownerOf(2);
        assertEq(_owner2, users[2]);
        address _owner3 = nft.ownerOf(3);
        assertEq(_owner3, users[2]);

    }

    function testBuyNFTrevert_AS() public{

        testcreateNFT();
        vm.startPrank(users[1]);
        nft.setApprovalForAll(address(market), true);
        vm.stopPrank();
        
        vm.startPrank(users[2]);
        usdc.approve(address(market), 1000000);
        uint[] memory arr = new uint[](3);
        arr[0] = 1;
        arr[1] = 2;
        arr[2] = 3;
        Struct.NFTSell memory t2 = Struct.NFTSell({winery:users[1],seller:users[1],tokenIds: arr ,price:100,amount: 3});
        market.buyNFT(t2,2);
        vm.stopPrank();
        vm.startPrank(users[3]);
        usdc.approve(address(market), 1000000);
        market.buyNFT(t2,1);
         address _owner = nft.ownerOf(1);
        assertEq(_owner, users[2]);
        address _owner2 = nft.ownerOf(2);
        assertEq(_owner2, users[2]);
        address _owner3 = nft.ownerOf(3);
        assertEq(_owner3, users[3]);
        vm.expectRevert(abi.encodePacked("AS"));
        
        market.buyNFT(t2,1);


    }
    
    function testBuyNFTseller_ZA() public 
    {
        testcreateNFT();
      
       
        // vm.stopPrank();
        vm.startPrank(users[1]);
         nft.setApprovalForAll(address(market), true);

        vm.stopPrank();
        
        vm.startPrank(users[2]);
        usdc.approve(address(market), 1000000);
        uint[] memory arr = new uint[](3);
        arr[0] = 1;
        arr[1] = 2;
        arr[2] = 3;
        Struct.NFTSell memory t2 = Struct.NFTSell({winery:users[1],seller:address(0),tokenIds: arr ,price:100,amount: 3});
         vm.expectRevert(abi.encodePacked("ZA"));
        market.buyNFT(t2,3);

    }

    function testBuyNFTwinery_ZA() public 
    {
        testcreateNFT();
      
       
        // vm.stopPrank();
        vm.startPrank(users[1]);
         nft.setApprovalForAll(address(market), true);

        vm.stopPrank();
        
        vm.startPrank(users[2]);
        usdc.approve(address(market), 1000000);
        uint[] memory arr = new uint[](3);
        arr[0] = 1;
        arr[1] = 2;
        arr[2] = 3;
        Struct.NFTSell memory t2 = Struct.NFTSell({winery:address(0),seller:users[1],tokenIds: arr ,price:100,amount: 3});
         vm.expectRevert(abi.encodePacked("ZA"));
        market.buyNFT(t2,3);

    }



    // function testBuyNFTsecondary() public//secondary sell
    // {
    //   testBuyNFTprimary();
    //   vm.stopPrank();
    //     vm.startPrank(users[2]);
    //      nft.setApprovalForAll(address(market), true);

    //     vm.stopPrank();
      
    //   vm.startPrank(users[3]);
    //   usdc.approve(address(market), 100000);
    //     uint[] memory arr2 = new uint[](3);
    //     arr2[0] = 1;
    //     arr2[1] = 2;
    //     arr2[2] = 3;
    //     Struct.NFTSell memory t3 = Struct.NFTSell({winery:users[1],seller:users[2],tokenIds: arr2 ,price:200,amount: 1});
    //     vm.stopPrank();
    //     vm.warp(1669185853);
        
    
    //     vm.startPrank(users[0]);
    //     Struct.planDetails memory p1 = Struct.planDetails({months:10520000,price:50});
    //     market.createPlan(p1);
    //     vm.stopPrank();
    //     vm.startPrank(users[2]);
        
    //     usdc.approve(address(market),100000000);
    //     vm.warp(1689183652);
    //     console.log("before buy storage");
    //     market.buyStorage(1,1);
    //     console.log("after buy storage");
    //     vm.stopPrank();
    //     vm.startPrank(users[3]);
    //     console.log("before buyNFT");
    //     market.buyNFT(t3,1);
    //      console.log("after buyNFT");
    //     uint balance_of_admin = usdc.balanceOf(users[0]);
    //     assertEq(balance_of_admin, 370);
    //     uint balance_of_seller = usdc.balanceOf(users[2]);
    //     assertEq(balance_of_seller,29790);
    //     address _owner_after_sec = nft.ownerOf(1);
    //     assertEq(_owner_after_sec, users[3]);
    //     address _owner2_after_sec = nft.ownerOf(2);
    //     assertEq(_owner2_after_sec, users[2]);
    //     address _owner3_after_sec = nft.ownerOf(3);
    //     assertEq(_owner3_after_sec, users[2]);
        
    // }

    function testcreatePlan() public 
    {
      vm.startPrank(users[0]);
      Struct.planDetails memory p1 = Struct.planDetails({months:10520000,price:50 });
      market.createPlan(p1);
    }

    function testCreatPlanReverts()public{
      vm.startPrank(users[0]);
      Struct.planDetails memory p1 = Struct.planDetails({months:0,price:50 });
      vm.expectRevert(abi.encodePacked("IV"));
      market.createPlan(p1);
    }

    function testCreatPlanReverts2()public{
      vm.startPrank(users[0]);
      Struct.planDetails memory p1 = Struct.planDetails({months:4,price:0 });
      vm.expectRevert(abi.encodePacked("IV"));
      market.createPlan(p1);
    }

    function testchangereleaseDate() public
    {
        testcreateNFT();
        vm.startPrank(users[0]);
        market.changereleaseDate(1,1677470833);
        market.changereleaseDate(2,1679890033);
        market.changereleaseDate(3,1679890033);
    }


    function testchangereleaseDate_OnlyAdmin() public
    {
        testcreateNFT();
        vm.expectRevert(abi.encodePacked("NA"));
        market.changereleaseDate(1,1677470833);
        vm.expectRevert(abi.encodePacked("NA"));
        market.changereleaseDate(2,1679890033);
        vm.expectRevert(abi.encodePacked("NA"));
        market.changereleaseDate(3,1679890033);
    }

    function testChangeReleaseDateRevert()public{
        testcreateNFT();
        vm.startPrank(users[0]);
        vm.expectRevert(abi.encodePacked("ID"));
        market.changereleaseDate(1,177470833);
    }

    function testrenewstorage() public 
    {
        testcreateNFT();
        vm.startPrank(users[0]);
        
        Struct.planDetails memory p1 = Struct.planDetails({months:4,price:50});
        market.createPlan(p1);
        market.renewStorage(1, 1);
    }

    function testrenewstorage_onlyAdmin() public{
     testcreateNFT();
      vm.startPrank(users[0]);
      Struct.planDetails memory p1 = Struct.planDetails({months:4,price:50 });
       market.createPlan(p1);
      vm.stopPrank();
      vm.startPrank(users[1]);
      vm.expectRevert(abi.encodePacked("NA"));
      market.renewStorage(1, 1);
    }

    function testcreateplan_onlyAdmin() public
    {
      testcreateNFT();
      vm.startPrank(users[1]);
      Struct.planDetails memory p1 = Struct.planDetails({months:4,price:50 });
      vm.expectRevert(abi.encodePacked("NA"));
       market.createPlan(p1);    
    }

    function testbuyStorage() public
    
    {
        vm.warp(1669185853);
        testcreateNFT();
        vm.startPrank(users[0]);
        Struct.planDetails memory p1 = Struct.planDetails({months:10520000,price:50});
        market.createPlan(p1);
        vm.stopPrank();
        vm.startPrank(users[4]);
        address owner_ = nft.ownerOf(1);
        assertEq(owner_, users[1]);
        usdc.approve(address(market),100000000000000000);
        vm.warp(1689183652);
        market.buyStorage(1,1);
    }


}
