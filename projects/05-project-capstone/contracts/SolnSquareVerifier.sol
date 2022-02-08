// Solution Square Verifier
pragma solidity >=0.4.21 <0.6.0;

// ✅ define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
import "./ERC721Mintable.sol";
import "./Verifier.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

// ✅ define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class
contract SolnSquareVerifier is ERC721Mintable, Verifier {
    // ✅ define a solutions struct that can hold an index & an address
    struct Solution {
        bool isUsed;
        address verifierAddress;
    }
    // ✅ define an array of the above struct
    uint256 solutionCount = 0;
    // ✅ define a mapping to store unique solutions submitted
    mapping(bytes32 => Solution) private uniqueSolutions;

    // ✅ Create an event to emit when a solution is added
    event SolutionAdded(bytes32 key, address verifierAddress);

    // ✅ Create a function to add the solutions to the array and emit the event
    function addSolution(bytes32 solutionKey, address verifierAddress)
        internal
    {
        require(!uniqueSolutions[solutionKey].isUsed, "Solution is not unique");
        solutionCount = solutionCount.add(1);
        uniqueSolutions[solutionKey].isUsed = true;
        uniqueSolutions[solutionKey].verifierAddress = verifierAddress;
        emit SolutionAdded(solutionKey, verifierAddress);
    }

    // ✅ Create a function to mint new NFT only after the solution has been verified
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
