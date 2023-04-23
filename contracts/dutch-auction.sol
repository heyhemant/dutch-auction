// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import 'hardhat/console.sol';
/**
 * @title Dutch Auction Contract
 * @dev Allows users to auction there items in a decentralized environment, in the dutch auction format
 */
contract DutchAuctionContract{
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

    struct User{
        string email;
        string name;
        string pic;
        bool exists;
    }

    uint itemCount=0;
    mapping(uint256 => Item) public items;
    mapping(uint256 => mapping (address => bool)) public members;
    mapping(uint256 => mapping (address => bool)) public bidders;
    mapping(address => User) public users;

    event ItemCreated(uint256 itemId, uint256 reservePrice, uint256 startPrice, uint256 auctionEndTime);
    event AuctionStarted(uint itemId, uint startPrice);
    event SecretBidPlaced(uint256 itemId, address bidder);
    event SecretbiddingCompleted(uint itemId);
    event AuctionCompleted(uint256 itemId, address winner);
    event BidPlaced(uint256 itemId, uint256 sellingPrice, address bidder);
    event CloseBid(uint itemId);
    event UserCreated(string name);
    /**
     * @dev Modifier to ensure only participants can access certain features.
     * @param _itemId the id of the Item for which we are validating.
     */
    modifier onlyMember(uint _itemId) {
        require(members[_itemId][msg.sender], "Only members can access this function");
        _;
    }

    modifier onlyOwner(uint _itemId){
        require(items[_itemId].seller == msg.sender, "Only Owner can access this function");
        _;
    }

    modifier onlyBidder(uint _itemId){
        require (bidders[_itemId][msg.sender], "Only bidders can access this function");
        _;
    }

    function createUser(string memory _email, string memory _name, string memory _pic) public{
        require(!users[msg.sender].exists , "User already exists");
        users[msg.sender] = User(_email, _name, _pic, true);
    }

    function getUser() public view returns (string memory, string memory, string memory){
        require(users[msg.sender].exists , "Please register yourself");
        return (users[msg.sender].name, users[msg.sender].email, users[msg.sender].pic);
    }
    /**
     * @dev Allow users to enroll themselves in the auction for a certain item.
     * @param _itemId the id of the Item for which user is enrolling.
     */
    function inductMember(uint _itemId) public {
        require(users[msg.sender].exists , "Please Register Yourself");
        require(msg.sender != items[_itemId].seller, "Seller cannot participate in auction.");
        require(block.timestamp < items[_itemId].regTime, "Reg Time is over");
        members[_itemId][msg.sender] = true;
        items[_itemId].noOfMembers++;
    }

    /**
     * @dev Allow owner of the item to register for auction.
     * @param reservePrice the minimum price on which user is willing to sell the Item.
     * @param reductionRate the rate at which the price will reduce during the auction.
     * @param auctionDuration time duration for secret bidding.
     * @param regtime time duration for user to register for the auction.
     */
    function createItem(uint256 reservePrice, uint256 reductionRate, uint256 auctionDuration, uint256 regtime) public {
        require(items[itemCount].seller == address(0), "Item already exists");
        items[itemCount] = Item(msg.sender, reservePrice, reservePrice, reductionRate, block.timestamp+ auctionDuration, 0, block.timestamp, 0, 0, block.timestamp+ regtime, address(0));
        emit ItemCreated(itemCount, reservePrice,reservePrice, items[itemCount].auctionEndTime);
        itemCount++;
    }

    /**
     * @dev Allow participants to place bid in secret auction for a perticular item.
     * @param itemId the item for which user is trying to place secret bid.
     * @param secretBid the amount user wants to offer in secret bid.
     */
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

    function getNoOfMembers(uint256 itemId) public view returns(uint256){
        return items[itemId].noOfMembers;
    }

    /**
     * @dev Used to close the auction for a perticular item after a certain condition is met.
     * @param itemId the item for which we need to close the auction.
     */
    function closeBid(uint256 itemId) private{
        emit AuctionCompleted(itemId, items[itemId].bidWinner);
        delete (items[itemId]);
    }

    /**
     * @dev Allow participants retrieve the current price of the item in auction.
     * @param itemId the item for which user wants to get price of.
     * @return price of the particular item at the current time.
     */
    function getPrice(uint256 itemId) public view returns (uint256){
        require(items[itemId].seller != address(0), "Item does not exists");
        require(block.timestamp >= items[itemId].regTime,"Auction not started yet");
        require(block.timestamp >= items[itemId].auctionEndTime || 
            (items[itemId].noOfMembers == items[itemId].noOfBidders) , 
            "Secret bidding is not over yet") ;

        uint256 timeElapsed = block.timestamp - items[itemId].auctionStartTime;
        uint256 discount = items[itemId].reductionRate * timeElapsed;
        require((items[itemId].startPrice > discount) && 
            ((items[itemId].startPrice - discount) > items[itemId].reservePrice),
               "Please close the bid");
       
        return items[itemId].startPrice - discount;
    }

    /**
     * @dev Used to update the starting price of item and start the auction.
     * @param itemId the item for which we want to start the auction.
     * @param extraPrice the extra amount that the user wants to add in the auction starting price
     * @return the starting price of the item.
     */

    function startBidding(uint256 itemId, uint256 extraPrice)  public onlyOwner(itemId) returns (uint256) {
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

    /**
     * @dev used to deposit money to the contract
     */
    function deposit() public payable {}

    /**
     * @dev Allow participant to buy a item from the auction, first the amount is transferred to contract and contract is trasfering it to the seller.
     * @param itemId the item for user wants to buy from auction.
     */
    function buy(uint256 itemId) public onlyBidder(itemId) payable {
        require(items[itemId].bidWinner == address(0), "Item is already sold");
        require(items[itemId].seller != address(0), "Item does not exist");
        uint price = getPrice(itemId);
        require(price <= msg.value, "unable to buy lack of funds");
        deposit();
        address payable seller = payable(items[itemId].seller);
        seller.transfer(msg.value);
        emit BidPlaced(itemId, price, items[itemId].bidWinner);
    }
}