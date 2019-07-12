pragma solidity ^0.4.26;

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract MultiSend  {
  
    event MultiTransfer(
        address indexed _from,
        uint indexed _value,
        address _to,
        uint _amount
    );

    event MultiCall(
        address indexed _from,
        uint indexed _value,
        address _to,
        uint _amount
    );

    function multiTransferTightlyPacked(bytes32[] _addressesAndAmounts)
    payable public returns(bool)
    {
        uint toReturn = msg.value;
        for (uint i = 0; i < _addressesAndAmounts.length; i++) {
            address to = address(_addressesAndAmounts[i] >> 96);
            uint amount = uint(uint96(_addressesAndAmounts[i]));
            _safeTransfer(to, uint(uint96(_addressesAndAmounts[i])));
            toReturn = SafeMath.sub(toReturn, amount);
            emit MultiTransfer(msg.sender, msg.value, to, amount);
        }
        _safeTransfer(msg.sender, toReturn);
        return true;
    }
	
    function multiTransfer(address[] _addresses, uint[] _amounts)
    payable public returns(bool)
    {
        uint toReturn = msg.value;
        for (uint i = 0; i < _addresses.length; i++) {
            _safeTransfer(_addresses[i], _amounts[i]);
            toReturn = SafeMath.sub(toReturn, _amounts[i]);
            emit MultiTransfer(msg.sender, msg.value, _addresses[i], _amounts[i]);
        }
        _safeTransfer(msg.sender, toReturn);
        return true;
    }

    function multiCallTightlyPacked(bytes32[] _addressesAndAmounts)
    payable public returns(bool)
    {
        uint toReturn = msg.value;
        for (uint i = 0; i < _addressesAndAmounts.length; i++) {
            address to = address(_addressesAndAmounts[i] >> 96);
            uint amount = uint(uint96(_addressesAndAmounts[i]));
            _safeCall(to, amount);
            toReturn = SafeMath.sub(
                toReturn,
                uint(uint96(_addressesAndAmounts[i]))
            );
            emit MultiCall(msg.sender, msg.value, to, amount);
        }
        _safeTransfer(msg.sender, toReturn);
        return true;
    }

    function multiCall(address[] _addresses, uint[] _amounts)
    payable public returns(bool)
    {
        uint toReturn = msg.value;
        for (uint i = 0; i < _addresses.length; i++) {
            _safeCall(_addresses[i], _amounts[i]);
            toReturn = SafeMath.sub(toReturn, _amounts[i]);
            emit MultiCall(msg.sender, msg.value, _addresses[i], _amounts[i]);
        }
        _safeTransfer(msg.sender, toReturn);
        return true;
    }

    function _safeTransfer(address _to, uint _amount) internal {
        require(_to != 0);
        _to.transfer(_amount);
    }

    function _safeCall(address _to, uint _amount) internal {
        require(_to != 0);
        require(_to.call.value(_amount)());
    }

    function () public payable {
        revert();
    }
}