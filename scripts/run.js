const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
    const gameContract = await gameContractFactory.deploy(
      ["The Overachiever", "The Degen", "The New Guy"],       // Names
      ["https://i.imgur.com/BzFFcIW.png", // Images
      "https://i.imgur.com/G5ManyM.png", 
      "https://i.imgur.com/E9e51QQ.png"],
      [300, 200, 100],              // HP values
      [25, 50, 100],                // Attack damage values
      {                         
      characterStrengthModifier:[4, 2, 1],                    // Strength
      characterLuckModifier:[1, 4, 5],                        // Luck
      characterCharismaModifier:[1, 2, 3],                    // Charisma
      characterWisdomModifier:[4, 1, 2],                      // Wisdom
      characterIntelligenceModifier:[4, 1, 2],                // Intelligence 
      },
      "THE BOSS", // Boss name
      "https://www.kindpng.com/picc/m/46-469365_clip-art-angry-stick-figure-meme-angry-meme.png", // Boss image
      10000,                         // Boss hp
      50                             // Boss attack damage                  
    );
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);
  
    let txn;

txn = await gameContract.mintCharacterNFT(2);
await txn.wait();

let returnedTokenUri = await gameContract.tokenURI(1);
console.log("Token URI:", returnedTokenUri);
  
  };
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();
