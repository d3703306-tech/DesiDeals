// MARK: - Listing Detail View
import SwiftUI
import MapKit

struct ListingDetailView: View {
    let listing: Listing
    @StateObject private var viewModel = DesiHubViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showFlagDialog = false
    @State private var flagReason = ""
    @State private var showContactOptions = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Image Carousel
                imageSection
                
                // Content
                VStack(alignment: .leading, spacing: 20) {
                    // Category & Price
                    categoryAndPriceSection
                    
                    // Title & Description
                    titleAndDescriptionSection
                    
                    // Location
                    locationSection
                    
                    // Author Info
                    authorSection
                    
                    // Contact Button
                    contactButton
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        viewModel.toggleFavorite(for: listing.id ?? "")
                    } label: {
                        Label(
                            viewModel.isFavorite(listing.id ?? "") ? "Remove from Favorites" : "Add to Favorites",
                            systemImage: viewModel.isFavorite(listing.id ?? "") ? "heart.fill" : "heart"
                        )
                    }
                    
                    Button(role: .destructive) {
                        showFlagDialog = true
                    } label: {
                        Label("Report Listing", systemImage: "flag")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                }
            }
        }
        .confirmationDialog("Contact Seller", isPresented: $showContactOptions, titleVisibility: .visible) {
            if let phone = listing.contactInfo.phone, !phone.isEmpty {
                Button("Call \(phone)") {
                    if let url = URL(string: "tel:\(phone)") {
                        UIApplication.shared.open(url)
                    }
                }
            }
            
            if let whatsapp = listing.contactInfo.whatsapp, !whatsapp.isEmpty {
                Button("WhatsApp \(whatsapp)") {
                    let formatted = whatsapp.replacingOccurrences(of: "+", with: "").replacingOccurrences(of: " ", with: "")
                    if let url = URL(string: "https://wa.me/\(formatted)") {
                        UIApplication.shared.open(url)
                    }
                }
            }
            
            if let email = listing.contactInfo.email, !email.isEmpty {
                Button("Email \(email)") {
                    if let url = URL(string: "mailto:\(email)") {
                        UIApplication.shared.open(url)
                    }
                }
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .alert("Report Listing", isPresented: $showFlagDialog) {
            TextField("Reason for reporting...", text: $flagReason)
            Button("Cancel", role: .cancel) {
                flagReason = ""
            }
            Button("Report", role: .destructive) {
                if !flagReason.isEmpty {
                    viewModel.flagListing(listing, reason: flagReason)
                    flagReason = ""
                }
            }
        } message: {
            Text("Please tell us why you're reporting this listing.")
        }
    }
    
    // MARK: - Image Section
    private var imageSection: some View {
        TabView {
            if listing.imageURLs.isEmpty {
                Image(systemName: "photo")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGray5))
            } else {
                ForEach(listing.imageURLs, id: \.self) { url in
                    AsyncImage(url: URL(string: url)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(.systemGray5))
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: listing.imageURLs.count > 1 ? .always : .never))
        .frame(height: 300)
    }
    
    // MARK: - Category & Price
    private var categoryAndPriceSection: some View {
        HStack {
            // Category Badge
            HStack(spacing: 6) {
                Image(systemName: listing.category.icon)
                Text(listing.category.rawValue)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(listing.category.swiftColor.color.opacity(0.15))
            .foregroundStyle(listing.category.swiftColor.color)
            .clipShape(Capsule())
            
            Spacer()
            
            // Price
            if let price = listing.price {
                Text(formatPrice(price))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
            } else {
                Text("Contact for Price")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Title & Description
    private var titleAndDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(listing.title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(listing.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Location Section
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline)
            
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(listing.neighborhood.rawValue)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Text("Dallas-Fort Worth Metroplex")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            // Mini Map
            Map(position: .constant(.region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: listing.neighborhood.coordinate.latitude,
                    longitude: listing.neighborhood.coordinate.longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )))) {
                Marker(listing.title, coordinate: CLLocationCoordinate2D(
                    latitude: listing.neighborhood.coordinate.latitude,
                    longitude: listing.neighborhood.coordinate.longitude
                ))
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Author Section
    private var authorSection: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundStyle(.orange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Posted by")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(listing.authorName)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            Text(formatDate(listing.timestamp))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Contact Button
    private var contactButton: some View {
        Button {
            showContactOptions = true
        } label: {
            HStack {
                Image(systemName: "message.fill")
                Text("Contact Seller")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.orange)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(listing.contactInfo.phone == nil && 
                  listing.contactInfo.whatsapp == nil && 
                  listing.contactInfo.email == nil)
        .opacity((listing.contactInfo.phone == nil && 
                 listing.contactInfo.whatsapp == nil && 
                 listing.contactInfo.email == nil) ? 0.5 : 1)
    }
    
    // MARK: - Helpers
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "\(Int(price))"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    NavigationStack {
        ListingDetailView(
            listing: Listing(
                id: "1",
                title: "2BHK Apartment for Rent",
                description: "Beautiful apartment near the mosque with all amenities included.",
                category: .housing,
                price: 1200,
                neighborhood: .irving,
                imageURLs: [],
                contactInfo: ContactInfo(phone: "555-0123", whatsapp: "+15550123"),
                authorId: "user1",
                authorName: "Ahmed Khan"
            )
        )
    }
}
