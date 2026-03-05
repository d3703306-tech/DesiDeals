// MARK: - Add Listing ViewModel (Multi-step Form)
import Foundation
import SwiftUI
import PhotosUI

enum AddListingStep: Int, CaseIterable {
    case details = 0
    case location = 1
    case photos = 2
    case review = 3
    
    var title: String {
        switch self {
        case .details: return "Details"
        case .location: return "Location & Price"
        case .photos: return "Photos & Contact"
        case .review: return "Review"
        }
    }
}

@MainActor
class AddListingViewModel: ObservableObject {
    // MARK: - Step Management
    @Published var currentStep: AddListingStep = .details
    
    // MARK: - Step 1: Details
    @Published var title = ""
    @Published var description = ""
    @Published var selectedCategory: ListingCategory = .marketplace
    
    // MARK: - Step 2: Location & Price
    @Published var selectedNeighborhood: DallasNeighborhood = .irving
    @Published var priceString = ""
    var price: Double? {
        Double(priceString)
    }
    
    // MARK: - Step 3: Photos & Contact
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var selectedImages: [UIImage] = []
    @Published var phone = ""
    @Published var whatsapp = ""
    @Published var email = ""
    
    // MARK: - State
    @Published var isSubmitting = false
    @Published var isSuccess = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var uploadProgress: Double = 0
    
    private let listingService = ListingService.shared
    private let maxPhotos = 5
    
    // MARK: - Validation
    var isStep1Valid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        title.count >= 5 &&
        description.count >= 10
    }
    
    var isStep2Valid: Bool {
        // Price is optional, but if provided must be valid
        if priceString.isEmpty { return true }
        return price != nil && price! >= 0
    }
    
    var isStep3Valid: Bool {
        // At least one contact method required
        !selectedImages.isEmpty &&
        selectedImages.count <= maxPhotos &&
        (!phone.isEmpty || !whatsapp.isEmpty || !email.isEmpty)
    }
    
    var canProceed: Bool {
        switch currentStep {
        case .details: return isStep1Valid
        case .location: return isStep2Valid
        case .photos: return isStep3Valid
        case .review: return true
        }
    }
    
    var progress: Double {
        Double(currentStep.rawValue + 1) / Double(AddListingStep.allCases.count)
    }
    
    // MARK: - Navigation
    func nextStep() {
        guard let next = AddListingStep(rawValue: currentStep.rawValue + 1),
              canProceed else { return }
        currentStep = next
    }
    
    func previousStep() {
        guard let previous = AddListingStep(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = previous
    }
    
    func canGoBack() -> Bool {
        currentStep != .details
    }
    
    // MARK: - Photo Processing
    func processSelectedPhotos() async {
        selectedImages = []
        
        for item in selectedPhotos {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImages.append(image)
            }
        }
    }
    
    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
        
        // Also update selectedPhotos if needed
        if index < selectedPhotos.count {
            selectedPhotos.remove(at: index)
        }
    }
    
    // MARK: - Submission
    func submitListing() async {
        guard canProceed && currentStep == .review else { return }
        
        isSubmitting = true
        defer { isSubmitting = false }
        
        let contactInfo = ContactInfo(
            phone: phone.isEmpty ? nil : phone,
            whatsapp: whatsapp.isEmpty ? nil : whatsapp,
            email: email.isEmpty ? nil : email
        )
        
        do {
            _ = try await listingService.createListing(
                title: title,
                description: description,
                category: selectedCategory,
                price: price,
                neighborhood: selectedNeighborhood,
                images: selectedImages,
                contactInfo: contactInfo
            )
            
            isSuccess = true
            reset()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func reset() {
        currentStep = .details
        title = ""
        description = ""
        selectedCategory = .marketplace
        selectedNeighborhood = .irving
        priceString = ""
        selectedPhotos = []
        selectedImages = []
        phone = ""
        whatsapp = ""
        email = ""
        uploadProgress = 0
    }
}
