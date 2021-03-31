// SPDX-License-Identifier: GPL-3.0
// authors Mohamed El Jarrari, Ludovic Jacob, Shiny Saing

pragma solidity >=0.7.0 <0.8.0;
pragma experimental ABIEncoderV2;

contract Marketplace {
    enum SaleState {
        OnSale,
        Sold,
        Cancelled
    }
    
    struct Item {
        uint id;
        string name;
        address payable owner;
    }
    
    struct Sale {
        uint id;
        uint itemId;
        uint price;
        SaleState state;
        address payable seller;
        address payable buyer;
    }
    
    mapping (uint => Item) items;
    mapping (uint => Sale) sales;
    
    uint idCounter = 0;
    
    modifier openSale(uint _saleId) {
        require(sales[_saleId].state == SaleState.OnSale, "Item is not on sale!");
        _;
    }
    
    function generateId() private returns(uint) {
        idCounter++;
        return idCounter;
    }
    
    function newItem(string memory _name) public returns (uint) {
        uint id = generateId();
        Item memory item = Item(
            id,
            _name,
            msg.sender
        );
        items[id] = item;
        return id;
    }
    
    function newSale(uint itemId, uint _price) public returns (uint) {
        require(msg.sender == getItem(itemId).owner, "Only the owner of the item can sell it!");
        uint id = generateId();
        Sale memory sale = Sale(
            id,
            itemId,
            _price,
            SaleState.OnSale,
            msg.sender,
            address(0x0)
        );
        sales[id] = sale;
        return id;
    }
    
    function buyItem(uint _saleId) openSale(_saleId) public payable {
        require(msg.sender.balance > msg.value, "Insufficient balance!");
        Sale storage sale = sales[_saleId]; // Using the storage keyword in order to persist any changes done to the objects
        require(msg.value >= sale.price, "Not enough money sent!");
        Item storage item = items[sale.itemId];
        item.owner.transfer(sale.price);
        msg.sender.transfer(msg.value - sale.price); // Cash back
        sale.buyer = msg.sender;
        sale.state = SaleState.Sold;
        item.owner = msg.sender;
    }
    
    function cancelSale(uint _saleId) public openSale(_saleId) {
        sales[_saleId].state = SaleState.Cancelled; // Calling the getter generates the warning: "Function state mutability can be restricted to view"
    }
    
    function getItem(uint _itemId) public view returns (Item memory) {
        return items[_itemId];
    }
    
    function getSale(uint _saleId) public view returns (Sale memory) {
        return sales[_saleId];
    }
}