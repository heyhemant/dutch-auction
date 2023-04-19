// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DutchAuction {
    struct Item {
        address owner;
        uint256 reservePrice;
        uint256 startPrice;
        uint256 currentPrice;
        uint256 reductionRate;
        uint256 auctionEndTime;
        address highestBidder;
        uint256 highestBid;
        bool sold;
        uint256 auctionStartTime;
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

    // TODO not to induct owner
    function inductMember() public {
        members[msg.sender] = true;
    }

    function createItem(uint256 itemId, uint256 reservePrice, uint256 startPrice, uint256 auctionDuration, uint256 reductionRate) public onlyMember {
        require(items[itemId].owner == address(0), "Item already exists");
        items[itemId] = Item(msg.sender, reservePrice, startPrice, startPrice,reductionRate, block.timestamp+ auctionDuration,address(0), 0, false, block.timestamp);
         // create a new item

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

    //TODO check why input is not allowed
    function getPrice(uint256 itemId) public view returns (uint256){
        // uint256 itemId = 0;
        require(block.timestamp >= items[itemId].auctionEndTime, "Secretbidding is not over yet");
        uint256 timeElapsed = block.timestamp - items[itemId].auctionStartTime;
        uint256 discount = items[itemId].reductionRate * timeElapsed;
        return items[itemId].startPrice - discount;
    }

    function updatePrice(uint256 itemId, uint256 extraPrice)  public returns (uint256) {
        require(items[itemId].currentPrice > 0, "Item is sold out");
        require(block.timestamp >= items[itemId].auctionEndTime, "Auction is not over yet");
        
        if (items[itemId].highestBid >= items[itemId].reservePrice) {
            items[itemId].startPrice = items[itemId].highestBid + extraPrice ;
            items[itemId].auctionStartTime = block.timestamp;
        }
        return items[itemId].startPrice;
    }

    function deposit() public payable {}

    //TODO check the amount transfer
    function buy(uint256 itemId) public payable {
        deposit();
        address payable owner = payable(items[itemId].owner);
        owner.transfer(msg.value);

        items[itemId].owner = msg.sender;
    }
}