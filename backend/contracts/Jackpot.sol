pragma solidity >=0.4.22 <0.9.0;


contract Jackpot {


  //events
  event JackspotResult(bool _result, uint[] _sequence, uint _amount);
  event PrizeTransfered(uint _amount, address _from, address _to);
  event BalanceUpdated(uint _amount);


  uint jackpotSequence;
  uint jackpotDigits=6;
  uint jackpotModulus=10**jackpotDigits;

  uint randJackpotNonce = 0;
  struct Winner {
    uint amount;
  }

  function _generateRandomJackpotSequence() private returns (uint[] memory) {
    randJackpotNonce++;
    uint[] memory sequence;
    sequence[0] = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % jackpotModulus;
    randJackpotNonce++;
    sequence[1] = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % jackpotModulus;
    randJackpotNonce++;
    sequence[2] = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % jackpotModulus;
    return sequence;
  }

  function _validateSequence(uint[] memory _sequence) private pure returns (bool){
    if(_sequence[0] == _sequence[1] && _sequence[1] == _sequence[2] && _sequence[0] == _sequence[2]){
      return true;
    } else {
      return false;
    }
  }
  
  function getBalance() public view returns (uint) {
    return address(this).balance;
  }

  function _withDrawAmount() private{
    uint balance = address(this).balance;
    payable(msg.sender).transfer(balance);
    emit PrizeTransfered(balance, address(this), address(msg.sender));
    emit BalanceUpdated(getBalance());
  } 

  function receive() external payable{
    require(msg.value > 0, "Increase the amount");
    emit BalanceUpdated(getBalance());
    _generateSequence(msg.value);
  } 

  function _generateSequence(uint _amount) private{
    uint[] memory sequence = _generateRandomJackpotSequence();
    if(_validateSequence(sequence)){
      emit JackspotResult(true,sequence,_amount);
      _withDrawAmount();
    } else {
      emit JackspotResult(false,sequence,_amount);
    }
  }
}