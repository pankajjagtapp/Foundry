pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract MyContract {
    using ECDSA for bytes32;

    struct MyMessage {
        uint256 value;
        address to;
    }

    bytes32 private constant DOMAIN_SEPARATOR = keccak256(abi.encode(
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
        keccak256(bytes("MyContract")),
        keccak256(bytes("1")),
        block.chainid,
        address(this)
    ));

    bytes32 private constant MY_MESSAGE_TYPEHASH = keccak256("MyMessage(uint256 value,address to)");

    function sign(MyMessage memory message) external view returns (bytes memory) {
        bytes32 messageHash = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(
                MY_MESSAGE_TYPEHASH,
                message.value,
                message.to
            ))
        ));
        return abi.encodePacked(messageHash.toEthSignedMessageHash().recover(msg.sender));
    }
}
