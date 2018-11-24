pragma solidity ^0.4.24;

contract DogContract{
    struct Dog{
        //Token ID will equal the (index of the dog) + 1 == the length from beginning to that element in the array of dogs
        //(i.e. Dog[1] has an ID of 2)
        
        uint256 genes;

        // The timestamp of existence.
        uint64 birthTime;

        //When cooldown ends for breeding.
        uint64 cooldownEndBlockBreeding;
        
        //When cooldown ends for training.
        uint64 cooldownEndBlockTraining;

        //Parents
        uint32 matronId;
        uint32 sireId;

        uint32 siringWithId;

        // Cooldown for breeding. Will use times from an assorted array.
        uint16 cooldownBreedingIndex;

        //Cooldown for training, directly related to age)
        uint32 cooldownTraining;
        
        // Highest generation between the matron and sire + 1. Gen0 are 0.
        // (i.e. max(matron.generation, sire.generation) + 1)
        uint16 generation;
    }
    
    uint32[17] public cooldowns = [
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(10 minutes),
        uint32(20 minutes),
        uint32(40 minutes),
        uint32(1 hours),
        uint32(3 hours),
        uint32(6 hours),
        uint32(9 hours),
        uint32(12 hours),
        uint32(16 hours),
        uint32(20 hours),
        uint32(1 days),
        uint32(2 days),
        uint32(3 days),
        uint32(7 days),
        uint32(14 days)
    ];
    
    uint256 public secsPerBlock = 15;
    Dog[] dogs;
    /**
     * Creates a new dog object and adds it the array of existing dogs.
     * @param _matronId Dog ID of matron
     *  _sireId Dog ID of sire
     *  _generation The generation of the new dog
     *  _genes The genes integer of the new dog
     *  _owner The address that called mint() to create a new dog
     */
    function _createDog(uint256 _matronId, uint256 _sireId, uint256 _generation, uint256 _genes, address _owner) internal{
        uint16 _cooldownBreedingIndex = uint16(_generation / 2);
        if (_cooldownBreedingIndex > 13) {
            _cooldownBreedingIndex = 13;
        }
        Dog memory _dog = Dog({
            genes: _genes,
            birthTime: uint64(now),
            cooldownEndBlockBreeding: 0,
            cooldownEndBlockTraining: 0,
            matronId: uint32(_matronId),
            sireId: uint32(_sireId),
            siringWithId: 0,
            cooldownBreedingIndex: _cooldownBreedingIndex,
            cooldownTraining: uint32(10 minutes),
            generation: uint16(_generation)
        });
        
        uint256 dogID = dogs.push(_dog);
        
        require(dogID == uint256(uint32(dogID))); //Puts a limit of 2^32 (about 4 million) dogs.
        
        emit Birth(_owner, dogID, uint256(_dog.matronId), (_dog.sireId), _dog.genes);
    }
    
    
	/**
	 * Will train the dogs and will add to the train element in the dog object.
	 * Training will be randomly assigned to the dog after the time of training is finished.
	 * More rarer training has a lower probability of being assigned to the dog, while more common training has a higher chance of bieng assigned
	 * @param _tokenId The dog ID
	 */
	function _train(uint256 _tokenId) view internal{
	    
	}
    
    /**
     * Retrives the genes integer from a specified dog.
     * @param _tokenId the token ID of the dog
     * @return Integer that represents the dog's genes
     */
    function getGenes(uint256 _tokenId) external view returns (uint256 genes) {
	    return dogs[_tokenId].genes;
	}
    
    event Birth(address owner, uint256 kittyId, uint256 matronId, uint256 sireId, uint256 genes);
}

contract ERC721 {
    // Required methods
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // Optional
    //function name() public view returns (string name);
    //function symbol() public view returns (string symbol);
    function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}

contract PongvalRetriever {
 	int8 pongval_tx_retrieval_attempted = 0;
    	function mintGenes() public returns (int8){
		pongval_tx_retrieval_attempted = -1;
		return pongval_tx_retrieval_attempted;
	}
	
	function trainDog(uint256 _genes) public returns (int8){
		pongval_tx_retrieval_attempted = -1;
		return pongval_tx_retrieval_attempted;
	}
}

contract DogToken is DogContract, ERC721, PongvalRetriever {
	//mapping (uint256 => address) public tokenToAddress;
	//mapping (address => uint256) public addresToToken;
	
	string public constant name = "DigitalDoggos";
	string public constant symbol = "DIGIDOG";
	address contractOwner;
	PongvalRetriever pongAddress;

	bytes4 constant InterfaceID_ERC165 =
		bytes4(keccak256('supportsInterface(bytes4)'));

	bytes4 constant InterfaceID_ERC721 =
		bytes4(keccak256('name()')) ^
		bytes4(keccak256('symbol()')) ^
		bytes4(keccak256('totalSupply()')) ^
		bytes4(keccak256('balanceOf(address)')) ^
		bytes4(keccak256('ownerOf(uint256)')) ^
		bytes4(keccak256('approve(address,uint256)')) ^
		bytes4(keccak256('transfer(address,uint256)')) ^
		bytes4(keccak256('transferFrom(address,address,uint256)')) ^
		bytes4(keccak256('tokensOfOwner(address)'));


	/*** DATA TYPES ***/

	struct Token {
		address mintedBy;
		uint64 mintedAt;
	}


	/*** STORAGE ***/

	Token[] tokens;

	mapping (uint256 => address) public tokenIndexToOwner;
	mapping (address => uint256) ownershipTokenCount;
	mapping (uint256 => address) public tokenIndexToApproved;

    /*** CONTRUCTOR ***/
    
    constructor(PongvalRetriever _pongAddress) public {
        contractOwner = msg.sender;
        pongAddress = _pongAddress;
        
        //This is a temporary loop. Ideally, the dogs would be generated in intervals instead of all at once since that will take too much gas to even run.
        for(uint16 i = 0; i < 5; i++){
           _mint(contractOwner, uint256(keccak256(contractOwner, tokens.length)));
        }
    }
    
	/*** EVENTS ***/

	event Mint(address owner, uint256 tokenId);

    function test(uint256 _testint) external view returns (int8){
        return pongAddress.trainDog(_testint);
    }
	/*** INTERNAL FUNCTIONS ***/
    /**
     * Checks if a token is oened by the claimant address.
     * @param _claimant is a public address
     *  _tokenId is the ID number of the dog
     * @return true if the address contains the dog
     */
	function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
		return tokenIndexToOwner[_tokenId] == _claimant;
	}
     /**
     * Checks if the sender can take Ether or tokens from owner of that Ether or token.
     * @param _claimant the recieving address
     *  _tokenId the ID of the dog
     * @return true if claimant is approved
     *  otherwise false
     */
	function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
		return tokenIndexToApproved[_tokenId] == _claimant;
	}
    /**
     * Gives permission to the reciever to transact Ether or tokens on the sender's behalf.
     * @param _to the recieving address
     *  _tokenId the ID of the dog
     */
	function _approve(address _to, uint256 _tokenId) internal {
		tokenIndexToApproved[_tokenId] = _to;

		emit Approval(tokenIndexToOwner[_tokenId], tokenIndexToApproved[_tokenId], _tokenId);
	}
    
    /**
     * Sends one ERC-721 token to the to address.
     * @param _to the recieving address
     *  _tokenId the ID of the dog
     */
	function _transfer(address _from, address _to, uint256 _tokenId) internal {
		ownershipTokenCount[_to]++;
		tokenIndexToOwner[_tokenId] = _to;

		if (_from != address(0)) {
		  ownershipTokenCount[_from]--;
		  delete tokenIndexToApproved[_tokenId];
		}

		emit Transfer(_from, _to, _tokenId);
	}
   
    //function _createInitDog(address _owner, uint256 recursion, uint256 recursionMax) internal {
    //    require(recursionMax > recursion);
    //    _mint(_owner, uint256(keccak256(_owner, tokens.length)));
    //    recursion++;
    //    _createInitDog(_owner, recursion, recursionMax);
    //}
    
    /**
     * Creates a new dog by minting a ERC-721 token and initailizing a new Dog object.
     * Right now, this function only creates Gen 0 dogs.
     * In the future, a separeate function will be make to mint higher genration dogs where its matron and sire will be stored.
     * @param _owner The address that called the mint function
     *  _genes 256-bit integer that represents the dog's genees.'
     * @return tokenID the ID of the newly minted dog
     */
	function _mint(address _owner, uint256 _genes) internal returns (uint256 tokenId) {
		Token memory token = Token({
		  mintedBy: _owner,
		  mintedAt: uint64(now)
		});
		tokenId = tokens.push(token);
        _createDog(0, 0, 0, _genes, _owner); //Ideally, the genes here SHOULD be randomly genreated. Only probem here is it will take several lines to execute making it take up lots of gas...
		emit Mint(_owner, tokenId);

		_transfer(0, _owner, tokenId);
	}


	/*** ERC721 IMPLEMENTATION ***/
    
	function supportsInterface(bytes4 _interfaceID) external view returns (bool) {
		return ((_interfaceID == InterfaceID_ERC165) || (_interfaceID == InterfaceID_ERC721));
	}
    /**
     * @return The total amount of dog tokens created
     */
	function totalSupply() public view returns (uint256) {
		return tokens.length;
	}

    /**
     * @param _owner Any Ethereum address
     * @return Retrieves the dog token balance of the passed address
     */
	function balanceOf(address _owner) public view returns (uint256) {
		return ownershipTokenCount[_owner];
	}
	
     /**
     * ownerOf function that is accessible to being called by addresses on the blockchain.
     * Gets the owner of a dog passed into the function
     * @param _tokenId Dog ID
     * @return owner address of the owner of the dog
     */
	function ownerOf(uint256 _tokenId) external view returns (address owner) {
		owner = tokenIndexToOwner[_tokenId];

		require(owner != address(0));
	}
	
    /**
     * Can be executed by any Ether address
     * Gives permission to the reciever to transact Ether or tokens on the sender's behalf
     * @param _to the recieving address
     *  _tokenId the ID of the dog
     */
	function approve(address _to, uint256 _tokenId) external {
		require(_owns(msg.sender, _tokenId));

		_approve(_to, _tokenId);
	}
    
    /**
     * Can be executed by any Ether address
     * Transfers the dog token from the sender's address to the _to address
     * @param _to the recieving address
     *  _tokenId the ID of the dog
     */
	function transfer(address _to, uint256 _tokenId) external {
		require(_to != address(0));
		require(_to != address(this));
		require(_owns(msg.sender, _tokenId));

		_transfer(msg.sender, _to, _tokenId);
	}
    
    /**
     * Can be executed by any Ether address
     * Transfers the dog token from one address to another executed not by the original owner of the dog
     * Requires approved to be executed first in order for the trasaction to be made
     * @param _from the original dog owner address
     *  _to the recieving address
     *  _tokenId the ID of the dog
     */
	function transferFrom(address _from, address _to, uint256 _tokenId) external {
		require(_to != address(0));
		require(_to != address(this));
		require(_approvedFor(msg.sender, _tokenId));
		require(_owns(_from, _tokenId));

		_transfer(_from, _to, _tokenId);
	}
    
    /**
     * Displays a list of all the dogs owned by a certain address
     * @param _owner Any ETH address
     * @return An array of all the dog IDs that the address owns
     */
	function tokensOfOwner(address _owner) external view returns (uint256[]) {
		uint256 balance = balanceOf(_owner);

		if (balance == 0) {
		  return new uint256[](0);
		} else {
		  uint256[] memory result = new uint256[](balance);
		  uint256 maxTokenId = totalSupply();
		  uint256 idx = 0;

		  uint256 tokenId;
		  for (tokenId = 1; tokenId <= maxTokenId; tokenId++) {
			if (tokenIndexToOwner[tokenId] == _owner) {
			  result[idx] = tokenId;
			  idx++;
			}
		  }
		}

		return result;

	}

	/*** OTHER EXTERNAL FUNCTIONS ***/
    /**
     * Mint function that is accessible to being called by addresses on the blockchain.
     * The genes as of right now are just only based off a hash of the sender address and the number of dogs already created.
     * In the future, I will create a separate contract to evaluate genes instead of using hashing to randomly generate Gen 0 genes.
     * @return the id of the minted dog.
     */
	function mint() external returns (uint256) {
		return _mint(msg.sender, uint256(keccak256(msg.sender, tokens.length)));
	}
    /**
     * @param _tokenId the ID of the dog token
     * @return mintedBy the address who called the mint() function that generated this Token
     *      mintedAt the date and time of when the token was minted.
     */
	function getToken(uint256 _tokenId) external view returns (address mintedBy, uint64 mintedAt) {
		Token memory token = tokens[_tokenId];

		mintedBy = token.mintedBy;
		mintedAt = token.mintedAt;
	}
}