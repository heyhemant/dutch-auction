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
        uint256 highestBid;
        bool sold;
        uint256 auctionStartTime;
    }
    mapping(uint256 => Item) public items;
    mapping(address => bool) public members;
    mapping(address => bool) public bidders;

    uint256 public regTime;
    uint256 public nOfMembers = 0;
    uint256 public noOfbidders = 0;

    constructor(uint _regTime){
        regTime = block.timestamp + _regTime;
    }
    
    event AuctionStarted(uint256 itemId, uint256 reservePrice, uint256 startPrice, uint256 auctionEndTime);
    event SecretBidPlaced(uint256 itemId, address bidder);
    event AuctionCompleted(uint256 itemId, address winner);

    modifier onlyMember() {
        require(members[msg.sender], "Only members can access this function");
        _;
    }
    // TODO not to induct owner
    function inductMember() public {
        require(block.timestamp < regTime, "Reg Time  is over");
        members[msg.sender] = true;
        nOfMembers++;
    }

    uint itemCount=0;
    function createItem(uint256 reservePrice, uint256 startPrice, uint256 auctionDuration, uint256 reductionRate) public onlyMember {
        //how will user know which itemId is available or not
        require(items[itemCount].owner == address(0), "Item already exists");
        items[itemCount] = Item(msg.sender, reservePrice, startPrice, startPrice,reductionRate, block.timestamp+ auctionDuration, 0, false, block.timestamp);
         // create a new item
        emit AuctionStarted(itemCount, reservePrice, startPrice, items[itemCount].auctionEndTime);
        itemCount++;
    }
    function placeSecretBid(uint256 itemId, uint256 secretBid) public onlyMember {
        require(!bidders[msg.sender], "you already have Placed a bid");
        require(block.timestamp < items[itemId].auctionEndTime, "Secret Bidding is over"); //why are we checking auction end time here ?
          if (items[itemId].highestBid < secretBid){
              items[itemId].highestBid = secretBid;
            //   items[itemId].highestBidder = msg.sender; //no need to store higgestBidder address in secret bid
          }
          //check weather the all users have placed the secrate bid or not and start auction accordingly
        bidders[msg.sender] = true;
        noOfbidders++;
        emit SecretBidPlaced(itemId, msg.sender);
    }
    function closeBid(uint256 itemId) private{
        delete (items[itemId]);
       //either delete the item or self destruct(not recomannded)
    }
    //TODO check why input is not allowed
    function getPrice(uint256 itemId) public returns (uint256){
        // uint256 itemId = 0;
        require(block.timestamp >= items[itemId].auctionEndTime || nOfMembers == noOfbidders , "Secret bidding is not over yet") ;
        uint256 timeElapsed = block.timestamp - items[itemId].auctionStartTime;
        uint256 discount = items[itemId].reductionRate * timeElapsed;
        if((items[itemId].startPrice - discount) < items[itemId].reservePrice ){
             closeBid(itemId);
            return 0;
        }
        return items[itemId].startPrice - discount;
    }
    
    function updatePrice(uint256 itemId, uint256 extraPrice)  public returns (uint256) {
        require(block.timestamp >= items[itemId].auctionEndTime || nOfMembers == noOfbidders, "Secret bidding is not over yet");
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