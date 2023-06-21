pragma solidity >=0.8.0;

// SPDX-License-Identifier: UNLICENSED


contract VotingContract {

    // Contract's Owner address
    address public owner;

    // Relate candidate's name and its personal data hash.
    mapping (string => bytes32) candidateId;

    // Relate candidate's name and votes count.
    mapping (string => uint) candidateVotes;

    // Candidates list.
    string[] candidates;

    // Voters list as hashes to keep voter info private.
    bytes32[] votants;


    constructor() {

        // Set owner to contract deployer.
        owner = msg.sender;

    }


    // Lets everyone be proposed as a candidate.
    function representate(string memory _candidateName, uint _age, string memory _candidateId) public {

        // Get candidate's data hash.
        bytes32 _candidateHash = keccak256(abi.encodePacked(_candidateName, _age, _candidateId));

        // Store candidate's hash.
        candidateId[_candidateName] = _candidateHash;

        // Update candidates array.
        candidates.push(_candidateName);

    }

    // Get candidates list.
    function getCandidates() public view returns (string[] memory) {
        return candidates;
    }

    // Vote function.
    function vote(string memory _candidateName) public onlyOnce {
        candidateVotes[_candidateName] ++;
    }

    // Check that voter is not voting twice.
    modifier onlyOnce() {

        // Calculate voter's hash.
        bytes32 _votantHash = keccak256(abi.encodePacked(msg.sender));

        // Check if votant has voted before.
        for(uint256 i = 0; i < votants.length; i++) {
            require(votants[i] != _votantHash, "Voter has already voted.");
        }

        // Add votant's hash to votants array.
        votants.push(_votantHash);

        _;
    }

    // Get candidate votes.
    function getCandidateVotes(string memory _candidateName) public view returns (uint) {
        return candidateVotes[_candidateName];
    }

    // Get vote winnner.
    function getVoteResult() public view returns(string memory) {

        // Get candidates result.
        string memory _result = "";

        // Get result.
        for(uint i = 0; i < candidates.length; i++) {
            _result = string(abi.encodePacked(_result, "( ", candidates[i], ", ", uint2str(getCandidateVotes(candidates[i])), " ) "));
        }

        return _result;

    }

    // Cast from Uint to String
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    // Get Vote Winner.
    function winner() public view returns (string memory) {

        require(candidates.length > 0, "Not enough candidates.");

        // Winner variable with its name.
        string memory _winner = candidates[0];

        // Draw flag.
        bool flag;

        for (uint i = 1; i < candidates.length; i++) {

            if (candidateVotes[candidates[i]] > candidateVotes[_winner]) {

                _winner = candidates[i];
                flag = false;

            } else if (candidateVotes[candidates[i]] == candidateVotes[_winner]) {

                flag = true;

            }

        }

        // If draw, return a draw.
        if (flag) {
            _winner = "There was a Draw";
        }

        return _winner;
    }

}