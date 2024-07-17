// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract SmartWalletProject {
    address payable public owner;

    constructor(){
        owner = payable (msg.sender);
    }

    mapping (address => uint) public Allowances;
    mapping (address => bool) public isAllowed;
    mapping (address => bool) public Guardian;
    address payable public nextOwner;
    uint public constant suggestionsRequired = 3;
    uint public suggestions;
    mapping (address => mapping (address => bool)) public guardiansNotVoted;

    function setGuardian(address _guard, bool _isguardian) public {
        Guardian[_guard] = _isguardian;
    }

    function selectNextOwner(address payable _newOwner) public {
        require(Guardian[msg.sender], "Only Guardians can suggest next Owner!! Aborting...");
        require(guardiansNotVoted[_newOwner][msg.sender] == false, "Each Guardian can only vote once!!");
        if(_newOwner != nextOwner) {
            suggestions = 0;
            nextOwner = _newOwner;
        }
        suggestions++;
        guardiansNotVoted[_newOwner][msg.sender] = true;

        if(suggestions >= suggestionsRequired) {
            owner = nextOwner;
            nextOwner = payable (address(0));
        }
    }

    function setAllowances(address _for, uint _amount) public {

        require(msg.sender == owner, "Only Owner can set allowances!! Aborting...");
        Allowances[_for] = _amount;
        if(_amount > 0) 
            isAllowed[_for] = true;
        

    }

    function transfer(address _to, uint _amount, bytes memory _payload ) public returns (bytes memory) {

        // require(msg.sender == owner, "Only the owner is allowed to make transfers!!");

        if(msg.sender != owner) {
            require(isAllowed[msg.sender] , "Not allowed to transact to that address!! Aborting...");
            require(_amount <= Allowances[msg.sender], "Amount exceeds the allowance!! Aborting...");
            Allowances[msg.sender] -= _amount;

        }

        (bool success, bytes memory returnData) = _to.call{value: _amount}(_payload);
        require(success, "Transfer unsuccessfull! Aborting...");
        return returnData;
    }

    receive() external payable { }
}