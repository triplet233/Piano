import StoreKit

@MainActor
@Observable
class SubscriptionManager {

    
    var lifetimeProduct: Product? = nil
    var isSubscribed = false

    let lifetimeProductId = "piano_pro"
    
    func updateSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if !transaction.isUpgraded, transaction.productID == lifetimeProductId {
                    isSubscribed = true
                    return
                }
            case .unverified: break
            }
        }
        isSubscribed = false
    }
    
    func startTransactionListener() async {
        
        for await result in Transaction.updates {
            switch result {
            case .verified(let transaction):
                await transaction.finish()
                await updateSubscriptionStatus()
            case .unverified(_, let error):
                print("Unverified transaction: \(error)")
            }
        }
    }
    func getProducts() async {
        
        guard let lifetimeProduct = try? await Product.products(for: [lifetimeProductId]).first else { return }
        
        self.lifetimeProduct = lifetimeProduct
        
    }

    
    func restorePurchases() async {
        try? await AppStore.sync()
    }
}

