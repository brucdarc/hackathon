
pragma solidity ^0.8.7;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract DummyToken is ERC20{
    
    constructor() ERC20("DummyToken", "DT"){
        _mint(msg.sender, 1e21);
    }
    
    
}