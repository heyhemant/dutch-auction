   struct Item {
        uint256 itemId;
        string itemName;
        address payable seller;
        uint256 biddingEndTime;
        bool ended;
        address[] bidders;
    }
        function placeBid(uint256 _itemId, bytes32 _hashedBid) public payable {
        Item storage item = items[_itemId];
        require(block.timestamp < item.biddingEndTime, "Bidding period has ended.");
        require(item.hashedBids[msg.sender] == bytes32(0), "Bidder has already placed a bid.");
        item.hashedBids[msg.sender] = _hashedBid;
        item.bidders.push(msg.sender);
        emit BidPlaced(_itemId, msg.sender, _hashedBid);
    }
    
  function starrtingPrice(uint256 _itemId, uint256 _revealedBid) public {
        Item storage item = items[_itemId];
        bytes32 hashedBid = keccak256(abi.encodePacked(msg.sender, _revealedBid));
        require(item.hashedBids[msg.sender] == hashedBid, "Invalid hashed bid.");
        require(!item.hasRevealed[msg.sender], "Bidder has already revealed their bid.");
        item.revealedBids[msg.sender] = _revealedBid;
        item.hasRevealed[msg.sender] = true;
        emit BidRevealed(_itemId, msg.sender, _revealedBid);
        if (_revealedBid > item.highestBid) {
            item.highestBid = _revealedBid;
            item.highestBidder = msg.sender;
        }
    }