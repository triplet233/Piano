import SwiftUI
import StoreKit

struct SubscriptionView: View {
    
    @Environment(SubscriptionManager.self) private var subscription
    @Environment(\.verticalSizeClass) private var sizeClass
    @Environment(\.purchase) private var purchase: PurchaseAction
    @Environment(\.dismiss) private var dismiss
    

    var body: some View {
        
        VStack {
            let layout = sizeClass == .compact
                ? AnyLayout(HStackLayout(spacing: 20))
                : AnyLayout(VStackLayout(spacing: 20))
            
            layout {
                Image(systemName: "crown")
                    .font(.system(size: 50))
                    .foregroundStyle(.yellow)

                Text(subscription.isSubscribed ? String(localized: "Enjoy Pro Features") : String(localized: "Upgrade to Pro"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding()

            
            List {
                FeatureRowView(icon: "guitars", title: String(localized: "More Instruments & Styles")) {
                    Text("• More instruments")
                    Text("• Unlock rolled chords")
                }
                FeatureRowView(icon: "paintbrush", title: String(localized: "Additonal Features")) {
                    Text("• Unlock more theme colors")
                }
            }
            .scrollContentBackground(.hidden)
            
            if !subscription.isSubscribed {
                if let lifetimeProduct = subscription.lifetimeProduct  {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            
                        
                            Text(lifetimeProduct.displayPrice)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("One time purchase.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                    
                        }
                        Spacer()
                        VStack(alignment: .trailing) {

                            Button {
                                Task {
                                    let productSelected = lifetimeProduct
                                    let result = try? await purchase(productSelected)
                                    switch result {
                                    case .success(let verification):
                                        switch verification {
                                        case .verified(let transaction):
                                            await transaction.finish()
                                            await subscription.updateSubscriptionStatus()
                                            dismiss()
                                        default: break
                                        }
                                    default: return
                                    }
                                }
                            } label: {
                                Text("Get Pro")
                                    .padding(2)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            .buttonStyle(.glassProminent)
                        }
                    }
                    .padding()
                    
                } else {
                    ProgressView("Loading subscription details...")
                        .padding()
                }
            }
        }
        .task {
            await subscription.getProducts()
        }
        .toolbarCloseButton(dismiss: dismiss)
    }
}


#Preview {
    SubscriptionView()
}
