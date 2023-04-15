pragma solidity ^0.8.0;

contract DutchAuction {
    struct Item {
        address owner;
        uint256 reservePrice;
        uint256 startPrice;
        uint256 currentPrice;
        uint256 reductionRate;
        uint256 auctionEndTime;
        // address []secretBids;
        address highestBidder;
        uint256 highestBid;
        bool sold;
    }

    mapping(uint256 => Item) public items;
    mapping(address => bool) public members;

    event AuctionStarted(uint256 itemId, uint256 reservePrice, uint256 startPrice, uint256 auctionEndTime);
    event SecretBidPlaced(uint256 itemId, address bidder);
    event AuctionCompleted(uint256 itemId, address winner);

    modifier onlyMember() {
        require(members[msg.sender], "Only members can access this function");
        _;
    }

    function inductMember() public {
        members[msg.sender] = true;
    }

    function createItem(uint256 itemId, uint256 reservePrice, uint256 startPrice, uint256 auctionDuration, uint256 reductionRate) public onlyMember {
        require(items[itemId].owner == address(0), "Item already exists");
        items[itemId] = Item(msg.sender, reservePrice, startPrice, startPrice,reductionRate, block.timestamp+ auctionDuration,address(0), 0, false); // create a new item

        emit AuctionStarted(itemId, reservePrice, startPrice, items[itemId].auctionEndTime);
    }

    function placeSecretBid(uint256 itemId, uint256 secretBid) public onlyMember {
        require(block.timestamp < items[itemId].auctionEndTime, "Auction is over");
        
          if (items[itemId].highestBid < secretBid){
              items[itemId].highestBid = secretBid;
            items[itemId].highestBidder = msg.sender;
          }

        
        emit SecretBidPlaced(itemId, msg.sender);
    }


    function updatePrice(uint256 itemId, uint256 extraPrice)  public returns (uint256) {
        require(items[itemId].currentPrice > 0, "Item is sold out");
        require(block.timestamp >= items[itemId].auctionEndTime, "Auction is not over yet");
        
        if (items[itemId].highestBid >= items[itemId].reservePrice) {
            items[itemId].startPrice = items[itemId].highestBid + extraPrice ;
        }
        return items[itemId].startPrice;
    }
}