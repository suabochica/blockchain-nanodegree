pragma solidity ^0.5.0;

import "./ERC721Mintable.sol";

// ✅ define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class
contract SolnSquareVerifier is ERC721Mintable {
    Verifier private verifierContract;

    // ✅ define a solutions struct that can hold an index & an address
    struct Solution {
        bool minted;
        uint256 solutionIndex;
        address solutionAddress;
    }

    // ✅ define an array of the above struct
    uint256 numberOfSolutions = 0;
    Solution[] private solutions;

    // ✅ define a mapping to store unique solutions submitted
    mapping(bytes32 => Solution) solutions;

    // ✅ Create an event to emit when a solution is added
    event SolutionAdded(uint256 solutionIndex, address indexed solutionAddress);

    constructor(address verifierContractAddress) public {
        verifierContract = Verifier(verifierContractAddress);
    }

    function hash(
        uint256[2] memory a,
        uint256[2] memory a_p,
        uint256[2][2] memory b,
        uint256[2] memory b_p,
        uint256[2] memory c,
        uint256[2] memory c_p,
        uint256[2] memory h,
        uint256[2] memory k,
        uint256[2] memory input
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(a, a_p, b, b_p, c, c_p, h, k, input));
    }

    // ✅ Create a function to add the solutions to the array and emit the event
    function addSolution(
        uint256 index,
        address solvedBy,
        bytes32 solutionHash
    ) public {
        Solution memory solution = Solution(index, solvedBy);
        solutions.push(solution);
        uniqueSolutions[solutionHash] = solution;

        emit SolutionAdded(index, solvedBy);
    }

    // ✅ Create a function to mint new NFT only after the solution has been verified
    //  - make sure the solution is unique (has not been used before)
    //  - make sure you handle metadata as well as tokenSuplly
    function mintNewToken(
        address to,
        uint256 tokenId,
        uint256[2] memory a,
        uint256[2] memory a_p,
        uint256[2][2] memory b,
        uint256[2] memory b_p,
        uint256[2] memory c,
        uint256[2] memory c_p,
        uint256[2] memory h,
        uint256[2] memory k,
        uint256[2] memory input
    ) public returns (bool) {
        bytes32 solutionHash = hash(a, a_p, b, b_p, c, c_p, h, k, input);
        bool verified = verifierContract.verifyTx(
            a,
            a_p,
            b,
            b_p,
            c,
            c_p,
            h,
            k,
            input
        );
        require(verified, "Solution not verified (zero Knowledge Proof check)");
        require(
            uniqueSolutions[solutionHash].solvedBy == address(0),
            "Solution has already been used before"
        );
        addSolution(tokenId, to, solutionHash);

        return mint(to, tokenId);
    }
}

// ✅ define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
contract Verifier {
    function verifyTransaction(
        uint256[2] memory A,
        uint256[2] memory A_p,
        uint256[2] memory B,
        uint256[2] memory B_p,
        uint256[2] memory C,
        uint256[2] memory C_p,
        uint256[2] memory H,
        uint256[2] memory K,
        uint256[2] memory input
    ) public returns (bool response);
}
