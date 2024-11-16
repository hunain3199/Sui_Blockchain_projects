/*
/// Module: nft_project
module nft_project::nft_project;
*/

module nft_project::nft_project {
    use sui::url::Url;
    use std::string;
    use sui::object::{ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::TxContext;

    public struct ExampleNFT has key, store {
        id: UID,
        name: string::String,
        description: string::String,
        
    }

    public struct NFTMinted has copy, drop {
        object_id: ID,
        creator: address,
        name: string::String,
    }

    // Function to get the name of the NFT
    public fun name(nft: &ExampleNFT): &std::string::String {
        &nft.name
    }

    // Function to get the description of the NFT
    public fun description(nft: &ExampleNFT): &std::string::String {
        &nft.description
    }

    // Function to get the URL of the NFT as a string
//     public fun url(nft: &ExampleNFT): std::string::String {
//     let url_bytes = vector::empty<u8>();  // Placeholder, replace with actual byte data
//     return string::utf8(url_bytes);  // Convert byte vector to string
// }


    // Mint an NFT to the sender
    public fun mint_to_sender(
    name: vector<u8>,
    description: vector<u8>,
    _ctx: &mut TxContext
) {
    let sender = tx_context::sender(_ctx);

  

    let nft = ExampleNFT {
        id: object::new(_ctx),
        name: string::utf8(name),
        description: string::utf8(description),
         // Assign the created URL
    };

    event::emit(NFTMinted {
        object_id: object::id(&nft),
        creator: sender,
        name: nft.name,
    });

    transfer::public_transfer(nft, sender);
}


    // Transfer the NFT to another recipient
    public entry fun transfer(
        nft: ExampleNFT,
        recipient: address,
        _ctx: &mut TxContext
    ) {
        transfer::public_transfer(nft, recipient);
    }

    // Update the description of an NFT
    public entry fun update_description(
        nft: &mut ExampleNFT,
        new_description: vector<u8>,
        _ctx: &mut TxContext
    ) {
        nft.description = string::utf8(new_description);
    }

    // Permanently delete the NFT
    public entry fun burn(
        nft: ExampleNFT,
        _ctx: &mut TxContext
    ) {
        let ExampleNFT { id, name: _, description: _} = nft;
        object::delete(id);
    }
}
