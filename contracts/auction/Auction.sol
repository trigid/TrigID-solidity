pragma solidity ^0.4.10;

import "../token/Token.sol";

contract Auction {

    uint256 constant public MAX_TOKENS_SOLD = 5000000; // 5,000,000
    uint256 constant public HARD_CAP = 30000000;       // $30,000,000

    struct Bid {
        bytes32 blindedBid;
        uint256 deposit;
        uint256 tokenCount;
    }

    enum Stages {
        AuctionDeployed,
        AuctionSetUp,
        AuctionStarted,
        AuctionEnded
    }

    Token public trigIDToken;
    Stages public stage;
    address public wallet;
    address public owner;
    uint256 public priceFactor;
    uint256 public totalBid;
    address public highestBidder;
    uint256 public highestBid;

    mapping (address => Bid) public bids;

    event BidSubmission(address indexed sender, uint256 amount);

    modifier atStage(Stages _stage) {
        require(stage == _stage);
        _;
    }

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier isWallet() {
        require(msg.sender == wallet);
        _;
    }

    modifier isValidPayload() {
        require (msg.data.length == 4 || msg.data.length == 36);
        _;
    }

    constructor(address _wallet, uint256 _priceFactor) public {
        require(_wallet != 0);
        require(_priceFactor != 0);
        owner = msg.sender;
        wallet = _wallet;
        priceFactor = _priceFactor;
        stage = Stages.AuctionDeployed;
    }

    /// @dev Setup function sets external contracts' addresses.
    /// @param _trigIDToken TrigID token address.
    function setup(address _trigIDToken)
    public
    isOwner
    atStage(Stages.AuctionDeployed)
    {
        require(_trigIDToken != 0);
        trigIDToken = Token(_trigIDToken);
        stage = Stages.AuctionSetUp;
    }

    /// @dev Starts auction and sets startBlock.
    function startAuction()
    public
    isWallet
    atStage(Stages.AuctionSetUp)
    {
        stage = Stages.AuctionStarted;
    }

    /// @dev Changes auction price factor before auction is started.
    /// @param _priceFactor Updated start price factor.
    function changeSettings(uint256 _priceFactor)
    public
    isWallet
    atStage(Stages.AuctionSetUp)
    {
        priceFactor = _priceFactor;
    }

    /// @dev Calculates token price.
    /// @return Returns token price.
    function calcTokenPrice()
    constant
    public
    returns (uint256)
    {
        return totalBid * priceFactor;
    }

    function bid(bytes32 _blindedBid)
    public
    payable
    isValidPayload
    atStage(Stages.AuctionStarted)
    {
        require(_blindedBid != 0);
        require(bids[msg.sender].blindedBid.length == 0);
        uint256 amount = calcTokenPrice();
        if (amount >= HARD_CAP) {
            finalizeAuction();
        }
        bids[msg.sender] = Bid({blindedBid: _blindedBid, deposit: msg.value, tokenCount: 0});
        emit BidSubmission(msg.sender, msg.value);
    }

    function reveal(uint256 _value, bool _fake, bytes32 _secret)
    public
    atStage(Stages.AuctionEnded)
    {
        require(_value != 0);
        require(_fake == false || _fake == true);
        require(_secret != 0);

        require(bids[msg.sender].blindedBid == keccak256(abi.encodePacked(_value, _fake, _secret)));

        totalBid = totalBid + (bids[msg.sender].deposit * _value);
        bids[msg.sender].tokenCount = _value;
        if(_value > highestBid) {
            highestBidder = msg.sender;
            highestBid = _value;
        }
    }

    /// @dev Claims tokens for bidder after auction.
    /// @param receiver Tokens will be assigned to this address if set.
    function claimTokens(address receiver)
    public
    isValidPayload
    atStage(Stages.AuctionEnded)
    {
        uint256 tokenCount = bids[receiver].tokenCount;
        bids[receiver].blindedBid = bytes32(0);
        bids[receiver].deposit = 0;
        bids[receiver].tokenCount = 0;
        trigIDToken.transfer(receiver, tokenCount);
    }

    function finalizeAuction()
    private
    {
        stage = Stages.AuctionEnded;
        trigIDToken.transfer(wallet, MAX_TOKENS_SOLD - totalBid);
    }
}