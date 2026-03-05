import SwiftUI

// MARK: - User Profile View
struct ProfileView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @State private var selectedTab: ProfileTab = .activity
    
    enum ProfileTab: String, CaseIterable {
        case activity = "Activity"
        case redemptions = "My Deals"
        case reviews = "Reviews"
        case badges = "Badges"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if let user = viewModel.currentUser {
                        ProfileHeaderView(user: user)
                        
                        // Stats Row
                        ProfileStatsView(user: user)
                            .padding()
                        
                        // Tier Progress
                        TierProgressView(user: user)
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                        
                        // Tab Selector
                        Picker("Tab", selection: $selectedTab) {
                            ForEach(ProfileTab.allCases, id: \.self) { tab in
                                Text(tab.rawValue).tag(tab)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        // Tab Content
                        switch selectedTab {
                        case .activity:
                            ActivityFeedView()
                        case .redemptions:
                            MyRedemptionsView()
                        case .reviews:
                            MyReviewsView()
                        case .badges:
                            BadgesView(user: user)
                        }
                    } else {
                        SignInPromptView()
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { /* TODO: Implement settings navigation */ }) {
                        Image(systemName: "gear")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
    }
}

// MARK: - Profile Header
struct ProfileHeaderView: View {
    let user: UserProfile
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .red.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                if let avatar = user.avatarImage {
                    Image(avatar)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Text(String(user.name.prefix(1)))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.orange)
                }
                
                // Tier Badge
                Circle()
                    .fill(tierColor)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "crown.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    )
                    .offset(x: 40, y: 40)
            }
            
            // Name & Tier
            VStack(spacing: 4) {
                Text(user.name)
                    .font(.title2.bold())
                
                HStack(spacing: 6) {
                    Text(user.tier.rawValue)
                        .font(.subheadline.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(tierColor.opacity(0.2))
                        .foregroundColor(tierColor)
                        .cornerRadius(12)
                    
                    Text("\(user.points) pts")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Bio
            if let bio = user.bio {
                Text(bio)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Edit Profile Button
            Button(action: { /* TODO: Implement edit profile */ }) {
                Text("Edit Profile")
                    .font(.subheadline.bold())
                    .foregroundColor(.orange)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.orange, lineWidth: 1.5)
                    )
            }
        }
        .padding()
    }
    
    private var tierColor: Color {
        switch user.tier {
        case .bronze: return .brown
        case .silver: return .gray
        case .gold: return .yellow
        case .platinum: return .cyan
        case .diamond: return .blue
        }
    }
}

// MARK: - Profile Stats
struct ProfileStatsView: View {
    let user: UserProfile
    
    var body: some View {
        HStack(spacing: 0) {
            StatItem(value: user.redemptionCount, label: "Deals Used", icon: "ticket.fill")
            Divider()
            StatItem(value: user.reviewCount, label: "Reviews", icon: "star.fill")
            Divider()
            StatItem(value: user.helpfulVotesReceived, label: "Helpful", icon: "hand.thumbsup.fill")
            Divider()
            StatItem(value: user.streakDays, label: "Day Streak", icon: "flame.fill")
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct StatItem: View {
    let value: Int
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.orange)
            
            Text("\(value)")
                .font(.title3.bold())
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Tier Progress
struct TierProgressView: View {
    let user: UserProfile
    
    var nextTier: UserTier? {
        let allTiers = UserTier.allCases
        guard let currentIndex = allTiers.firstIndex(of: user.tier),
              currentIndex < allTiers.count - 1 else { return nil }
        return allTiers[currentIndex + 1]
    }
    
    var progress: Double {
        guard let next = nextTier else { return 1.0 }
        let currentMin = user.tier.minPoints
        let nextMin = next.minPoints
        let range = Double(nextMin - currentMin)
        let earned = Double(user.points - currentMin)
        return earned / range
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(user.points) points")
                    .font(.subheadline.bold())
                
                Spacer()
                
                if let next = nextTier {
                    Text("\(next.minPoints - user.points) to \(next.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
            
            if let next = nextTier {
                Text(next.benefits.first ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Activity Feed
struct ActivityFeedView: View {
    var body: some View {
        VStack(spacing: 16) {
            ActivityItem(
                icon: "ticket.fill",
                color: .green,
                title: "Redeemed 'BOGO Thali' at Mehfil",
                time: "2 hours ago",
                points: "+50 pts"
            )
            
            ActivityItem(
                icon: "star.fill",
                color: .orange,
                title: "Posted review for Namak Indian Cuisine",
                time: "Yesterday",
                points: "+25 pts"
            )
            
            ActivityItem(
                icon: "hand.thumbsup.fill",
                color: .blue,
                title: "Your review got 5 helpful votes",
                time: "2 days ago",
                points: "+10 pts"
            )
            
            ActivityItem(
                icon: "flame.fill",
                color: .red,
                title: "7-day streak bonus!",
                time: "3 days ago",
                points: "+100 pts"
            )
        }
        .padding()
    }
}

struct ActivityItem: View {
    let icon: String
    let color: Color
    let title: String
    let time: String
    let points: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(color)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .lineLimit(2)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(points)
                .font(.caption.bold())
                .foregroundColor(.green)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - My Redemptions
struct MyRedemptionsView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    
    var activeRedemptions: [Redemption] {
        viewModel.redemptions.filter { $0.status == .active }
    }
    
    var usedRedemptions: [Redemption] {
        viewModel.redemptions.filter { $0.status == .used }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if !activeRedemptions.isEmpty {
                SectionHeader(title: "Active (\(activeRedemptions.count))")
                
                ForEach(activeRedemptions) { redemption in
                    RedemptionCard(redemption: redemption)
                }
            }
            
            if !usedRedemptions.isEmpty {
                SectionHeader(title: "Used")
                
                ForEach(usedRedemptions) { redemption in
                    RedemptionCard(redemption: redemption)
                        .opacity(0.7)
                }
            }
        }
        .padding()
    }
}

struct RedemptionCard: View {
    let redemption: Redemption
    @EnvironmentObject var viewModel: ContentViewModel
    @State private var showingQR = false
    
    var deal: Deal? {
        viewModel.deals.first { $0.id == redemption.dealId }
    }
    
    var vendor: Vendor? {
        viewModel.vendors.first { $0.id == redemption.vendorId }
    }
    
    var body: some View {
        Button(action: { showingQR = true }) {
            HStack(spacing: 16) {
                // QR Code Preview
                VStack {
                    Image(systemName: "qrcode")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text(redemption.code)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 80, height: 80)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(deal?.title ?? "Deal")
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(vendor?.name ?? "Vendor")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        RedemptionStatusBadge(status: redemption.status)
                        
                        Spacer()
                        
                        if redemption.status == .active {
                            Text("Expires \(redemption.expiresAt, style: .date)")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .sheet(isPresented: $showingQR) {
            if let deal = deal, let vendor = vendor {
                QRCodeView(redemption: redemption, deal: deal, vendor: vendor)
            }
        }
    }
}

struct RedemptionStatusBadge: View {
    let status: RedemptionStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor.opacity(0.1))
            .foregroundColor(backgroundColor)
            .cornerRadius(8)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .active: return .green
        case .used: return .gray
        case .expired: return .red
        case .cancelled: return .orange
        case .refunded: return .blue
        }
    }
}

// MARK: - QR Code View
struct QRCodeView: View {
    let redemption: Redemption
    let deal: Deal
    let vendor: Vendor
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Deal Info
                VStack(spacing: 8) {
                    Text(deal.title)
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                    
                    Text(vendor.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // QR Code
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .frame(width: 280, height: 280)
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    
                    VStack(spacing: 16) {
                        Image(systemName: "qrcode")
                            .font(.system(size: 180))
                            .foregroundColor(.black)
                        
                        Text(redemption.code)
                            .font(.system(.title3, design: .monospaced))
                            .fontWeight(.bold)
                    }
                }
                
                // Instructions
                VStack(spacing: 12) {
                    Label("Show this code to the cashier", systemImage: "person.wave.2")
                    Label("Valid until \(redemption.expiresAt, style: .date)", systemImage: "clock")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Spacer()
                
                // Terms
                Text(deal.terms)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Your Deal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - My Reviews
struct MyReviewsView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    
    var myReviews: [Review] {
        guard let userId = viewModel.currentUser?.id else { return [] }
        return viewModel.reviews.filter { $0.author.id == userId }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(myReviews) { review in
                ReviewCard(review: review)
            }
        }
        .padding()
    }
}

// MARK: - Badges View
struct BadgesView: View {
    let user: UserProfile
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
            ForEach(user.badges, id: \.self) { badge in
                BadgeItem(badge: badge)
            }
            
            // Locked badges
            ForEach(lockedBadges, id: \.self) { badge in
                BadgeItem(badge: badge, isLocked: true)
            }
        }
        .padding()
    }
    
    var lockedBadges: [UserBadge] {
        UserBadge.allCases.filter { !user.badges.contains($0) }
    }
}

struct BadgeItem: View {
    let badge: UserBadge
    var isLocked: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isLocked ? Color.gray.opacity(0.1) : Color.orange.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Text(badge.icon)
                    .font(.system(size: 40))
                    .grayscale(isLocked ? 1 : 0)
                    .opacity(isLocked ? 0.5 : 1)
                
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            
            Text(badge.rawValue)
                .font(.caption.bold())
                .multilineTextAlignment(.center)
                .foregroundColor(isLocked ? .secondary : .primary)
            
            if !isLocked {
                Text(badge.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(width: 100)
        .opacity(isLocked ? 0.6 : 1)
    }
}

// MARK: - Sign In Prompt
struct SignInPromptView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange.opacity(0.5))
            
            Text("Sign in to access your profile")
                .font(.headline)
            
            Text("Track your deals, earn points, and unlock badges")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { /* TODO: Implement sign in flow */ }) {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
        }
        .padding()
    }
}

#Preview {
    ProfileView()
        .environmentObject(ContentViewModel())
}
