import SwiftUI
import StoreKit

struct SubscriptionView: View {
    
    @State private var showLifetimePurchase: Bool = false
    
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
                    Text("• More chord, bass, and drum sounds")
                    Text("• Unlock 20+ styles")
                    Text("• Unlock rolled chords")
                }

                FeatureRowView(icon: "pencil.circle", title: String(localized: "Advanced Editing Mode")) {
                    Text("• Create chords with advanced alterations")
                    Text("• Use in songwriting mode and the chord dictionary")
                }
                FeatureRowView(icon: "paintbrush", title: String(localized: "Additonal Features")) {
                    Text("• Transpose, adjust voicing, and export MIDI in songwriting mode")
                    Text("• Unlock more theme colors")
                }
            }
            .scrollContentBackground(.hidden)
            
            if !subscription.isSubscribed {
                if let product = subscription.product, let lifetimeProduct = subscription.lifetimeProduct  {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            
                            if showLifetimePurchase {
                                Text(lifetimeProduct.displayPrice)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("One time purchase.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text(product.displayPrice + String(localized: " / month"))
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("Auto renewal, cancel anytime.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Button {
                                showLifetimePurchase.toggle()
                            } label: {
                                Text(showLifetimePurchase ? "See monthly option" : "See lifetime option")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .underline()
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                Task {
                                    let productSelected = showLifetimePurchase ? lifetimeProduct : product
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
