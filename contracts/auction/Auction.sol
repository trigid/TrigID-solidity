pragma solidity ^0.4.10;

import "../token/Token.sol";

contract Auction {

    uint256 constant public MAX_TOKENS_SOLD = 5000000; // 5,000,000
    uint256 constant public HARD_CAP = 30000000;       // $30,000,000

    struct Bid {
        bytes32 blindedBid;
        uint256 deposit;
    }

    enum Stages {
        AuctionDeployed,
        AuctionSetUp,
        AuctionStarted,
        AuctionEnded,
        TradingStarted
    }

    Token public trigIDToken;
    Stages public stage;
    address public wallet;
    address public owner;
    uint256 public priceFactor;
    uint256 public totalBid;

    mapping (address => Bid[]) public bids;

    event BidSubmission(address indexed sender, uint256 amount);

    modifier atStage(Stages _stage) {
        if (stage != _stage)
        // Contract not in expected state
            throw;
        _;
    }

    modifier isOwner() {
        if (msg.sender != owner)
        // Only owner is allowed to proceed
            throw;
        _;
    }

    modifier isWallet() {
        if (msg.sender != wallet)
        // Only wallet is allowed to proceed
            throw;
        _;
    }

    modifier isValidPayload() {
        if (msg.data.length != 4 && msg.data.length != 36)
            throw;
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
        startBlock = block.number;
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
        uint256 amount = calcTokenPrice();
        if (amount >= HARD_CAP) {
            finalizeAuction();
        }
        bids[msg.sender].push(Bid({blindedBid: _blindedBid, deposit: msg.value}));
        totalBid += msg.value;
        emit BidSubmission(msg.sender, msg.value);
    }

    function reveal(uint256[] _values, bool[] _fake, bytes32[] _secret)
    public
    atStage(Stages.AuctionEnded)
    {
        uint256 length = bids[msg.sender].length;
        require(_values.length == length);
        require(_fake.length == length);
        require(_secret.length == length);

        for (uint8 i = 0; i < length; i++) {
            Bid storage bid = bids[msg.sender][i];
            (uint256 value, bool fake, bytes32 secret) = (_values[i], _fake[i], _secret[i]);
            if (fake && bid.blindedBid != keccak256(value, fake, secret)) {
                bid.blindedBid = bytes32(0);
            }
        }
        stage = Stages.TradingStarted;
    }

    /// @dev Claims tokens for bidder after auction.
    /// @param receiver Tokens will be assigned to this address if set.
    function claimTokens(address receiver)
    public
    isValidPayload
    atStage(Stages.TradingStarted)
    {
        uint256 tokenCount = bids[receiver];
        bids[receiver] = 0;
        trigIDToken.transfer(receiver, tokenCount);
    }

    function finalizeAuction()
    private
    {
        stage = Stages.AuctionEnded;
        trigIDToken.transfer(wallet, MAX_TOKENS_SOLD - totalBid);
    }
}