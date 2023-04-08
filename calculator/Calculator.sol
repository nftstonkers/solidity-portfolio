// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract Calculator {

    /**
     * 
     * @param firstInput First Integer
     * @param secondInput Second Integer
     * Returns sum of the two inputs
     */
    function add(int256 firstInput, int256 secondInput) public pure returns (int256) {
        return (firstInput + secondInput);
    }

    function subtract(int256 firstInput, int256 secondInput) public pure returns (int256) {
        return (firstInput - secondInput);
    }

    function multiply(int256 firstInput, int256 secondInput) public pure returns (int256) {
        return (firstInput * secondInput);
    }

    function divide(int256 firstInput, int256 secondInput) public pure returns (int256) {
        return ((firstInput* (10**18)) / secondInput);
    }

    function modulo(int256 firstInput, int256 secondInput) public pure returns (int256) {
        return (firstInput / secondInput);
    }

}