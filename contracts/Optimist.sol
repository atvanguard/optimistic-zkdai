pragma solidity ^0.4.25;

interface Optimist {
    function submit() external payable;
    function challenge() external;
}