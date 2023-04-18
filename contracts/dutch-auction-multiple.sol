// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract DutchAuction {
    struct Item {
        address seller;
        uint256 reservePrice;
        uint256 startPrice;
        uint256 reductionRate;
        uint256 auctionEndTime;
        uint256 highestBid;
        uint256 auctionStartTime;
        uint256 noOfMembers;
        uint256 noOfBidders;
        uint256 regTime;
        address bidWinner;
    }
    mapping(uint256 => Item) public items;
    mapping(uint256 => mapping (address => bool)) public members;
    mapping(uint256 => mapping (address => bool)) public bidders;

    event ItemCreated(uint256 itemId, uint256 reservePrice, uint256 startPrice, uint256 auctionEndTime);
    event AuctionStarted(uint itemId, uint startPrice);
    event SecretBidPlaced(uint256 itemId, address bidder);
    event SecretbiddingCompleted(uint itemId);
    event AuctionCompleted(uint256 itemId, address winner);

    modifier onlyMember(uint _itemId) {
        require(members[_itemId][msg.sender], "Only members can access this function");
        _;
    }

    function inductMember(uint _itemId) public {
        require(msg.sender != items[_itemId].seller, "Seller cannot participate in auction.");
        require(block.timestamp < items[_itemId].regTime, "Reg Time is over");
        members[_itemId][msg.sender] = true;
        items[_itemId].noOfMembers++;
    }

    uint itemCount=0;
    function createItem(uint256 reservePrice, uint256 reductionRate, uint256 auctionDuration, uint256 regtime) public {
        require(items[itemCount].seller == address(0), "Item already exists");
        items[itemCount] = Item(msg.sender, reservePrice, reservePrice, reductionRate, block.timestamp+ auctionDuration, 0, block.timestamp, 0, 0, block.timestamp+ regtime, address(0));
        emit ItemCreated(itemCount, reservePrice,reservePrice, items[itemCount].auctionEndTime);
        itemCount++;
    }

    function placeSecretBid(uint256 itemId, uint256 secretBid) public onlyMember(itemId) {
        require(items[itemId].regTime < block.timestamp, "Secret bidding not started yet");
        require(!bidders[itemId][msg.sender], "you already have Placed a bid");
        require(block.timestamp < items[itemId].auctionEndTime, "Secret Bidding is over"); 
          if (items[itemId].highestBid < secretBid){
              items[itemId].highestBid = secretBid;
          }
        bidders[itemId][msg.sender] = true;
        items[itemId].noOfBidders ++;
        emit SecretBidPlaced(itemId, msg.sender);

        if(items[itemId].noOfMembers == items[itemId].noOfBidders){
            emit SecretbiddingCompleted(itemId);
        }
    }

    function closeBid(uint256 itemId) private{
        if(items[itemId].bidWinner == address(0)){
            //emit
        }
        else{
            //emit
        }
        delete (items[itemId]);
    }
   
    function getPrice(uint256 itemId) public returns (uint256){
        require(items[itemId].seller != address(0), "Item does not exists");
        require(block.timestamp >= items[itemId].auctionEndTime || items[itemId].noOfMembers == items[itemId].noOfBidders , "Secret bidding is not over yet") ;
        uint256 timeElapsed = block.timestamp - items[itemId].auctionStartTime;
        uint256 discount = items[itemId].reductionRate * timeElapsed;
        if((items[itemId].startPrice - discount) < items[itemId].reservePrice ){
            closeBid(itemId);
            return items[itemId].reservePrice;
        }
        return items[itemId].startPrice - discount;
    }
   
    function startBidding(uint256 itemId, uint256 extraPrice)  public returns (uint256) {
        require(block.timestamp >= items[itemId].auctionEndTime || items[itemId].noOfMembers == items[itemId].noOfBidders, "Secret bidding is not over yet");
        if (items[itemId].highestBid >= items[itemId].reservePrice) {
            items[itemId].startPrice = items[itemId].highestBid + extraPrice ;
            items[itemId].auctionStartTime = block.timestamp;
        }
        else{
            items[itemId].startPrice = items[itemId].reservePrice;
        }
        emit AuctionStarted(itemId, items[itemId].startPrice);
        return items[itemId].startPrice;
    }
    function deposit() public payable {}

    function buy(uint256 itemId) public payable {
        require(items[itemId].bidWinner == address(0), "Item is already sold");
        require(items[itemId].seller != address(0), "Item does not exist");
        uint price = getPrice(itemId);
        require(price <= msg.value, "unable to buy lack of funds");
        deposit();
        address payable seller = payable(items[itemId].seller);
        seller.transfer(price);
        items[itemId].bidWinner = msg.sender;
        //emit
        // transfer remaining value from contract to winner
        payable(msg.sender).transfer(address(this).balance);
    }
}