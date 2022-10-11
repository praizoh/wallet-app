// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Wallet {

    // enum to hold the types of transactions
    enum transaction_types { 
        DEBIT,
        CREDIT
    }
    
    //event to be emitted when a new wallet is created
    event NewWalletCreated(
        bytes32 walletId,
        address walletOwner,
        uint256 accountBalance,
        uint256 timeStampCreated
    );

    //event to be emitted when a wallet is credited
    event WalletCredited(
        bytes32 walletId,
        address walletOwner,
        uint256 amount,
        uint256 accountBalance,
        uint256 timeStampCredited
    );

    //event to be emitted when a wallet is debited
    event WalletDebited(
        bytes32 walletId,
        address walletOwner,
        uint256 amount,
        uint256 accountBalance,
        uint256 timeStampCredited
    );

    // wallet struct
    struct CreateWallet {
        bytes32 walletId;
        address walletOwner;
        uint256 accountBalance;
        uint256 timeStampCreated;
        Transaction[] transactions;
    }

    // transaction struct
    struct Transaction {
        bytes32 transactionId;
        uint256 timestamp;
        uint256 amount;
        transaction_types transactionType;
    }

    mapping(bytes32 => CreateWallet) public idToWallet;

    function CreateNewWallet() external {
        bytes32 walletId = keccak256(
            abi.encodePacked(
                msg.sender,
                address(this),
                block.timestamp
            )
        );
        // this creates a new wallet struct and adds it to the idToWallet mapping
        CreateWallet storage wallet = idToWallet[walletId];
        wallet.walletId = walletId;
        wallet.walletOwner = msg.sender;
        wallet.accountBalance = 0;
        wallet.timeStampCreated = block.timestamp;

        emit NewWalletCreated(
            walletId,
            msg.sender,
            0,
            block.timestamp
        );
    }

    function CreditWallet(bytes32 walletId, uint256 amount) external payable{

        CreateWallet storage myWallet = idToWallet[walletId];
        require(msg.sender == myWallet.walletOwner, "NOT AUTHORIZED");
        require(msg.value == amount, "Amount is not correct with transaction amount");
        // get wallet
        myWallet.accountBalance += amount;

        bytes32 transactionId = keccak256(
            abi.encodePacked(
                msg.sender,
                address(this),
                block.timestamp,
                amount,
                walletId
            )
        );
        myWallet.transactions.push(Transaction(
            transactionId,
            block.timestamp,
            amount,
            transaction_types.CREDIT
        ));

        emit WalletCredited(
            walletId,
            msg.sender,
            amount,
            myWallet.accountBalance,
            block.timestamp
        );
    }

    function DebitWallet(bytes32 walletId, uint256 amount) external payable{
        CreateWallet storage myWallet = idToWallet[walletId];
        require(msg.sender == myWallet.walletOwner, "NOT AUTHORIZED");
        require(myWallet.accountBalance >= amount, "You cannot withdraw more than the money in wallet");

        // sending eth back to the user `https://solidity-by-example.org/sending-ether`
        (bool sent,) = msg.sender.call{value: amount}("");
        if (sent) {
            myWallet.accountBalance -= amount;
        }

        bytes32 transactionId = keccak256(
            abi.encodePacked(
                msg.sender,
                address(this),
                block.timestamp,
                amount,
                walletId
            )
        );
        myWallet.transactions.push(Transaction(
            transactionId,
            block.timestamp,
            amount,
            transaction_types.CREDIT
        ));

        emit WalletDebited(
            walletId,
            msg.sender,
            amount,
            myWallet.accountBalance,
            block.timestamp
        );
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}