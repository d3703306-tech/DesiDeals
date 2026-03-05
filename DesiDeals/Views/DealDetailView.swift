import SwiftUI

struct DealDetailView: View {
    let deal: Deal
    @EnvironmentObject var viewModel: ContentViewModel
    @Environment(\.dismiss) var dismiss
    @State private var scrollOffset: CGFloat = 0
    @State private var showingRedemption = false
    @State private var showingShareSheet = false
    
    var vendor: Vendor? {
        viewModel.getVendor(for: deal.vendorId)
    }
    
    var hasRedeemed: Bool {
        guard let userId = viewModel.currentUser?.id else { return false }
        return viewModel.redemptions.contains { $0.dealId == deal.id && $0.userId == userId && $0.status == .active }
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
                    ParallaxDealHeader(deal: deal, scrollOffset: scrollOffset)
                    
                    // Content Card
                    VStack(spacing: 0) {
                        // Deal Info
                        dealInfoSection
                            .padding(.horizontal)
                            .padding(.top, 24)
                        
                        // Vendor Info
                        if let vendor = vendor {
                            vendorSection(vendor: vendor)
                                .padding(.horizontal)
                                .padding(.top, 24)
                        }
                        
                        // Terms
                        termsSection
                            .padding(.horizontal)
                            .padding(.top, 24)
                        
                        // Reviews
                        if let vendor = vendor {
                            reviewsSection(vendor: vendor)
                                .padding(.horizontal)
                                .padding(.top, 24)
                                .padding(.bottom, 100)
                        }
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
            TranslucentNavigationBar(title: deal.title, scrollOffset: scrollOffset) {
                HStack(spacing: 12) {
                    // Save Button
                    Button(action: { /* TODO: Implement save/bookmark deal */ }) {
                        Image(systemName: "bookmark")
                            .font(.title3)
                            .foregroundColor(.orange)
                            .frame(width: 44, height: 44)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    // Redeem Button
                    Button(action: { showingRedemption = true }) {
                        HStack {
                            Image(systemName: hasRedeemed ? "checkmark" : "ticket.fill")
                            Text(hasRedeemed ? "View QR Code" : "Get This Deal")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(hasRedeemed ? Color.green : Color.orange)
                        .clipShape(Capsule())
                    }
                    .disabled(hasRedeemed)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showingRedemption) {
            if let vendor = vendor {
                RedemptionConfirmationView(deal: deal, vendor: vendor)
                    .environmentObject(viewModel)
            }
        }
    }
    
    // MARK: - Deal Info Section
    private var dealInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title and Type
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(deal.dealType.rawValue)
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .clipShape(Capsule())
                    
                    if deal.isVeg {
                        HStack(spacing: 2) {
                            Image(systemName: "leaf.fill")
                                .font(.caption)
                            Text("Veg")
                                .font(.caption)
                        }
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    
                    Spacer()
                }
                
                Text(deal.title)
                    .font(.title2.bold())
            }
            
            // Description
            Text(deal.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(4)
            
            // Price Display
            HStack(spacing: 20) {
                if let discount = deal.discountPercentage {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(discount)%")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.red)
                        Text("OFF")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let original = deal.originalPrice {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("$\(String(format: "%.2f", original))")
                            .font(.title3)
                            .strikethrough()
                            .foregroundColor(.secondary)
                        
                        if let discounted = deal.discountedPrice {
                            Text("$\(String(format: "%.2f", discounted))")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.green)
                            
                            Text("Save $\(String(format: "%.2f", original - discounted))")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
                
                // Stats
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                        Text("\(deal.redemptionCount)")
                            .font(.subheadline)
                    }
                    .foregroundColor(.secondary)
                    
                    if let max = deal.maxRedemptions {
                        Text("Max \(max)/person")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Divider()
            
            // Validity Info
            VStack(alignment: .leading, spacing: 12) {
                Label {
                    Text("Valid: \(deal.validDays.map(\.rawValue).joined(separator: ", "))")
                        .font(.subheadline)
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundColor(.orange)
                }
                
                if let expiry = deal.validUntil {
                    let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: expiry).day ?? 0
                    
                    Label {
                        if daysLeft > 0 {
                            Text("Expires in \(daysLeft) days")
                                .font(.subheadline)
                                .foregroundColor(daysLeft <= 3 ? .red : .primary)
                        } else if daysLeft == 0 {
                            Text("Expires today!")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        } else {
                            Text("Expired \(abs(daysLeft)) days ago")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    } icon: {
                        Image(systemName: daysLeft < 0 ? "clock.arrow.circlepath" : "clock")
                            .foregroundColor(daysLeft <= 3 && daysLeft >= 0 ? .red : daysLeft < 0 ? .gray : .orange)
                    }
                }
            }
        }
    }
    
    // MARK: - Vendor Section
    private func vendorSection(vendor: Vendor) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About the Vendor")
                .font(.headline)
            
            NavigationLink(value: vendor) {
                HStack(spacing: 12) {
                    Image(vendor.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vendor.name)
                            .font(.subheadline.bold())
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text(String(format: "%.1f", vendor.rating))
                                .font(.caption)
                            Text("(\(vendor.reviewCount))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("\(vendor.vendorType.rawValue) • \(vendor.city)")
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
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Terms Section
    private var termsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Terms & Conditions")
                .font(.headline)
            
            Text(deal.terms)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(4)
            
            // Quick Info Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                InfoTile(icon: "checkmark.circle", title: "Instant", subtitle: "Confirmation", color: .green)
                InfoTile(icon: "qrcode", title: "QR Code", subtitle: "Entry", color: .blue)
                InfoTile(icon: "arrow.uturn.backward", title: "Non-", subtitle: "refundable", color: .orange)
                InfoTile(icon: "person.fill", title: "Per Person", subtitle: "Limit", color: .purple)
            }
        }
    }
    
    // MARK: - Reviews Section
    private func reviewsSection(vendor: Vendor) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            let summary = viewModel.getReviewSummary(for: vendor.id)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reviews")
                        .font(.headline)
                    
                    HStack(spacing: 4) {
                        Text(String(format: "%.1f", summary.averageRating))
                            .font(.title2.bold())
                        StarRatingView(rating: summary.averageRating, size: 14)
                        Text("(\(summary.totalReviews))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                NavigationLink("See All") {
                    ReviewsListView(targetId: vendor.id, targetType: .vendor, targetName: vendor.name)
                        .environmentObject(viewModel)
                }
                .font(.subheadline)
                .foregroundColor(.orange)
            }
            
            // Preview of 2 reviews
            ForEach(viewModel.getReviews(for: vendor.id).prefix(2)) { review in
                ReviewCard(review: review)
            }
        }
    }
}

// MARK: - Parallax Deal Header
struct ParallaxDealHeader: View {
    let deal: Deal
    let scrollOffset: CGFloat
    let height: CGFloat = 320
    
    var body: some View {
        GeometryReader { geometry in
            let offset = scrollOffset > 0 ? -scrollOffset : 0
            let scale = scrollOffset > 0 ? 1 + (scrollOffset / height) * 0.3 : 1
            
            Image(deal.imageName)
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
                            .black.opacity(0.4),
                            .black.opacity(0.7)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .frame(height: height)
    }
}

// MARK: - Info Tile
struct InfoTile: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Redemption Confirmation View
struct RedemptionConfirmationView: View {
    let deal: Deal
    let vendor: Vendor
    @EnvironmentObject var viewModel: ContentViewModel
    @Environment(\.dismiss) var dismiss
    @State private var redemption: Redemption?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Success Animation
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                }
                
                VStack(spacing: 8) {
                    Text("Deal Secured!")
                        .font(.title.bold())
                    
                    Text("Show this QR code at \(vendor.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                if let redemption = redemption {
                    VStack(spacing: 16) {
                        // QR Code
                        Image(systemName: "qrcode")
                            .font(.system(size: 150))
                        
                        Text(redemption.code)
                            .font(.system(.title3, design: .monospaced))
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Label("Valid until \(deal.validUntil ?? Date().addingTimeInterval(86400 * 7), style: .date)", systemImage: "calendar")
                    Label("Present at checkout", systemImage: "qrcode")
                    Label("Cannot be combined", systemImage: "exclamationmark.triangle")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding()
            .navigationTitle("Confirmation")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if redemption == nil {
                    redemption = viewModel.redeemDeal(deal)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DealDetailView(deal: MockData.deals[0])
            .environmentObject(ContentViewModel())
    }
}
