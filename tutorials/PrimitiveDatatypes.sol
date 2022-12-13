// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract PrimitiveDatatypes {
    bool public boolean = true;
    uint8 u8 = 4;
    int8 i8 = -4;
    uint16 u16 = 200;
    uint u256 = 1000;

    int public minInt = type(int).min;
    int public maxInt = type(int).max;

    address public addr = 0x617F2E2fD72FD9D5503197092aC168c91465E7f2;

}