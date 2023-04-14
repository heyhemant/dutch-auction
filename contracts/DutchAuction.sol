// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract DutchAuction {
    constructor(){

    }
    struct Item {
        address owner; //TODO remove this out & create a map
        string name;
        uint256 startingPrice;
        uint256 highestBid;
        address highestBidder;
        uint bidStartTime;
        bool sold;
    }

    struct User {
        bool enrolled; // boolean to track if the user is enrolled
        uint256 balance; // balance of the user to make bids
    }

    // Mapping to store the items being auctioned
    mapping(uint256 => Item) public items;

    // Mapping to store the users participating in the auction
    mapping(address => User) public users;
    // TO DO create map of user & item

    // Events to be emitted on certain actions
    event ItemEnrolled(uint256 indexed itemId, address indexed owner, string name, uint256 startingPrice);
    event UserEnrolled(address indexed user);
    event BidPlaced(uint256 indexed itemId, address indexed bidder, uint256 amount);
    event ItemSold(uint256 indexed itemId, address indexed seller, address indexed buyer, uint256 amount);

    // Function to enroll a new item for auction
    function enrollItem(string memory _name, uint256 _startingPrice, uint _bidStartTime) public {
        uint256 itemId = uint256(keccak256(abi.encodePacked(msg.sender, _name, block.timestamp))); // generate unique ID for the item
        require(!items[itemId].sold, "Item already sold"); // check if the item has already been sold
        // TODO check if the owner is trying to enroll the item

        items[itemId] = Item(msg.sender, _name, _startingPrice, _startingPrice, address(0), block.timestamp + _bidStartTime, false); // create a new item

        console.log("success %i", itemId);
        emit ItemEnrolled(itemId, msg.sender, _name, _startingPrice); // emit ItemEnrolled event
    }

    function enrollUser() public {
        require(!users[msg.sender].enrolled, "User already enrolled"); // check if the user is already enrolled
        users[msg.sender] = User(true, 0); // create a new user
        emit UserEnrolled(msg.sender); // emit UserEnrolled event
    }
    //TODO get all users

    //start secrete bid
    function placeSecretBid(uint256 _itemId, uint bidAmount) public {
        require(users[msg.sender].enrolled, "User not enrolled"); // check if the user is enrolled
        require(!items[_itemId].sold, "Item already sold"); // check if the item has already been sold
        require((items[_itemId].bidStartTime < block.timestamp), "Biding already started"); // check if bid is already started
        //TODO to check if all the enrolled user has placed the bid

        // check if the bid is higher than the current highest bid
        if (bidAmount > items[_itemId].highestBid){
            items[_itemId].highestBid = bidAmount; // update the highest bid for the item
        }
    }

    //compute item price after every 2min
    function getCurrentItemPrice(uint256 _itemId) public payable returns(uint256 price) {
        // current price = initial price - (discount rate * time elapsed in seconds)
        uint256 timeSpent = block.timestamp - items[_itemId].bidStartTime;
        return items[_itemId].startingPrice - (timeSpent * 2);
    }

    function placeBid(uint256 _itemId) public payable {
        require(users[msg.sender].enrolled, "User not enrolled"); // check if the user is enrolled
        require(!items[_itemId].sold, "Item already sold"); // check if the item has already been sold
        require(msg.value > items[_itemId].highestBid, "Bid not high enough"); // check if the bid is higher than the current highest bid
        //TODO check if biding is started

        items[_itemId].highestBid = msg.value; // update the highest bid for the item
        items[_itemId].highestBidder = msg.sender; // update the highest bidder for the item
        users[msg.sender].balance += msg.value; // add the bid amount to the user's balance
        emit BidPlaced(_itemId, msg.sender, msg.value); // emit BidPlaced event
    }

    // Function to end an auction and sell an item to the highest bidder
    function sellItem(uint256 _itemId) public view {
        require(items[_itemId].owner == msg.sender, "Only the owner can sell");
        // transfer item to bidder
    }
}
