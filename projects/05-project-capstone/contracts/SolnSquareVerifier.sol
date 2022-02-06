// // Solution Square Verifier
// pragma solidity >=0.4.21 <0.6.0;

// // ✅ define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
// import "./ERC721Mintable.sol";
// import "./Verifier.sol";
// import "openzeppelin-solidity/contracts/math/SafeMath.sol";

// // ✅ define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class
// contract SolnSquareVerifier is ERC721Mintable {
//     Verifier private verifierContract;

//     // ✅ define a solutions struct that can hold an index & an address
//     struct Solution {
//         uint256 index;
//         address solvedBy;
//     }

//     // ✅ define an array of the above struct
//     uint256 numberOfSolutions = 0;
//     Solution[] private solutions;

//     // ✅ define a mapping to store unique solutions submitted
//     mapping(bytes32 => Solution) uniqueSolutions;

//     // ✅ Create an event to emit when a solution is added
//     event SolutionAdded(uint256 solutionIndex, address indexed solutionAddress);

//     constructor(address verifierContractAddress) public {
//         verifierContract = Verifier(verifierContractAddress);
//     }

//     function hash(
//         uint256[2] memory a,
//         uint256[2] memory a_p,
//         uint256[2][2] memory b,
//         uint256[2] memory b_p,
//         uint256[2] memory c,
//         uint256[2] memory c_p,
//         uint256[2] memory h,
//         uint256[2] memory k,
//         uint256[2] memory input
//     ) public pure returns (bytes32) {
//         return keccak256(abi.encodePacked(a, a_p, b, b_p, c, c_p, h, k, input));
//     }

//     // ✅ Create a function to add the solutions to the array and emit the event
//     function addSolution(
//         uint256 index,
//         address solvedBy,
//         bytes32 solutionHash
//     ) public {
//         Solution memory solution = Solution(index, solvedBy);
//         solutions.push(solution);
//         uniqueSolutions[solutionHash] = solution;

//         emit SolutionAdded(index, solvedBy);
//     }

//     // ✅ Create a function to mint new NFT only after the solution has been verified
//     //  - make sure the solution is unique (has not been used before)
//     //  - make sure you handle metadata as well as tokenSuplly
//     function mintNewToken(
//         address to,
//         uint256 tokenId,
//         uint256[2] memory a,
//         uint256[2] memory a_p,
//         uint256[2][2] memory b,
//         uint256[2] memory b_p,
//         uint256[2] memory c,
//         uint256[2] memory c_p,
//         uint256[2] memory h,
//         uint256[2] memory k,
//         uint256[2] memory input
//     ) public {
//         bytes32 solutionHash = hash(a, a_p, b, b_p, c, c_p, h, k, input);
//         bool verified = verifierContract.verifyTx(
//             a,
//             a_p,
//             b,
//             b_p,
//             c,
//             c_p,
//             h,
//             k,
//             input
//         );
//         require(verified, "Solution not verified (zero Knowledge Proof check)");
//         require(
//             uniqueSolutions[solutionHash].solvedBy == address(0),
//             "Solution has already been used before"
//         );
//         addSolution(tokenId, to, solutionHash);

//         return mint(to, tokenId);
//     }
// }
// Solution Square Verifier
pragma solidity >=0.4.21 <0.6.0;

// TODO define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
import "./ERC721Mintable.sol";
import "./Verifier.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

// TODO define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class
contract SolnSquareVerifier is ERC721Mintable, Verifier {
    struct Solution {
        bool isUsed;
        address verifierAddress;
    }
    uint256 solutionCount = 0;
    mapping(bytes32 => Solution) private uniqueSolutions;

    event SolutionAdded(bytes32 key, address verifierAddress);

    function addSolution(bytes32 solutionKey, address verifierAddress)
        internal
    {
        require(!uniqueSolutions[solutionKey].isUsed, "Solution is not unique");
        solutionCount = solutionCount.add(1);
        uniqueSolutions[solutionKey].isUsed = true;
        uniqueSolutions[solutionKey].verifierAddress = verifierAddress;
        emit SolutionAdded(solutionKey, verifierAddress);
    }

    function mintVerify(
        address to,
        uint256 tokenId,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory inputs
    ) public {
        bytes32 key = keccak256(abi.encodePacked(a, b, c, inputs));
        require(!uniqueSolutions[key].isUsed, "Solution is not unique");
        require(verifyTx(a, b, c, inputs), "Proof is not valid");
        addSolution(key, msg.sender);
        super.mint(to, tokenId);
    }
}
