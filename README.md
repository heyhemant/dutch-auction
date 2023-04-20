Contract Address: 0xd7432E68aE19dC47762aC849dAeE42edD38c1B7a

Stage 0: A user must be inducted as a member of the Dapp with their profile. The profile must be linked to the user’s wallet and contain other information about them. Bonus points for a well-rounded profile with a profile picture and other data (stored in a decentralised manner).

Stage 1: A item owner can announce an auction on a list of items. The owner sets a reserve price for every time (a price below which they are not willing to sell the item - this information must remain a secret to the bidders). As a bonus, the auction notification can be sent to all members.

Stage 2: Members log in to their profile to perform a secret bid, to announce the maximum price they are willing to bid for an item. They can choose not to bid as well. The secret bid is open for a limited time or until all members have made their secret bid, whichever comes earlier. Note that the secret bid must remain secret i.e no other member or even the owner can find out what each member has bid. Every member can place at most one secret bid per item.

Stage 3: When the secret bid is closed, only the member who participated will advance to the next round of the auction. The highest bid plus a positive integer value 'x' is chosen as the start price for an item. The dutch auction begins.

Stage 4: Periodically, (say every 2 minutes) the value of the item price reduces by constant 'y' linearly. Every participating user must be able to see the current item price on the auction page. A user may bid for the item at any time. The first person to bid for the item receives it and the auction for that item ends.

Stage 5: the auction is over when all the items are sold, or the item price has reached its reserve price. The Dapp must display the items with their owners on the auction page.

