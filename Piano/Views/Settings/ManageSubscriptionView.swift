import SwiftUI
import StoreKit

struct ManageSubscriptionView: View {
    
    @State private var showManageSubscriptionSheet: Bool = false
    
    @Environment(SubscriptionManager.self) private var subscription

    var body: some View {
        Form {
            if subscription.isLifetime {
                Text("Chord Studio Lifetime is active.")
            } else {
                if let status = subscription.status, let willAutoRenew = subscription.willAutoRenew {
                    Section("Current Period Status") {
                        HStack {
                            Text("Status")
                            Spacer()
                            Text(status)
                                .foregroundStyle(Color.secondary)
                        }
                        if let startDate = subscription.subscriptionStartDate,
                           let endDate = subscription.subscriptionEndDate {
                            HStack {
                                Text("Start")
                                Spacer()
                                Text(startDate.formatted())
                                    .foregroundStyle(Color.secondary)
                            }
                            HStack {
                                Text("End")
                                Spacer()
                                Text(endDate.formatted())
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    }
                    
                    Section(header: Text("Auto Renewal")) {
                        HStack {
                            Text("Auto Renewal")
                            Spacer()
                            Text(willAutoRenew ? "Active" : "Inactive")
                                .foregroundStyle(Color.secondary)
                        }
#if !os(macOS)
                        Button("Edit") {
                            showManageSubscriptionSheet.toggle()
                        }
#else
                        Text("To cancel auto renewal, go to Settings > Apple Account > Media & Purchases > Subscriptions.")
#endif
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .onChange(of: showManageSubscriptionSheet) {
            Task {
                await subscription.getDetail()
            }
        }
#if !os(macOS)
        .manageSubscriptionsSheet(isPresented: $showManageSubscriptionSheet)
#endif
        .task {
            await subscription.getDetail()
        }
        .navigationTitle("Manage Subscription")
        .inlineNavigationTitle()
    }
}

#Preview {
    ManageSubscriptionView()
}
