// MARK: - Add Listing View (Multi-step Form)
import SwiftUI
import PhotosUI

struct AddListingView: View {
    @StateObject private var viewModel = AddListingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Bar
                ProgressView(value: viewModel.progress)
                    .tint(.orange)
                    .padding()
                
                // Step Content
                ScrollView {
                    VStack(spacing: 24) {
                        stepContent
                    }
                    .padding()
                }
                
                // Navigation Buttons
                navigationButtons
                    .padding()
            }
            .navigationTitle(viewModel.currentStep.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .alert("Success!", isPresented: $viewModel.isSuccess) {
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Your listing has been posted successfully.")
            }
        }
        .accentColor(.orange)
    }
    
    // MARK: - Step Content
    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .details:
            DetailsStepView(viewModel: viewModel)
        case .location:
            LocationStepView(viewModel: viewModel)
        case .photos:
            PhotosStepView(viewModel: viewModel)
        case .review:
            ReviewStepView(viewModel: viewModel)
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Back Button
            if viewModel.canGoBack() {
                Button {
                    viewModel.previousStep()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            // Next/Submit Button
            Button {
                if viewModel.currentStep == .review {
                    Task {
                        await viewModel.submitListing()
                    }
                } else {
                    viewModel.nextStep()
                }
            } label: {
                HStack {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(viewModel.currentStep == .review ? "Post Listing" : "Next")
                        if viewModel.currentStep != .review {
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.canProceed ? Color.orange : Color.gray)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!viewModel.canProceed || viewModel.isSubmitting)
        }
    }
}

// MARK: - Step 1: Details
struct DetailsStepView: View {
    @ObservedObject var viewModel: AddListingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title
            VStack(alignment: .leading, spacing: 8) {
                Label("Title", systemImage: "textformat")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                TextField("Enter a catchy title", text: $viewModel.title, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...3)
                
                Text("\(viewModel.title.count)/100 characters")
                    .font(.caption)
                    .foregroundStyle(viewModel.title.count > 100 ? .red : .secondary)
            }
            
            // Description
            VStack(alignment: .leading, spacing: 8) {
                Label("Description", systemImage: "text.alignleft")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                TextEditor(text: $viewModel.description)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Text("\(viewModel.description.count)/500 characters")
                    .font(.caption)
                    .foregroundStyle(viewModel.description.count > 500 ? .red : .secondary)
            }
            
            // Category
            VStack(alignment: .leading, spacing: 12) {
                Label("Category", systemImage: "tag")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(ListingCategory.allCases, id: \.self) { category in
                        CategorySelectionButton(
                            category: category,
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            withAnimation {
                                viewModel.selectedCategory = category
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Category Selection Button
struct CategorySelectionButton: View {
    let category: ListingCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                Text(category.rawValue)
                    .fontWeight(isSelected ? .semibold : .medium)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .padding()
            .background(isSelected ? category.swiftColor.color.opacity(0.2) : Color(.systemGray6))
            .foregroundStyle(isSelected ? category.swiftColor.color : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? category.swiftColor.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Step 2: Location & Price
struct LocationStepView: View {
    @ObservedObject var viewModel: AddListingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Neighborhood
            VStack(alignment: .leading, spacing: 12) {
                Label("Neighborhood", systemImage: "mappin.and.ellipse")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                VStack(spacing: 8) {
                    ForEach(DallasNeighborhood.allCases, id: \.self) { neighborhood in
                        NeighborhoodButton(
                            neighborhood: neighborhood,
                            isSelected: viewModel.selectedNeighborhood == neighborhood
                        ) {
                            withAnimation {
                                viewModel.selectedNeighborhood = neighborhood
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            // Price
            VStack(alignment: .leading, spacing: 12) {
                Label("Price (Optional)", systemImage: "dollarsign.circle")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack {
                    Text("$")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    TextField("Enter price", text: $viewModel.priceString)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
                
                Toggle("Contact for Price", isOn: .init(
                    get: { viewModel.priceString.isEmpty },
                    set: { if $0 { viewModel.priceString = "" } }
                ))
                .tint(.orange)
            }
        }
    }
}

// MARK: - Neighborhood Button
struct NeighborhoodButton: View {
    let neighborhood: DallasNeighborhood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "mappin")
                    .foregroundStyle(isSelected ? .white : .orange)
                Text(neighborhood.rawValue)
                    .fontWeight(isSelected ? .semibold : .medium)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.white)
                }
            }
            .padding()
            .background(isSelected ? Color.orange : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Step 3: Photos & Contact
struct PhotosStepView: View {
    @ObservedObject var viewModel: AddListingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Photos
            VStack(alignment: .leading, spacing: 12) {
                Label("Photos (Max 5)", systemImage: "photo.on.rectangle")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                // Photo Grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    // Add Photo Button
                    if viewModel.selectedImages.count < 5 {
                        PhotosPicker(
                            selection: $viewModel.selectedPhotos,
                            maxSelectionCount: 5 - viewModel.selectedImages.count,
                            matching: .images
                        ) {
                            VStack {
                                Image(systemName: "plus")
                                    .font(.title2)
                                Text("Add Photos")
                                    .font(.caption)
                            }
                            .frame(width: 100, height: 100)
                            .background(Color(.systemGray6))
                            .foregroundStyle(.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .onChange(of: viewModel.selectedPhotos, initial: false) { _, newSelection in
                            Task {
                                await viewModel.processSelectedPhotos()
                            }
                        }
                    }
                    
                    // Selected Photos
                    ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Button {
                                viewModel.removeImage(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .background(Color.red)
                                    .clipShape(Circle())
                            }
                            .offset(x: 8, y: -8)
                        }
                    }
                }
                
                Text("\(viewModel.selectedImages.count)/5 photos")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Contact Info
            VStack(alignment: .leading, spacing: 12) {
                Label("Contact Information (at least one)", systemImage: "person.crop.circle")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                VStack(spacing: 16) {
                    ContactField(
                        icon: "phone.fill",
                        placeholder: "Phone number",
                        text: $viewModel.phone,
                        keyboardType: .phonePad
                    )
                    
                    ContactField(
                        icon: "message.fill",
                        placeholder: "WhatsApp number",
                        text: $viewModel.whatsapp,
                        keyboardType: .phonePad
                    )
                    
                    ContactField(
                        icon: "envelope.fill",
                        placeholder: "Email address",
                        text: $viewModel.email,
                        keyboardType: .emailAddress
                    )
                }
            }
        }
    }
}

// MARK: - Contact Field
struct ContactField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.orange)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Step 4: Review
struct ReviewStepView: View {
    @ObservedObject var viewModel: AddListingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Review your listing before posting")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            // Preview Card
            VStack(alignment: .leading, spacing: 12) {
                // Photos Preview
                if !viewModel.selectedImages.isEmpty {
                    TabView {
                        ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { _, image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Category Badge
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.selectedCategory.icon)
                            .font(.caption2)
                        Text(viewModel.selectedCategory.rawValue)
                            .font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(viewModel.selectedCategory.swiftColor.color.opacity(0.15))
                    .foregroundStyle(viewModel.selectedCategory.swiftColor.color)
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    if let price = viewModel.price {
                        Text(formatPrice(price))
                            .font(.headline)
                            .foregroundStyle(.orange)
                    } else {
                        Text("Contact for Price")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Title
                Text(viewModel.title)
                    .font(.headline)
                
                // Description
                Text(viewModel.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                
                // Location
                HStack {
                    Image(systemName: "mappin.fill")
                        .foregroundStyle(.orange)
                    Text(viewModel.selectedNeighborhood.rawValue)
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
                
                // Contact Preview
                VStack(alignment: .leading, spacing: 4) {
                    Text("Contact Info:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if !viewModel.phone.isEmpty {
                        Label(viewModel.phone, systemImage: "phone")
                            .font(.caption)
                    }
                    if !viewModel.whatsapp.isEmpty {
                        Label(viewModel.whatsapp, systemImage: "message")
                            .font(.caption)
                    }
                    if !viewModel.email.isEmpty {
                        Label(viewModel.email, systemImage: "envelope")
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "\(Int(price))"
    }
}

#Preview {
    AddListingView()
}
