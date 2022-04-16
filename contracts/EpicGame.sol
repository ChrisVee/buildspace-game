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

    struct CharacterStats {
        uint256 strength;
        uint256 luck;
        uint256 charisma;
        uint256 wisdom;
        uint256 intelligence;
    }

    struct CharacterAttributes {
        uint256 characterIndex;
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
        CharacterStats stats;
    }

    struct CharacterStatModifiers {
        uint256[] characterStrengthModifier;
        uint256[] characterLuckModifier;
        uint256[] characterCharismaModifier;
        uint256[] characterWisdomModifier;
        uint256[] characterIntelligenceModifier;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    CharacterAttributes[] defaultCharacters;

    mapping(address => uint256) public nftHolders;
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    struct BigBoss {
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }

    BigBoss public bigBoss;

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint256[] memory characterHp,
        uint256[] memory characterAttackDmg,
        CharacterStatModifiers memory characterStatModifiers,
        string memory bossName, // These new variables would be passed in via run.js or deploy.js.
        string memory bossImageURI,
        uint256 bossHp,
        uint256 bossAttackDamage
    ) ERC721("Heroes", "HERO") {
        // Initialize the boss. Save it to our global "bigBoss" state variable.
        bigBoss = BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDamage
        });

        console.log(
            "Done initializing boss %s w/ HP %s, img %s",
            bigBoss.name,
            bigBoss.hp,
            bigBoss.imageURI
        );

        for (uint256 i = 0; i < characterNames.length; i += 1) {
            defaultCharacters.push(
                CharacterAttributes({
                    characterIndex: i,
                    name: characterNames[i],
                    imageURI: characterImageURIs[i],
                    hp: characterHp[i],
                    maxHp: characterHp[i],
                    attackDamage: characterAttackDmg[i],
                    stats: CharacterStats({
                        strength: characterStatModifiers
                            .characterStrengthModifier[i],
                        luck: characterStatModifiers.characterLuckModifier[i],
                        charisma: characterStatModifiers
                            .characterCharismaModifier[i],
                        wisdom: characterStatModifiers.characterWisdomModifier[
                            i
                        ],
                        intelligence: characterStatModifiers
                            .characterIntelligenceModifier[i]
                    })
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
            stats: CharacterStats({
                strength: statRoll(
                    defaultCharacters[_characterIndex].stats.strength
                ),
                luck: statRoll(defaultCharacters[_characterIndex].stats.luck),
                charisma: statRoll(
                    defaultCharacters[_characterIndex].stats.charisma
                ),
                wisdom: statRoll(
                    defaultCharacters[_characterIndex].stats.wisdom
                ),
                intelligence: statRoll(
                    defaultCharacters[_characterIndex].stats.intelligence
                )
            })
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
            charAttributes.stats.strength
        );
        string memory strLuck = Strings.toString(charAttributes.stats.luck);
        string memory strCharisma = Strings.toString(
            charAttributes.stats.charisma
        );
        string memory strWisdom = Strings.toString(charAttributes.stats.wisdom);
        string memory strIntelligence = Strings.toString(
            charAttributes.stats.intelligence
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
