// MARK: - Listing Service for Desi Hub
import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import FirebaseCore
import Combine
import UIKit

@MainActor
class ListingService: ObservableObject {
    static let shared = ListingService()
    
    @Published var listings: [Listing] = []
    @Published var userListings: [Listing] = []
    @Published var userFavorites: [String] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var db: Firestore? {
        guard FirebaseApp.app() != nil else { return nil }
        return Firestore.firestore()
    }
    private var storage: Storage? {
        guard FirebaseApp.app() != nil else { return nil }
        return Storage.storage()
    }
    private var listeners: [ListenerRegistration] = []
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    @MainActor deinit {
        removeAllListeners()
    }
    
    // MARK: - Real-time Listeners
    func startListeningToListings() {
        removeAllListeners()

        guard let db = db else {
            error = ListingError.firebaseNotConfigured
            return
        }
        
        let listener = db.collection("listings")
            .whereField("status", in: [ListingStatus.active.rawValue, ListingStatus.featured.rawValue])
            .order(by: "isFeatured", descending: true)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.error = error
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.listings = documents.compactMap { document -> Listing? in
                    try? document.data(as: Listing.self)
                }
            }
        
        listeners.append(listener)
    }
    
    func startListeningToUserListings(userId: String) {
        guard let db = db else {
            error = ListingError.firebaseNotConfigured
            return
        }
        let listener = db.collection("listings")
            .whereField("authorId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.error = error
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.userListings = documents.compactMap { document -> Listing? in
                    try? document.data(as: Listing.self)
                }
            }
        
        listeners.append(listener)
    }
    
    func startListeningToUserFavorites(userId: String) {
        guard let db = db else {
            error = ListingError.firebaseNotConfigured
            return
        }
        let listener = db.collection("users")
            .document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.error = error
                    return
                }
                
                guard let data = snapshot?.data(),
                      let favorites = data["favorites"] as? [String] else {
                    self.userFavorites = []
                    return
                }
                
                self.userFavorites = favorites
            }
        
        listeners.append(listener)
    }
    
    func removeAllListeners() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }
    
    // MARK: - CRUD Operations
    func createListing(
        title: String,
        description: String,
        category: ListingCategory,
        price: Double?,
        neighborhood: DallasNeighborhood,
        images: [UIImage],
        contactInfo: ContactInfo
    ) async throws -> Listing {
        guard let db = db, let _ = storage else {
            throw ListingError.firebaseNotConfigured
        }
            // Allow guests by signing in anonymously when no user session exists.
            var currentUser = Auth.auth().currentUser
            if currentUser == nil {
                let authResult = try await Auth.auth().signInAnonymously()
                currentUser = authResult.user
            }
            guard let currentUser = currentUser else {
                throw ListingError.notAuthenticated
            }
        
        isLoading = true
        defer { isLoading = false }
        
        // Upload images to Firebase Storage
        var imageURLs: [String] = []
        for (index, image) in images.enumerated() {
            let url = try await uploadImage(image, for: currentUser.uid, index: index)
            imageURLs.append(url)
        }
        
        // Get user display name
            let userDocRef = db.collection("users").document(currentUser.uid)
            let userDoc = try await userDocRef.getDocument()
            if !userDoc.exists {
                try await userDocRef.setData([
                    "displayName": "Guest",
                    "createdAt": Timestamp(date: Date()),
                    "favorites": [],
                    "myListings": []
                ], merge: true)
            }
            let authorName = (userDoc.data()?["displayName"] as? String) ?? "Guest"
        
        let listing = Listing(
            title: title,
            description: description,
            category: category,
            price: price,
            neighborhood: neighborhood,
            imageURLs: imageURLs,
            contactInfo: contactInfo,
            authorId: currentUser.uid,
            authorName: authorName
        )
        
        let docRef = try db.collection("listings").addDocument(from: listing)
        
        // Add to user's myListings
            // Add to user's myListings
            try await userDocRef.setData([
                "myListings": FieldValue.arrayUnion([docRef.documentID])
            ], merge: true)
        
        var newListing = listing
        newListing.id = docRef.documentID
        
        return newListing
    }
    
    func fetchListings() async throws -> [Listing] {
        guard let db = db else { throw ListingError.firebaseNotConfigured }
        let snapshot = try await db.collection("listings")
            .whereField("status", in: [ListingStatus.active.rawValue])
            .order(by: "isFeatured", descending: true)
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: Listing.self) }
    }
    
    func fetchListing(by id: String) async throws -> Listing? {
        guard let db = db else { throw ListingError.firebaseNotConfigured }
        let doc = try await db.collection("listings").document(id).getDocument()
        return try? doc.data(as: Listing.self)
    }
    
    func deleteListing(_ listing: Listing) async throws {
        guard let db = db, let storage = storage else {
            throw ListingError.firebaseNotConfigured
        }
        guard let currentUser = Auth.auth().currentUser else {
            throw ListingError.notAuthenticated
        }
        
        guard let listingId = listing.id else {
            throw ListingError.invalidListingId
        }
        
        // Verify ownership
        guard listing.authorId == currentUser.uid else {
            throw ListingError.notAuthorized
        }
        
        // Delete images from storage
        for imageURL in listing.imageURLs {
            if URL(string: imageURL) != nil {
                let storageRef = storage.reference(forURL: imageURL)
                try? await storageRef.delete()
            }
        }
        
        // Delete document
        try await db.collection("listings").document(listingId).delete()
        
        // Remove from user's myListings
        try await db.collection("users").document(currentUser.uid).updateData([
            "myListings": FieldValue.arrayRemove([listingId])
        ])
    }
    
    // MARK: - Favorites
    func toggleFavorite(listingId: String) async throws {
        guard let db = db else { throw ListingError.firebaseNotConfigured }
        guard let currentUser = Auth.auth().currentUser else {
            throw ListingError.notAuthenticated
        }
        
        let userRef = db.collection("users").document(currentUser.uid)
        let userDoc = try await userRef.getDocument()
        
        let favorites = userDoc.data()?["favorites"] as? [String] ?? []
        
        if favorites.contains(listingId) {
            try await userRef.updateData([
                "favorites": FieldValue.arrayRemove([listingId])
            ])
        } else {
            try await userRef.updateData([
                "favorites": FieldValue.arrayUnion([listingId])
            ])
        }
    }
    
    func fetchFavoriteListings() async throws -> [Listing] {
        guard let db = db else { throw ListingError.firebaseNotConfigured }
        guard let currentUser = Auth.auth().currentUser else {
            throw ListingError.notAuthenticated
        }
        
        let userDoc = try await db.collection("users").document(currentUser.uid).getDocument()
        let favorites = userDoc.data()?["favorites"] as? [String] ?? []
        
        guard !favorites.isEmpty else { return [] }
        
        // Firestore 'in' queries limited to 10 items
        var allListings: [Listing] = []
        let chunks = favorites.chunked(into: 10)
        
        for chunk in chunks {
            let snapshot = try await db.collection("listings")
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments()
            
            let listings = snapshot.documents.compactMap { try? $0.data(as: Listing.self) }
            allListings.append(contentsOf: listings)
        }
        
        return allListings
    }
    
    func isFavorite(listingId: String) -> Bool {
        return userFavorites.contains(listingId)
    }
    
    // MARK: - Flag/Report
    func flagListing(listingId: String, reason: String) async throws {
        guard let db = db else { throw ListingError.firebaseNotConfigured }
        guard let currentUser = Auth.auth().currentUser else {
            throw ListingError.notAuthenticated
        }
        
        let report = [
            "listingId": listingId,
            "reason": reason,
            "reportedBy": currentUser.uid,
            "timestamp": Timestamp(date: Date())
        ] as [String: Any]
        
        // Add to reports collection
        try await db.collection("reports").addDocument(data: report)
        
        // Increment flag count on listing
        try await db.collection("listings").document(listingId).updateData([
            "flagCount": FieldValue.increment(Int64(1))
        ])
    }
    
    // MARK: - Helper Methods
    private func uploadImage(_ image: UIImage, for userId: String, index: Int) async throws -> String {
        guard let storage = storage else { throw ListingError.firebaseNotConfigured }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ListingError.imageCompressionFailed
        }
        
        let filename = "\(userId)_\(UUID().uuidString)_\(index).jpg"
        let storageRef = storage.reference().child("listings/\(filename)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        
        return downloadURL.absoluteString
    }
}

// MARK: - Errors
enum ListingError: LocalizedError {
    case notAuthenticated
    case notAuthorized
    case invalidListingId
    case imageCompressionFailed
    case uploadFailed
    case firebaseNotConfigured
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to continue"
        case .notAuthorized:
            return "You are not authorized to perform this action"
        case .invalidListingId:
            return "Invalid listing ID"
        case .imageCompressionFailed:
            return "Failed to process image"
        case .uploadFailed:
            return "Failed to upload image"
        case .firebaseNotConfigured:
            return "Firebase is not configured. Add GoogleService-Info.plist and relaunch."
        }
    }
}

// MARK: - Array Extension
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
