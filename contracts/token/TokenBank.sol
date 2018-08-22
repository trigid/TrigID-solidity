pragma solidity ^0.4.10;

import "./ERC20.sol";
import "../math/SafeMath.sol";

contract TokenBank {
    using SafeMath for uint256;

    mapping(address => mapping(address => uint256)) public balances;

    event TokensDeposited(address depositor, address tokenAddress, uint256 tokens, uint256 balanceAfter);
    event TokensWithdrawn(address withdrawer, address tokenAddress, uint256 tokens, uint256 balanceAfter);

    function depositTokens(address tokenAddress, uint256 tokens) public {
        require(tokenAddress != 0 && tokens != 0);
        require(ERC20(tokenAddress).transferFrom(msg.sender, this, tokens));

        balances[tokenAddress][msg.sender] = balances[tokenAddress][msg.sender].add(tokens);
        emit TokensDeposited(msg.sender, tokenAddress, tokens, balances[tokenAddress][msg.sender]);
    }

    function withdrawTokens(address tokenAddress, uint256 tokens) public {
        require(tokenAddress != 0 && tokens != 0);
        require(balances[tokenAddress][msg.sender] >= tokens);
        require(ERC20(tokenAddress).transfer(msg.sender, tokens));

        balances[tokenAddress][msg.sender] = balances[tokenAddress][msg.sender].sub(tokens);
        emit TokensWithdrawn(msg.sender, tokenAddress, tokens, balances[tokenAddress][msg.sender]);
    }

    function balanceOf(address tokenAddress, address tokenOwner) public view returns (uint256 tokens) {
        return balances[tokenAddress][tokenOwner];
    }
}