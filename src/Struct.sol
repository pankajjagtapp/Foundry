//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

library Struct {
    struct NFTVoucher {
        uint256 minPrice;
        string uri;
        bytes signature;
    }
}