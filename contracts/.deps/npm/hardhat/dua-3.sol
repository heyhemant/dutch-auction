pragma solidity ^0.8.0;

contract DutchAuction {
    struct Item {
        address owner;
        uint256 reservePrice;
        uint256 startPrice;
        uint256 currentPrice;
        uint256 reductionRate;
        uint256 auctionEndTime;
        mapping(address => bytes32) secretBids;
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

        // items[itemId] = Item({
        //     owner: msg.sender,
        //     reservePrice: reservePrice,
        //     startPrice: startPrice,
        //     currentPrice: startPrice,
        //     reductionRate: reductionRate,
        //     auctionEndTime: block.timestamp + auctionDuration,
        //     highestBidder: address(0),
        //     highestBid: 0,
        //     sold: false
        // });

        emit AuctionStarted(itemId, reservePrice, startPrice, items[itemId].auctionEndTime);
    }

    function placeSecretBid(uint256 itemId, bytes32 secretBid) public onlyMember {
        require(items[itemId].secretBids[msg.sender] == bytes32(0), "Already placed a secret bid");
        require(block.timestamp < items[itemId].auctionEndTime, "Auction is over");
        
        items[itemId].secretBids[msg.sender] = secretBid;
        
        emit SecretBidPlaced(itemId, msg.sender);
    }

    function revealBid(uint256 itemId, uint256 bidAmount, bytes32 secret) public onlyMember {
        require(items[itemId].secretBids[msg.sender] == keccak256(abi.encodePacked(bidAmount, secret)), "Invalid secret");
        require(block.timestamp < items[itemId].auctionEndTime, "Auction is over");
        
        if (bidAmount > items[itemId].highestBid) {
            items[itemId].highestBid = bidAmount;
            items[itemId].highestBidder = msg.sender;
        }

        items[itemId].secretBids[msg.sender] = bytes32(0);
    }

    function updatePrice(uint256 itemId)  public {
        require(items[itemId].currentPrice > 0, "Item is sold out");
        require(block.timestamp >= items[itemId].auctionEndTime, "Auction is not over yet");
        
        if (items[itemId].highestBid >= items[itemId].reservePrice) {
            if (items[itemId].highestBidder.send(items[itemId].currentPrice)) {
                items[itemId].sold = true;
                items[itemId].owner = items[itemId].highestBidder;
                emit AuctionCompleted(itemId, items[itemId].highestBidder);
            }
        } else {
            items[itemId].currentPrice = items[itemId].currentPrice - items[itemId].reductionRate;
        }
    }
}