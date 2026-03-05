// MARK: - Desi Hub ViewModel
import Foundation
import Combine
import SwiftUI

@MainActor
class DesiHubViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var filteredListings: [Listing] = []
    @Published var selectedCategory: ListingCategory? = nil
    @Published var searchText = ""
    @Published var selectedNeighborhood: DallasNeighborhood? = nil
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let listingService = ListingService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        listingService.startListeningToListings()
        
        // Bind to service listings
        listingService.$listings
            .receive(on: DispatchQueue.main)
            .assign(to: &$listings)
        
        applyFilters()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest3(
            $listings,
            $searchText,
            $selectedNeighborhood
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] listings, searchText, neighborhood in
            self?.applyFilters()
        }
        .store(in: &cancellables)
        
        $selectedCategory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    func applyFilters() {
        var filtered = listings
        
        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            let lowercasedSearch = searchText.lowercased()
            filtered = filtered.filter {
                $0.title.lowercased().contains(lowercasedSearch) ||
                $0.description.lowercased().contains(lowercasedSearch)
            }
        }
        
        // Filter by neighborhood
        if let neighborhood = selectedNeighborhood {
            filtered = filtered.filter { $0.neighborhood == neighborhood }
        }
        
        filteredListings = filtered
    }
    
    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            _ = try await listingService.fetchListings()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func toggleFavorite(for listingId: String) {
        Task {
            do {
                try await listingService.toggleFavorite(listingId: listingId)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    func flagListing(_ listing: Listing, reason: String) {
        guard let listingId = listing.id else { return }
        
        Task {
            do {
                try await listingService.flagListing(listingId: listingId, reason: reason)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    func isFavorite(_ listingId: String) -> Bool {
        return listingService.isFavorite(listingId: listingId)
    }
}
