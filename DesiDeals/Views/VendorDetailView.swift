import SwiftUI

struct VendorDetailView: View {
    let vendor: Vendor
    @EnvironmentObject var viewModel: ContentViewModel
    @State private var selectedTab: Tab = .deals
    @State private var scrollOffset: CGFloat = 0
    @State private var headerHeight: CGFloat = 300
    
    enum Tab: String, CaseIterable {
        case deals = "Deals"
        case menu = "Menu"
        case reviews = "Reviews"
        case about = "About"
    }
    
    var deals: [Deal] {
        viewModel.getDeals(for: vendor.id)
    }
    
    var events: [Event] {
        viewModel.getEvents(for: vendor.id)
    }
    
    var reviews: [Review] {
        viewModel.getReviews(for: vendor.id)
    }
    
    var reviewSummary: ReviewSummary {
        viewModel.getReviewSummary(for: vendor.id)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Scrollable Content
            ScrollView(showsIndicators: false) {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
                }
                .frame(height: 0)
                
                VStack(spacing: 0) {
                    // Parallax Header
                    ParallaxHeader(imageName: vendor.imageName, height: headerHeight, scrollOffset: scrollOffset)
                    
                    // Content Card
                    VStack(spacing: 0) {
                        // Quick Info
                        quickInfoSection
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        // Tab Selector
                        tabSelector
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        // Tab Content
                        tabContent
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .padding(.bottom, 100)
                    }
                    .background(
                        Color(.systemBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .offset(y: -24)
                    )
                    .offset(y: -24)
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            
            // Translucent Navigation Bar
            TranslucentNavigationBar(title: vendor.name, scrollOffset: scrollOffset) {
                HStack(spacing: 12) {
                    Button(action: { callVendor() }) {
                        Image(systemName: "phone.fill")
                            .font(.subheadline.bold())
                            .foregroundColor(.orange)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    Button(action: { getDirections() }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Directions")
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.orange)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - Quick Info Section
    private var quickInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(vendor.name)
                        .font(.title2.bold())
                    
                    HStack(spacing: 6) {
                        Image(systemName: vendor.vendorType.icon)
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text(vendor.vendorType.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if !vendor.cuisine.isEmpty {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(vendor.cuisine.prefix(2).map { $0.icon }.joined(separator: " "))
                                .font(.subheadline)
                        }
                    }
                }
                
                Spacer()
                
                // Rating Badge
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                        Text(String(format: "%.1f", vendor.rating))
                            .font(.title3.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(ratingColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    
                    Text("\(vendor.reviewCount) reviews")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Quick Info Pills
            FlowLayout(spacing: 8) {
                InfoPill(icon: "mappin", text: vendor.city)
                InfoPill(icon: "clock", text: "Open Now")
                InfoPill(icon: "dollarsign.circle", text: vendor.priceRange.rawValue)
                if dealCount > 0 {
                    InfoPill(icon: "tag.fill", text: "\(dealCount) deals", color: .green)
                }
            }
        }
    }
    
    private var dealCount: Int {
        viewModel.getDeals(for: vendor.id).count
    }
    
    private var ratingColor: Color {
        switch vendor.rating {
        case 4.5...5.0: return .green
        case 3.5..<4.5: return .orange
        case 2.5..<3.5: return .yellow
        default: return .red
        }
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    TabButton(
                        title: tab.rawValue,
                        count: countForTab(tab),
                        isSelected: selectedTab == tab
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTab = tab
                        }
                    }
                }
            }
        }
    }
    
    private func countForTab(_ tab: Tab) -> Int? {
        switch tab {
        case .deals: return deals.count
        case .menu: return nil
        case .reviews: return reviews.count
        case .about: return nil
        }
    }
    
    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .deals:
            dealsTab
        case .menu:
            menuTab
        case .reviews:
            reviewsTab
        case .about:
            aboutTab
        }
    }
    
    // MARK: - Deals Tab
    private var dealsTab: some View {
        VStack(spacing: 16) {
            if deals.isEmpty {
                EmptyStateView(message: "No active deals at this vendor")
            } else {
                ForEach(deals) { deal in
                    NavigationLink(value: deal) {
                        CompactDealCard(deal: deal)
                            .environmentObject(viewModel)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            if !events.isEmpty {
                SectionHeader(title: "Upcoming Events")
                    .padding(.top, 8)
                
                ForEach(events) { event in
                    NavigationLink(value: event) {
                        CompactEventCard(event: event)
                            .environmentObject(viewModel)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Menu Tab
    private var menuTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular Items")
                .font(.headline)
            
            ForEach(vendor.specialties, id: \.self) { item in
                HStack {
                    Text(item)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
    
    // MARK: - Reviews Tab
    private var reviewsTab: some View {
        VStack(spacing: 16) {
            // Summary Card
            ReviewSummaryCard(summary: reviewSummary)
            
            // Write Review Button
            NavigationLink {
                WriteReviewView(targetId: vendor.id, targetType: .vendor, targetName: vendor.name)
                    .environmentObject(viewModel)
            } label: {
                HStack {
                    Image(systemName: "square.and.pencil")
                    Text("Write a Review")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(.orange)
                .padding()
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            
            // Reviews List
            ForEach(reviews.prefix(3)) { review in
                ReviewCard(review: review)
            }
            
            if reviews.count > 3 {
                NavigationLink("See All \(reviews.count) Reviews") {
                    ReviewsListView(targetId: vendor.id, targetType: .vendor, targetName: vendor.name)
                        .environmentObject(viewModel)
                }
                .font(.subheadline)
                .foregroundColor(.orange)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    // MARK: - About Tab
    private var aboutTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("About")
                    .font(.headline)
                
                Text(vendor.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
            
            // Amenities
            if !vendor.amenities.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Amenities")
                        .font(.headline)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(vendor.amenities, id: \.self) { amenity in
                            AmenityTag(amenity: amenity)
                        }
                    }
                }
            }
            
            // Cuisine Types
            if !vendor.cuisine.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cuisine")
                        .font(.headline)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(vendor.cuisine, id: \.self) { cuisine in
                            CuisineTag(cuisine: cuisine)
                        }
                    }
                }
            }
            
            // Contact Info
            VStack(alignment: .leading, spacing: 12) {
                Text("Contact")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 12) {
                    ContactRow(icon: "mappin", text: vendor.fullAddress)
                    ContactRow(icon: "phone", text: vendor.phone)
                    ContactRow(icon: "clock", text: vendor.hours)
                }
            }
            
            // Member Since
            Text("Member since \(vendor.joinedDate, style: .date)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Actions
    private func callVendor() {
        guard let url = URL(string: "tel://\(vendor.phone.filter { $0.isNumber })") else { return }
        UIApplication.shared.open(url)
    }
    
    private func getDirections() {
        let coordinate = vendor.coordinates.clLocation
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = vendor.name
        mapItem.openInMaps()
    }
}

// MARK: - Parallax Header
struct ParallaxHeader: View {
    let imageName: String
    let height: CGFloat
    let scrollOffset: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let offset = scrollOffset > 0 ? -scrollOffset : 0
            let scale = scrollOffset > 0 ? 1 + (scrollOffset / height) * 0.3 : 1
            
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: height + max(0, scrollOffset))
                .scaleEffect(scale, anchor: .center)
                .offset(y: offset)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [
                            .clear,
                            .clear,
                            .black.opacity(0.3),
                            .black.opacity(0.6)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .frame(height: height)
    }
}

// MARK: - Translucent Navigation Bar
struct TranslucentNavigationBar<Content: View>: View {
    let title: String
    let scrollOffset: CGFloat
    let content: Content
    
    @Environment(\.dismiss) private var dismiss
    @State private var titleOpacity: CGFloat = 0
    
    init(title: String, scrollOffset: CGFloat, @ViewBuilder content: () -> Content) {
        self.title = title
        self.scrollOffset = scrollOffset
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.bold())
                        .foregroundColor(titleOpacity > 0.5 ? .primary : .white)
                        .frame(width: 40, height: 40)
                        .background(titleOpacity > 0.5 ? Color(.secondarySystemBackground) : Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                    .opacity(titleOpacity)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "heart")
                        .font(.title3)
                        .foregroundColor(titleOpacity > 0.5 ? .primary : .white)
                        .frame(width: 40, height: 40)
                        .background(titleOpacity > 0.5 ? Color(.secondarySystemBackground) : Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 60)
            .padding(.bottom, 12)
            .background(
                Color(.systemBackground)
                    .opacity(titleOpacity)
                    .ignoresSafeArea(edges: .top)
            )
            .onChange(of: scrollOffset, initial: false) { _, newValue in
                withAnimation(.easeInOut(duration: 0.1)) {
                    titleOpacity = min(1, max(0, -newValue / 200))
                }
            }
            
            Spacer()
            
            // Bottom Action Bar
            content
        }
    }
}

// MARK: - Supporting Views
struct InfoPill: View {
    let icon: String
    let text: String
    var color: Color = .secondary
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule())
    }
}

struct TabButton: View {
    let title: String
    let count: Int?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline.bold())
                
                if let count = count {
                    Text("\(count)")
                        .font(.caption.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.3) : Color.gray.opacity(0.2))
                        .foregroundColor(isSelected ? .white : .secondary)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color.orange : Color(.secondarySystemBackground))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CompactDealCard: View {
    let deal: Deal
    @EnvironmentObject var viewModel: ContentViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Image(deal.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(deal.title)
                    .font(.subheadline.bold())
                    .lineLimit(2)
                
                HStack {
                    Text(deal.dealType.rawValue)
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    if let discount = deal.discountPercentage {
                        Text("• \(discount)% OFF")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                if let discounted = deal.discountedPrice {
                    Text("$\(String(format: "%.0f", discounted))")
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct CompactEventCard: View {
    let event: Event
    @EnvironmentObject var viewModel: ContentViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Date Box
            VStack(spacing: 2) {
                Text(event.date, format: .dateTime.month(.abbreviated))
                    .font(.caption2.bold())
                Text(event.date, format: .dateTime.day())
                    .font(.title3.bold())
            }
            .frame(width: 60, height: 60)
            .background(eventTypeColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                
                Text(event.eventType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(ContentViewModel.timeFormatter.string(from: event.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private var eventTypeColor: Color {
        switch event.eventType {
        case .djNight: return .purple
        case .liveMusic: return .pink
        case .bollywoodNight: return .orange
        case .comedyNight: return .yellow
        case .karaoke: return .green
        case .culturalNight: return .red
        case .newYear: return .blue
        case .diwali: return .orange
        case .holi: return .pink
        case .ladiesNight: return .purple
        case .brunch: return .orange
        case .wineTasting: return .red
        }
    }
}

struct AmenityTag: View {
    let amenity: Amenity
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: amenity.icon)
                .font(.caption)
            Text(amenity.rawValue)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .clipShape(Capsule())
    }
}

struct CuisineTag: View {
    let cuisine: CuisineType
    
    var body: some View {
        HStack(spacing: 4) {
            Text(cuisine.icon)
            Text(cuisine.rawValue)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.orange.opacity(0.1))
        .foregroundColor(.orange)
        .clipShape(Capsule())
    }
}

struct ContactRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.orange)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

import MapKit

#Preview {
    NavigationStack {
        VendorDetailView(vendor: MockData.vendors[0])
            .environmentObject(ContentViewModel())
    }
}
