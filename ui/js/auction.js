$(document).ready(function () {	
	
	let contract;
	let provider;
	async function initConnect() {

		provider = new ethers.providers.Web3Provider(window.ethereum)	
		signer = provider.getSigner();
		let contractAddress = "0xfcA10c67e10f25976e4Db1EC271A8A144f8D9576";
		let abi = [
			{
				"inputs": [
					{
						"internalType": "uint256",
						"name": "_regTime",
						"type": "uint256"
					}
				],
				"stateMutability": "nonpayable",
				"type": "constructor"
			},
			{
				"anonymous": false,
				"inputs": [
					{
						"indexed": false,
						"internalType": "uint256",
						"name": "itemId",
						"type": "uint256"
					},
					{
						"indexed": false,
						"internalType": "address",
						"name": "winner",
						"type": "address"
					}
				],
				"name": "AuctionCompleted",
				"type": "event"
			},
			{
				"anonymous": false,
				"inputs": [
					{
						"indexed": false,
						"internalType": "uint256",
						"name": "itemId",
						"type": "uint256"
					},
					{
						"indexed": false,
						"internalType": "uint256",
						"name": "reservePrice",
						"type": "uint256"
					},
					{
						"indexed": false,
						"internalType": "uint256",
						"name": "startPrice",
						"type": "uint256"
					},
					{
						"indexed": false,
						"internalType": "uint256",
						"name": "auctionEndTime",
						"type": "uint256"
					}
				],
				"name": "AuctionStarted",
				"type": "event"
			},
			{
				"anonymous": false,
				"inputs": [
					{
						"indexed": false,
						"internalType": "uint256",
						"name": "itemId",
						"type": "uint256"
					},
					{
						"indexed": false,
						"internalType": "address",
						"name": "bidder",
						"type": "address"
					}
				],
				"name": "SecretBidPlaced",
				"type": "event"
			},
			{
				"inputs": [
					{
						"internalType": "address",
						"name": "",
						"type": "address"
					}
				],
				"name": "bidders",
				"outputs": [
					{
						"internalType": "bool",
						"name": "",
						"type": "bool"
					}
				],
				"stateMutability": "view",
				"type": "function"
			},
			{
				"inputs": [
					{
						"internalType": "uint256",
						"name": "itemId",
						"type": "uint256"
					}
				],
				"name": "buy",
				"outputs": [],
				"stateMutability": "payable",
				"type": "function"
			},
			{
				"inputs": [
					{
						"internalType": "uint256",
						"name": "reservePrice",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "startPrice",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "auctionDuration",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "reductionRate",
						"type": "uint256"
					}
				],
				"name": "createItem",
				"outputs": [],
				"stateMutability": "nonpayable",
				"type": "function"
			},
			{
				"inputs": [],
				"name": "deposit",
				"outputs": [],
				"stateMutability": "payable",
				"type": "function"
			},
			{
				"inputs": [],
				"name": "getMembersCount",
				"outputs": [
					{
						"internalType": "uint256",
						"name": "",
						"type": "uint256"
					}
				],
				"stateMutability": "view",
				"type": "function"
			},
			{
				"inputs": [
					{
						"internalType": "uint256",
						"name": "itemId",
						"type": "uint256"
					}
				],
				"name": "getPrice",
				"outputs": [
					{
						"internalType": "uint256",
						"name": "",
						"type": "uint256"
					}
				],
				"stateMutability": "view",
				"type": "function"
			},
			{
				"inputs": [],
				"name": "inductMember",
				"outputs": [],
				"stateMutability": "nonpayable",
				"type": "function"
			},
			{
				"inputs": [
					{
						"internalType": "uint256",
						"name": "",
						"type": "uint256"
					}
				],
				"name": "items",
				"outputs": [
					{
						"internalType": "address",
						"name": "owner",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "reservePrice",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "startPrice",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "currentPrice",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "reductionRate",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "auctionEndTime",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "highestBid",
						"type": "uint256"
					},
					{
						"internalType": "bool",
						"name": "sold",
						"type": "bool"
					},
					{
						"internalType": "uint256",
						"name": "auctionStartTime",
						"type": "uint256"
					}
				],
				"stateMutability": "view",
				"type": "function"
			},
			{
				"inputs": [
					{
						"internalType": "address",
						"name": "",
						"type": "address"
					}
				],
				"name": "members",
				"outputs": [
					{
						"internalType": "bool",
						"name": "",
						"type": "bool"
					}
				],
				"stateMutability": "view",
				"type": "function"
			},
			{
				"inputs": [],
				"name": "nOfMembers",
				"outputs": [
					{
						"internalType": "uint256",
						"name": "",
						"type": "uint256"
					}
				],
				"stateMutability": "view",
				"type": "function"
			},
			{
				"inputs": [],
				"name": "noOfbidders",
				"outputs": [
					{
						"internalType": "uint256",
						"name": "",
						"type": "uint256"
					}
				],
				"stateMutability": "view",
				"type": "function"
			},
			{
				"inputs": [
					{
						"internalType": "uint256",
						"name": "itemId",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "secretBid",
						"type": "uint256"
					}
				],
				"name": "placeSecretBid",
				"outputs": [],
				"stateMutability": "nonpayable",
				"type": "function"
			},
			{
				"inputs": [],
				"name": "regTime",
				"outputs": [
					{
						"internalType": "uint256",
						"name": "",
						"type": "uint256"
					}
				],
				"stateMutability": "view",
				"type": "function"
			},
			{
				"inputs": [
					{
						"internalType": "uint256",
						"name": "itemId",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "extraPrice",
						"type": "uint256"
					}
				],
				"name": "updatePrice",
				"outputs": [
					{
						"internalType": "uint256",
						"name": "",
						"type": "uint256"
					}
				],
				"stateMutability": "nonpayable",
				"type": "function"
			}
		];
		contract = new ethers.Contract( contractAddress , abi , signer );
		
		//------------------------------------- METAMASK BOILERPPLATE------------------//
	
		window.ethereum.on('chainChanged', handleChainChanged);
		window.ethereum.on('accountsChanged', handleAccountsChanged);

		}

	
	function handleChainChanged(_chainId) {
	  // We recommend reloading the page, unless you must do otherwise
	  console.log("changed chain "+_chainId)
	}
	
	function handleAccountsChanged(accounts) {
	  // We recommend reloading the page, unless you must do otherwise
	  console.log("acccount changed "+ accounts)
	}
	
	const checkEvents = async()=>{
		contract.on("SecretBidPlaced",(itemId, secretBid)=>{
			console.log("event aaya", itemId, secretBid)
			alert("Yay!! Bid Placed")
		})
		contract.on("AuctionCompleted",(itemCount, reservePrice, startPrice, auctionEndTime)=>{
			console.log("event aaya", itemCount, reservePrice)
			alert("Yay!! Auction Comp0leted ", reservePrice)
		})

	};
	$("#connect").click(async function async() {
		initConnect();
		await provider.send("eth_requestAccounts", []);
		signer = provider.getSigner()
		console.log(signer);
		$("#connect").text(await signer.getAddress());
		

	});


	$("#inductember").click(async function async() {
		
		await provider.send("eth_requestAccounts", []);
		signer = provider.getSigner();
		let status = await contract
			.electionStarted()
		
		$("#status").text(JSON.stringify(status));

	});


	$("#enroll").click(async function async() {
	console.log("add User")
		// let name = $('#voter_wallet').val();
		let tx = await contract.inductMember();
		console.log(tx)
	});

	$("#create_item").click(async function async() {
		console.log("yaha aaya")
			let reservePrice = $('#reservePrice').val();
			let startPrice = $('#reservePrice').val();
			let auctionDuration = $('#auctionDuration').val();
			let reductionRate = $('#reductionRate').val();

			let tx = await contract.createItem(reservePrice, startPrice, auctionDuration, reductionRate);
			console.log(tx)
		});

	$("#get_members").click(async function async() {
		
		let count = await contract.getMembersCount();
		// console.log(count);
		count = ethers.utils.arrayify( count._hex )[0];
		console.log(count ); 
		$("#get_members").text("Number of members enrolled " + count);
	});

	$("#place_bid").click(async function async() {
			let secretBid = $('#secret_bid_amount').val();		
			let tx = await contract.placeSecretBid(0,secretBid);
			console.log(tx)
			checkEvents();
		});



		$("#update_price").click(async function async() {
				let amountTobeAdded = $('#extra_amount').val();
				let tx = await contract.updatePrice(0,amountTobeAdded );
				console.log(tx)
			});

			$("#get_price").click(async function async() {
				let tx = await contract.getPrice(0);
		
				count = ethers.utils.arrayify( tx._hex )[0];
				console.log(count ); 
			$("#get_price").text("current Price " + count);
			});
	

			$("#buy").click(async function async() {
				let amount = $('#amount').val();
				let tx = await contract.buy(0,{value:amount} );
				console.log(tx)
			});

	
	$("#SecretBidPlaced").addEventListener(async function async(event){
		console.log(event)
	})
	



});

document.addEventListener('SecretBidPlaced', function (event) {
	console.log(event.detail);
});