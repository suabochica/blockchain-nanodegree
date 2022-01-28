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
    // Solution[] private solutions;

    // ✅ define a mapping to store unique solutions submitted
    mapping(bytes32 => Solution) solutions;

    // ✅ Create an event to emit when a solution is added
    event SolutionAdded(uint256 solutionIndex, address indexed solutionAddress);

    constructor(
        address verifierAddress,
        string memory name,
        string memory symbol
    ) public ERC721Mintable(name, symbol) {
        verifierContract = Verifier(verifierAddress);
    }

    // ✅ Create a function to add the solutions to the array and emit the event
    function addSolution(
        uint256[2] memory A,
        uint256[2] memory A_p,
        uint256[2] memory B,
        uint256[2] memory B_p,
        uint256[2] memory C,
        uint256[2] memory C_p,
        uint256[2] memory H,
        uint256[2] memory K,
        uint256[2] memory input
    ) public {
        bytes32 solutionHash = keccak256(abi.encodePacked(input[0], input[1]));
        require(
            solutions[solutionHash].solutionAddress == address(0),
            "Solution address already exists"
        );

        bool verified = verifierContract.verifyTransaction(
            A,
            A_p,
            B,
            B_p,
            C,
            C_p,
            H,
            K,
            input
        );
        require(verified, "Solution could not be verified");

        solutions[solutionHash] = Solution(
            false,
            numberOfSolutions,
            msg.sender
        );
        // solutions.push(solution);

        emit SolutionAdded(numberOfSolutions, msg.sender);
        numberOfSolutions++;
    }

    // ✅ Create a function to mint new NFT only after the solution has been verified
    //  - make sure the solution is unique (has not been used before)
    //  - make sure you handle metadata as well as tokenSuplly
    function mintNewNFT(
        uint256 a,
        uint256 b,
        address to
    ) public {
        bytes32 solutionHash = keccak256(abi.encodePacked(a, b));

        require(
            solutions[solutionHash].solutionAddress != address(0),
            "Solution address already exists"
        );
        require(
            solutions[solutionHash].solutionAddress != msg.sender,
            "Only solution address can be use to mint a token"
        );
        require(
            solutions[solutionHash].minted != false,
            "Token is already minted"
        );

        super.mint(to, solutions[solutionHash].solutionIndex);

        solutions[solutionHash].minted = true;
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
