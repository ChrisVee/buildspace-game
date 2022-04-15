// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./libraries/Base64.sol";
import "hardhat/console.sol";

contract MyEpicGame is ERC721 {
    function random(uint256 maxNum) private view returns (uint256) {
        return
            uint256(
                keccak256(abi.encodePacked(block.timestamp, block.difficulty))
            ) % (maxNum + 1);
    }

    function statRoll(uint256 statModifier) private view returns (uint256) {
        return 4 + random(10) + statModifier;
    }

    struct CharacterAttributes {
        uint256 characterIndex;
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
        uint256 strength;
        uint256 luck;
        uint256 charisma;
        uint256 wisdom;
        uint256 intelligence;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    CharacterAttributes[] defaultCharacters;

    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    mapping(address => uint256) public nftHolders;

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint256[] memory characterHp,
        uint256[] memory characterAttackDmg,
        uint256[] memory characterStrengthModifier,
        uint256[] memory characterLuckModifier,
        uint256[] memory characterCharismaModifier,
        uint256[] memory characterWisdomModifier,
        uint256[] memory characterIntelligenceModifier
    ) ERC721("Heroes", "HERO") {
        for (uint256 i = 0; i < characterNames.length; i += 1) {
            defaultCharacters.push(
                CharacterAttributes({
                    characterIndex: i,
                    name: characterNames[i],
                    imageURI: characterImageURIs[i],
                    hp: characterHp[i],
                    maxHp: characterHp[i],
                    attackDamage: characterAttackDmg[i],
                    strength: characterStrengthModifier[i],
                    luck: characterLuckModifier[i],
                    charisma: characterCharismaModifier[i],
                    wisdom: characterWisdomModifier[i],
                    intelligence: characterIntelligenceModifier[i]
                })
            );

            CharacterAttributes memory c = defaultCharacters[i];
            console.log(
                "Done initializing %s w/ HP %s, img %s",
                c.name,
                c.hp,
                c.imageURI
            );
        }
        _tokenIds.increment();
    }

    function mintCharacterNFT(uint256 _characterIndex) external {
        uint256 newItemId = _tokenIds.current();

        _safeMint(msg.sender, newItemId);

        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].hp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage,
            strength: statRoll(defaultCharacters[_characterIndex].strength),
            luck: statRoll(defaultCharacters[_characterIndex].luck),
            charisma: statRoll(defaultCharacters[_characterIndex].charisma),
            wisdom: statRoll(defaultCharacters[_characterIndex].wisdom),
            intelligence: statRoll(
                defaultCharacters[_characterIndex].intelligence
            )
        });

        console.log(
            "Minted NFT w/ tokenId %s and characterIndex %s",
            newItemId,
            _characterIndex
        );

        nftHolders[msg.sender] = newItemId;

        _tokenIds.increment();
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        CharacterAttributes memory charAttributes = nftHolderAttributes[
            _tokenId
        ];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(
            charAttributes.attackDamage
        );
        string memory strStrength = Strings.toString(
            charAttributes.attackDamage
        );
        string memory strLuck = Strings.toString(charAttributes.attackDamage);
        string memory strCharisma = Strings.toString(
            charAttributes.attackDamage
        );
        string memory strWisdom = Strings.toString(charAttributes.attackDamage);
        string memory strIntelligence = Strings.toString(
            charAttributes.attackDamage
        );

        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                charAttributes.name,
                " -- NFT #: ",
                Strings.toString(_tokenId),
                '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
                charAttributes.imageURI,
                '", "attributes": [ { "trait_type": "Health Points", "value": ',
                strHp,
                ', "max_value":',
                strMaxHp,
                '}, { "trait_type": "Attack Damage", "value": ',
                strAttackDamage,
                '}, { "trait_type": "Strength", "value": ',
                strStrength,
                '}, { "trait_type": "Luck", "value": ',
                strLuck,
                '}, { "trait_type": "Charisma", "value": ',
                strCharisma,
                '}, { "trait_type": "Wisdom", "value": ',
                strWisdom,
                '}, { "trait_type": "Intelligence", "value": ',
                strIntelligence,
                "} ]}"
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }
}
