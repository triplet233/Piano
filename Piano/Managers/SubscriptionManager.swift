import StoreKit

@MainActor
@Observable
class SubscriptionManager {

    var product: Product? = nil
    var lifetimeProduct: Product? = nil
    var isSubscribed = false
    var isLifetime = false
    
    var subscriptionStartDate: Date?
    var subscriptionEndDate: Date?
    var status: String?
    var willAutoRenew: Bool?
    
    let productId = "01"
    let lifetimeProductId = "02"
    
    func updateSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if !transaction.isUpgraded, transaction.productID == productId {
                    isSubscribed = true
                    subscriptionStartDate = transaction.purchaseDate
                    subscriptionEndDate = transaction.expirationDate
                    return
                } else if !transaction.isUpgraded, transaction.productID == lifetimeProductId {
                    isSubscribed = true
                    isLifetime = true
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
        
        guard let product = try? await Product.products(for: [productId]).first else { return }
        guard let lifetimeProduct = try? await Product.products(for: [lifetimeProductId]).first else { return }
        
        self.product = product
        self.lifetimeProduct = lifetimeProduct
        
    }
    func getDetail() async {

        guard let product else { return }
        
        let statuses = try? await product.subscription?.status ?? []
        
        if let status = statuses?.first {
            self.status = switch status.state {
            case .subscribed: "Active"
            case .expired: "Expired"
            case .inGracePeriod: "In grace period"
            case .inBillingRetryPeriod: "In billing retry"
            case .revoked: "Revoked"
            default: "Unknown"
            }
            self.willAutoRenew = try? status.renewalInfo.payloadValue.willAutoRenew
        }
    }
    
    func restorePurchases() async {
        try? await AppStore.sync()
    }
}

