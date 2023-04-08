// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract StringOperations {

    function findLength(string memory s) public pure returns (uint256) {
        return bytes(s).length;
    }

    function findAtIndex(string calldata s, uint256 i) public pure returns (bytes1 ) {
        return bytes(s)[i];
    }

    function replaceAllOccurence(string calldata s, string calldata x, string calldata y ) public pure returns(string memory) {
        bytes1 originalCharacter = bytes(x)[0];
        bytes1 replacementCharacter = bytes(y)[0];

        bytes memory originalString = bytes(s);

        for (uint256 i = 0; i < originalString.length; i++) {
            if(originalString[i] == originalCharacter) {
                originalString[i] = replacementCharacter;
            }
        }

        return string(originalString);
    }
}