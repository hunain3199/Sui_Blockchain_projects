/*
#[test_only]
module nft_marketplace::nft_marketplace_tests;
// uncomment this line to import the module
// use nft_marketplace::nft_marketplace;

const ENotImplemented: u64 = 0;

#[test]
fun test_nft_marketplace() {
    // pass
}

#[test, expected_failure(abort_code = ::nft_marketplace::nft_marketplace_tests::ENotImplemented)]
fun test_nft_marketplace_fail() {
    abort ENotImplemented
}
*/

module nft_marketplace::tests {
    use sui::object::{ID, UID};
    use sui::coin::{Coin, Self};
    use sui::tx_context::test_only::new_test_tx_context;
    use sui::transfer;
    use sui::bag;
    use sui::table;
    use nft_marketplace::nft_marketplace::{Marketplace, Listing};

    /// A mock struct representing an item to be listed.
    struct MockItem has key, store {
        id: UID,
    }

    /// Helper function to create a `MockItem`.
    fun create_mock_item(ctx: &mut TxContext): MockItem {
        MockItem {
            id: object::new(ctx),
        }
    }

    /// Test creating a marketplace.
    public fun test_create() {
        let mut ctx = new_test_tx_context();
        nft_marketplace::nft_marketplace::create<sui::SUI>(&mut ctx);

        // Assert that the marketplace object was created and shared.
        let marketplace = transfer::fetch_object::<Marketplace<sui::SUI>>(ctx.sender());
        assert!(marketplace.id != ID::zero(), "Marketplace creation failed");
        assert!(bag::is_empty(&marketplace.items), "Marketplace should start with no items");
        assert!(table::is_empty(&marketplace.payments), "Payments table should be empty");
    }

    /// Test listing an item in the marketplace.
    public fun test_list() {
        let mut ctx = new_test_tx_context();

        // Step 1: Create a marketplace.
        nft_marketplace::nft_marketplace::create<sui::SUI>(&mut ctx);
        let mut marketplace = transfer::fetch_object_mut::<Marketplace<sui::SUI>>(ctx.sender());

        // Step 2: Create a mock item.
        let item = create_mock_item(&mut ctx);

        // Step 3: List the item in the marketplace.
        nft_marketplace::nft_marketplace::list<MockItem, sui::SUI>(&mut marketplace, item, 100, &mut ctx);

        // Verify that the item was listed correctly.
        let item_id = object::id(&item);
        let listing = bag::get::<Listing>(&marketplace.items, item_id);
        assert!(listing.is_some(), "Listing should exist in the marketplace");
        let listing = listing.unwrap();
        assert!(listing.ask == 100, "Listing price should be 100");
        assert!(listing.owner == ctx.sender(), "Listing owner should match transaction sender");
    }
}
