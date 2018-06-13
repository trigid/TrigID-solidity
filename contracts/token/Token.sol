pragma solidity ^0.4.10;

import "./ERC20.sol";
import "./Owned.sol";
import "./ApproveAndCallFallBack.sol";
import "../math/SafeMath.sol";

contract Token is ERC20, Owned {
    using SafeMath for uint256;

    string internal _name = "TrigID";
    string internal _symbol = "ID";
    uint8 internal _decimals = 0;
    uint256 internal _totalSupply = 2000000000;

    // For testing only
    uint256 public constant DRIP_AMOUNT = 1000;

    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    constructor() public {
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    function name()
    public
    view
    returns (string) {
        return _name;
    }

    function symbol()
    public
    view
    returns (string) {
        return _symbol;
    }

    function decimals()
    public
    view
    returns (uint8) {
        return _decimals;
    }

    function totalSupply()
    public
    view
    returns (uint256) {
        return SafeMath.sub(_totalSupply, balances[address(0)]);
    }

    // For testing only
    function drip() public {
        balances[owner] = balances[owner].sub(DRIP_AMOUNT);
        balances[msg.sender] = balances[msg.sender].add(DRIP_AMOUNT);
        emit Transfer(owner, msg.sender, DRIP_AMOUNT);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value > 0 );
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value > 0 );
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = SafeMath.sub(balances[_from], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint256 _addedValue, bytes data) public returns (bool) {
        allowed[msg.sender][_spender] = SafeMath.add(allowed[msg.sender][_spender], _addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        ApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _addedValue, this, data);
        return true;
    }

    // Don't accept ETH
    function () public payable {
        revert();
    }

    // Owner can transfer out any accidentally sent ERC20 tokens
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20(tokenAddress).transfer(owner, tokens);
    }
}