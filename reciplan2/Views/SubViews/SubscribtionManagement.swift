import StoreKit
import SwiftUI

struct SubscriptionManagementView: View {
    @EnvironmentObject var store: SKStore
    
    @State private var currentSubscription: Product?
    @State private var currentStatus: Product.SubscriptionInfo.Status?
    @State private var currentRenewalInfo: Product.SubscriptionInfo.RenewalInfo?
    @State private var showManageSubscriptionSheet: Bool = false
    @State private var showRefundSheet: Bool = false

    var availableSubscriptions: [Product] {
        store.subscriptions.filter { $0.id != currentSubscription?.id }
    }
    
    @ViewBuilder
    private func subscriptionBuyButton(subscription: Product) -> some View {
        Button {
            Task {
                do {
                    if let transaction = try await store.purchase(subscription) {
                        print(transaction)
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        } label: {
            HStack {
                Label("Subscribe", systemImage: "purchased.circle")
                Spacer()
                Text("\(subscription.displayPrice) / year").font(.body).bold()
            }
        }
    }
    
    var body: some View {
        Form {
            Text("Reciplan Premium is an optional subscription which helps fund future development.").font(.footnote)
            
            if !availableSubscriptions.isEmpty {
                Section(header: Text("Subscription"), footer: Text("Thanks for using Reciplan ❤️")) {
                    ForEach(availableSubscriptions) { subscription in
                        subscriptionBuyButton(subscription: subscription)
                    }
                    
                    Button("Restore Purchases") {
                        Task {
                            // This call displays a system prompt that asks users to authenticate with their App Store credentials.
                            // Call this function only in response to an explicit user action, such as tapping a button.
                            try? await AppStore.sync()
                        }
                    }
                }
            }
            
            if let sub = currentSubscription,
               let status = currentStatus,
               let _ = currentRenewalInfo,
               let payload = try? status.transaction.payloadValue {
                Section(header: Text("Active Subscription"), footer: Text("Thanks for supporting Reciplan ❤️")) {
                    VStack(alignment: .leading) {
                        HStack {
                            let date = payload.purchaseDate.formatted(date: .abbreviated, time: .omitted)
                            Label("Subscribed", systemImage: "purchased.circle.fill")
                            Spacer()
                            Text("since \(date)").font(.footnote).foregroundColor(.gray)
                        }
                        
                        Group {
                            Text("\(sub.displayPrice) / year")
                            Text("Renews: \(payload.expirationDate?.formatted(date: .abbreviated, time: .omitted) ?? "")")
                        }.font(.footnote).foregroundColor(.gray)
                    }
                    .font(.body)
                    
                    Button {
                        showManageSubscriptionSheet = true
                    } label: {
                        Text("Manage Subscription")
                    }
                    
                    Button("Restore Purchases") {
                        Task {
                            // This call displays a system prompt that asks users to authenticate with their App Store credentials.
                            // Call this function only in response to an explicit user action, such as tapping a button.
                            try? await AppStore.sync()
                        }
                    }
                    
                    Button {
                        showRefundSheet = true
                    } label: {
                        Text("Refund").foregroundColor(.red)
                    }
                }
                // *** DOESN'T WORK WITH XCODE STOREKIT TESTING. MUST USE SANDBOX OR iOS >=15.2 ***
                .manageSubscriptionsSheet(isPresented: $showManageSubscriptionSheet)
                .refundRequestSheet(for: payload.id, isPresented: $showRefundSheet) {
                    result in // Result<Transaction.RefundRequestStatus, Transaction.RefundRequestError>
                    print(result)
                    // TODO: Maybe show something in the UI indicating that the refund is processing
                }
                
                Section(header: Text("Help")) {
                    Text("Manage your subscription right here in the app or in Settings > Apple ID > Subscriptions.").font(.footnote)
                }
            }
        }
        .interactionActivityTrackingTag("SubscriptionView")
        .onAppear {
            Task {
                // When this view appears, get the latest subscription status.
                await updateSubscriptionStatus()
            }
        }
        .onChange(of: store.purchasedIdentifiers) {
            Task {
                // When `purchasedIdentifiers` changes, get the latest subscription status.
                await updateSubscriptionStatus()
            }
        }
        .font(.body)
        .navigationTitle("Subscription")
    }
    
    @MainActor
    func updateSubscriptionStatus() async {
        do {
            // This app has only one subscription group so products in the subscriptions
            // array all belong to the same group. The statuses returned by
            // `product.subscription.status` apply to the entire subscription group.
            guard let product = store.subscriptions.first,
                  let statuses = try await product.subscription?.status else {
                return
            }

            // Iterate through `statuses` for this subscription group and find
            // the `Status` with the highest level of service which isn't expired or revoked.
            for status in statuses {
                switch status.state {
                case .expired, .revoked:
                    continue
                default:
                    let renewalInfo = try store.checkVerified(status.renewalInfo)
                    
                    guard let newSubscription = store.subscriptions.first(where: { $0.id == renewalInfo.currentProductID }) else {
                        continue
                    }
                    
                    currentSubscription = newSubscription
                    currentStatus = status
                    currentRenewalInfo = renewalInfo
                }
            }
        } catch {
            print("Could not update subscription status \(error)")
        }
    }
}
