// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/*
EIP 1014: Creation of Create2 Opcode by Vitalik Buterin

Create2 Opcode -

1) Get bytecode of contract to be deployed
2) Compute the address of the contract to be deployed
3) Deploy the contract using Create2

*/
contract Factory {
    event Deployed(address addr, uint256 salt);

    // 1. Get Bytecode of the contract to be deployed
    function getByteCode(address _owner, uint256 _num)
        internal
        pure
        returns (bytes memory)
    {
        // wrap test contract in a type and call creation code property.
        // (Get the bytecode of the contract that is going to be deployed in advance.)

        bytes memory bytecode = type(Test).creationCode;

        // append data to be consumed by the constructor.
        // If the constructor doesn't take arguments elsewhere, no need to do the below step.

        return abi.encodePacked(bytecode, abi.encode(_owner, _num));
    }

    // 2. Compute the address of the contract to be deployed

    function getAddress(
        address _owner,
        uint256 _num,
        uint256 _salt
    ) public view returns (address) {
        bytes memory _bytecode = getByteCode(_owner, _num);
        bytes32 _hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(_bytecode)
            )
        );
        // Call last 20 bytes of hash to address
        return address(uint160(uint256(_hash)));
    }

    // 3. Deploy the contract using Create2
    function deployCreate2(
        address _owner,
        uint256 _num,
        uint256 _salt
    ) external payable {
        // 1. Get bytecode of the contract to be deployed
        bytes memory bytecode = getByteCode(_owner, _num);
        address addr;

        /*
        create2(v,p,n,s);

        v - amount of ether to send
        p - pointer to start of code in memory 
       `n - size of code
        s - salt
        */
        assembly {
            addr := create2(
                callvalue(), // wei sent with the current call
                add(bytecode, 32), // Actual code starts after skipping first 32 bytes - first 32 bytes stores the size of the code
                mload(bytecode), // load the size of the code contained in the first 32 bytes
                _salt // an arbitray value provided by the user
            )

            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }
        emit Deployed(addr, _salt);
    }
}



contract Test {

    address public owner;
    uint public num;

    constructor(address _owner, uint _num) {
        owner = _owner;
        num = _num;
    }

}
