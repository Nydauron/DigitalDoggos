pragma solidity ^0.4.24;

contract Genes{
    // function mintGenes1() public view returns (uint256) {
    //     pongval_tx_retrieval_attempted = 1;
    // 	pongval = pongval + 100;
    //     return 23456;
    // }
    
    int8 pongval;
    int8 pongval_tx_retrieval_attempted = 0;
    
    function trainDog(uint256 _genes) public view returns (uint256) {
        return _genes;
    }
    
    function mintGenes() public view returns (int8)
    {
    	pongval_tx_retrieval_attempted = 1;
    	pongval += 100;
    	return pongval;
    }
    
    function setPongval(int8 _pongval)
	{
		pongval = _pongval;
	}
}