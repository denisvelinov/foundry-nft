//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC721} from "../lib/openzepplin-contracts/contracts/token/ERC721/ERC721.sol";
import {Base64} from "../lib/openzepplin-contracts/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    //errors
    error MoodNft_CantFlipMoodIfNotOwner();

    uint256 private s_tokenCounter;
    string private s_happySvgImageURI;
    string private s_sadSvgImageURI;

    enum Mood {
        HAPPY,
        SAD
    }

    mapping(uint256 => Mood) private s_tokenIdToMood;

    constructor(
        string memory happySvgImageURI,
        string memory sadSvgImageURI
    ) ERC721("Mood NFT", "MN") {
        s_tokenCounter = 0;
        s_happySvgImageURI = happySvgImageURI;
        s_sadSvgImageURI = sadSvgImageURI;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
        s_tokenCounter++;
    }

    function flipMood(uint256 tokenID) public {
        if (!_isApprovedOrOwner(msg.sender, tokenID)) {
            revert MoodNft_CantFlipMoodIfNotOwner();
        }
        if (s_tokenIdToMood[tokenID] == Mood.HAPPY) {
            s_tokenIdToMood[tokenID] = Mood.SAD;
        } else {
            s_tokenIdToMood[tokenID] = Mood.HAPPY;
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        string memory imageURI;
        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            imageURI = s_happySvgImageURI;
        } else {
            imageURI = s_sadSvgImageURI;
        }

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(),
                                '","description": "An NFT thet reflects the owners mood.", "attributes": [{"trait_type": "moodiness", "value": 100}], "image": "',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
