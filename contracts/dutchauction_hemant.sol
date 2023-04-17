// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'hardhat/console.sol';

contract DutchAuction {
    constructor(){

    }
    struct Item {
        address owner;
        string name;
        uint256 minimumPrice;
        uint256 highestSecrateBid;
        address highestBidder;
        uint bidStartTime;
        bool sold;
        uint8 minimumBidders;
    }

    struct User {
        bool enrolled; // boolean to track if the user is enrolled
        // No need to have user balance as a property
        //uint256 balance; // balance of the user to make bids
        string name;
        string pic;
        uint256 itemId;

    }

    // Mapping to store the items being auctioned
    mapping(uint256 => Item) public items;

    // Mapping to store the users participating in the auction
    mapping(address => User) public users;
    // TO DO create map of user & item

    // Events to be emitted on certain actions
    event ItemEnrolled(uint256 indexed itemId, address indexed owner, string name, uint256 startingPrice, uint8 minimumBidders);
    event UserEnrolled(address indexed user);
    event BidPlaced(uint256 indexed itemId, address indexed bidder, uint256 amount);
    event ItemSold(uint256 indexed itemId, address indexed seller, address indexed buyer, uint256 amount);

    uint itemCounter = 0;
    // Function to enroll a new item for auction
    function enrollItem(string memory _name, uint256 _minimumPrice, uint _bidStartTime, uint8 _minBidders) public{
        uint256 itemId = itemCounter + 1; // generate unique ID for the item

        //TODO how can a item can be sold when it is not even enrolled so unnessary condition 
         require(!items[itemId].sold, "Item already sold"); // check if the item has already been sold 

        // TODO check if the owner is trying to enroll the item
        items[itemId] = Item(msg.sender, _name, _minimumPrice, _minimumPrice, address(0), block.timestamp + _bidStartTime, false, _minBidders); // create a new item
        console.log("success %i", itemId);
        require(items[itemId].owner != address(0), "Failed to enroll the item");
        itemCounter++;
        emit ItemEnrolled(itemId, msg.sender, _name, _minimumPrice, _minBidders); // emit ItemEnrolled event
    }

    function enrollUser( string memory _name, string memory _pic, uint256 _itemId) public {
        require(!users[msg.sender].enrolled, "User already enrolled"); // check if the user is already enrolled
        users[msg.sender] = User(true, _name, _pic, _itemId); // create a new user
        items[_itemId].minimumBidders--;
        emit UserEnrolled(msg.sender); // emit UserEnrolled event
        if(items[_itemId].minimumBidders <= 0){
            // items[_itemId].bidStartTime = now();
            //emit event for this also
        }
    }


    //start secrete bid
    function placeSecretBid(uint256 _itemId, uint bidAmount) public {
        require(users[msg.sender].enrolled, "User not enrolled"); // check if the user is enrolled
        require(!items[_itemId].sold, "Item already sold"); // check if the item has already been sold
        //require((items[_itemId].bidStartTime < block.timestamp), "Biding already started"); // check if bid is already started
        //TODO to check if all the enrolled user has placed the bid

        // check if the bid is higher than the current highest bid
        if (bidAmount > items[_itemId].highestSecrateBid){
            items[_itemId].highestSecrateBid = bidAmount; // update the highest bid for the item
        }
    }

    //compute item price after every 2min
    function getCurrentItemPrice(uint256 _itemId) public view returns(uint256 price) {

        require(items[_itemId].bidStartTime >block.timestamp, "Bidding Not Started Yet");
        require(!items[_itemId].sold, "Item already sold");
        // current price = initial price - (discount rate * time elapsed in seconds)
        uint256 timeSpent = block.timestamp - items[_itemId].bidStartTime;
        // currentAmount = items[_itemId].highestSecrateBid - (inMinutes(timespent)/ L ) * y;
        // if(currentAmount< items[_itemId].minimumPrice) return items[_itemId].minimumPrice;

        //TODO why are we taking minimum price here ?
        return items[_itemId].minimumPrice - (timeSpent * 2);
    }

    function placeBid(uint256 _itemId, uint256 _currentTime) public payable {
        require(users[msg.sender].enrolled, "User not enrolled"); // check if the user is enrolled
        require(!items[_itemId].sold, "Item already sold"); // check if the item has already been sold
    
        //TODO no need to check this condition in actual bidding, only needed to check in the secrate bidding
        //require(msg.value > items[_itemId].highestSecrateBid, "Bid not high enough"); // check if the bid is higher than the current highest bid

        //TODO check if biding is started
        require(_currentTime >  items[_itemId].bidStartTime, "Bidding not started yet");

        // checking user balance
        //(users[msg.sender]);
        
        items[_itemId].highestSecrateBid = msg.value; // update the highest bid for the item
        items[_itemId].highestBidder = msg.sender; // update the highest bidder for the item
       // users[msg.sender].balance += msg.value; // add the bid amount to the user's balance
        items[_itemId].sold = true;
        // Transfer the amount to owner 
        emit BidPlaced(_itemId, msg.sender, msg.value); // emit BidPlaced event
    }

    // Function to end an auction and sell an item to the highest bidder
    function sellItem(uint256 _itemId) public view {
        require(items[_itemId].owner == msg.sender, "Only the owner can sell");
        // transfer item to bidder
    }
}