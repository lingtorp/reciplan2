import Foundation
import StoreKit

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public enum StoreError: Error {
    case failedVerification
}

// FIXME: Convert to @Observable
class SKStore: ObservableObject {
    // Purchased subscription(s) and items
    @Published private(set) var purchasedIdentifiers = Set<String>()
    @Published private(set) var subscriptions: [Product] = []
    
    // Used to fetch products from App Store
    private let productIds: [String: String]
    private var updateListenerTask: Task<Void, Error>? = nil
    
    init() {
        if let path = Bundle.main.path(forResource: "Products", ofType: "plist"),
        let plist = FileManager.default.contents(atPath: path) {
            productIds = (try? PropertyListSerialization.propertyList(from: plist, format: nil) as? [String: String]) ?? [:]
        } else {
            productIds = [:]
        }

        // Start a transaction listener as close to app launch as possible so you don't miss any transactions.
        updateListenerTask = listenForTransactions()
        
        Task {
            // Initialize the store by starting a product request.
            await requestProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Iterate through any transactions which didn't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    // Deliver content to the user - nothing to deliver
                    await self.updatePurchasedIdentifiers(transaction)
                    
                    // Always finish a transaction.
                    await transaction.finish()
                } catch {
                    // StoreKit has a receipt it can read but it failed verification. Don't deliver content to the user.
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    // Check if the transaction passes StoreKit verification
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            // StoreKit has parsed the JWS but failed verification. Don't deliver content to the user.
            throw StoreError.failedVerification
        case .verified(let safe):
            // If the transaction is verified, unwrap and return it.
            return safe
        }
    }
    
    // Begin a purchase
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            // Deliver content to the user.
            await updatePurchasedIdentifiers(transaction)
            
            // Always finish a transaction.
            await transaction.finish()

            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }
    
    @MainActor // NOTE: Ensures all @Published, etc are modified on the main queue
    func updatePurchasedIdentifiers(_ transaction: Transaction) async {
        if transaction.revocationDate == nil {
            // If the App Store has not revoked the transaction, add it to the list of `purchasedIdentifiers`.
            purchasedIdentifiers.insert(transaction.productID)
        } else {
            // If the App Store has revoked this transaction, remove it from the list of `purchasedIdentifiers`.
            purchasedIdentifiers.remove(transaction.productID)
        }
    }
    
    @MainActor
    func requestProducts() async {
        do {
            // Request products from the App Store using the identifiers defined in the Products.plist file.
            let storeProducts = try await Product.products(for: productIds.keys)

            // Filter the products into different categories based on their type.
            for product in storeProducts {
                switch product.type {
                case .consumable:
                    // Ignore this product.
                    break
                case .nonConsumable:
                    // Ignore this product.
                    break
                case .autoRenewable:
                    subscriptions.append(product)
                default:
                    // Ignore this product.
                    print("Unknown product")
                }
            }
        } catch {
            print("Failed product request: \(error)")
        }
    }
}
