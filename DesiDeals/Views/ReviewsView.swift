import SwiftUI

// MARK: - Reviews List View
struct ReviewsListView: View {
    let targetId: UUID
    let targetType: ReviewTargetType
    let targetName: String
    @EnvironmentObject var viewModel: ContentViewModel
    @State private var sortOption: ReviewSortOption = .newest
    @State private var showingWriteReview = false
    
    var reviews: [Review] {
        let allReviews = viewModel.getReviews(for: targetId, type: targetType)
        
        switch sortOption {
        case .newest:
            return allReviews.sorted { $0.createdAt > $1.createdAt }
        case .oldest:
            return allReviews.sorted { $0.createdAt < $1.createdAt }
        case .highestRated:
            return allReviews.sorted { $0.rating > $1.rating }
        case .lowestRated:
            return allReviews.sorted { $0.rating < $1.rating }
        case .mostHelpful:
            return allReviews.sorted { $0.helpfulVotes > $1.helpfulVotes }
        case .verifiedOnly:
            return allReviews.filter { $0.isVerifiedPurchase }
        }
    }
    
    var summary: ReviewSummary {
        viewModel.getReviewSummary(for: targetId)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Summary Card
                ReviewSummaryCard(summary: summary)
                    .padding()
                
                // Sort & Filter
                HStack {
                    Text("\(summary.totalReviews) Reviews")
                        .font(.headline)
                    
                    Spacer()
                    
                    Menu {
                        ForEach(ReviewSortOption.allCases, id: \.self) { option in
                            Button(action: { sortOption = option }) {
                                Label(option.rawValue, systemImage: sortOption == option ? "checkmark" : "")
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.arrow.down")
                            Text(sortOption.rawValue)
                                .font(.subheadline)
                        }
                        .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Reviews List
                LazyVStack(spacing: 16) {
                    ForEach(reviews) { review in
                        ReviewCard(review: review)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Reviews")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingWriteReview = true }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.orange)
                }
            }
        }
        .sheet(isPresented: $showingWriteReview) {
            WriteReviewView(targetId: targetId, targetType: targetType, targetName: targetName)
                .environmentObject(viewModel)
        }
    }
}

// MARK: - Review Summary Card
struct ReviewSummaryCard: View {
    let summary: ReviewSummary
    
    var body: some View {
        VStack(spacing: 16) {
            // Overall Rating
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text(String(format: "%.1f", summary.averageRating))
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                    
                    StarRatingView(rating: summary.averageRating, size: 20)
                    
                    Text("\(summary.totalReviews) reviews")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 80)
                
                // Rating Distribution
                VStack(spacing: 4) {
                    ForEach(summary.ratingDistribution, id: \.rating) { item in
                        HStack(spacing: 8) {
                            Text("\(item.rating)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.orange)
                                    .frame(width: geo.size.width * CGFloat(item.percentage / 100))
                            }
                            .frame(height: 6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(2)
                            
                            Text("\(item.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 30, alignment: .trailing)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            // Top Tags
            if !summary.tagCounts.isEmpty {
                Divider()
                
                FlowLayout(spacing: 8) {
                    ForEach(summary.tagCounts.sorted { $0.value > $1.value }.prefix(6), id: \.key) { tag, count in
                        HStack(spacing: 4) {
                            Text(tag.icon)
                            Text(tag.rawValue)
                                .font(.caption)
                            Text("(\(count))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(tag.isPositive ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        .foregroundColor(tag.isPositive ? .green : .red)
                        .cornerRadius(16)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Review Card
struct ReviewCard: View {
    let review: Review
    @State private var isExpanded = false
    @State private var showHelpfulFeedback = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author Header
            HStack(spacing: 12) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    if let avatar = review.author.avatarImage {
                        Image(avatar)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                    } else {
                        Text(String(review.author.name.prefix(1)))
                            .font(.title3.bold())
                            .foregroundColor(.orange)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(review.author.name)
                            .font(.subheadline.bold())
                        
                        if review.author.isTopContributor {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        if review.isVerifiedPurchase {
                            Text("Verified")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.1))
                                .foregroundColor(.green)
                                .cornerRadius(4)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Text("\(review.author.reviewCount) reviews")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(review.createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Rating Badge
                HStack(spacing: 4) {
                    Text(String(format: "%.1f", review.rating))
                        .font(.subheadline.bold())
                    Image(systemName: "star.fill")
                        .font(.caption)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(ratingColor)
                .cornerRadius(8)
            }
            
            // Title
            Text(review.title)
                .font(.headline)
            
            // Content
            Text(review.content)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(isExpanded ? nil : 3)
            
            if review.content.count > 150 {
                Button(action: { isExpanded.toggle() }) {
                    Text(isExpanded ? "Show Less" : "Read More")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
            
            // Photos
            if !review.photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(review.photos, id: \.self) { photo in
                            Image(photo)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            // Visit Details
            HStack(spacing: 16) {
                if let mealType = review.mealType {
                    Label(mealType.rawValue, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let partySize = review.partySize {
                    Label("Party of \(partySize)", systemImage: "person.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Tags
            FlowLayout(spacing: 6) {
                ForEach(review.tags, id: \.self) { tag in
                    Text("\(tag.icon) \(tag.rawValue)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(tag.isPositive ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        .foregroundColor(tag.isPositive ? .green : .red)
                        .cornerRadius(12)
                }
            }
            
            // Vendor Response
            if let response = review.vendorResponse {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Response from the owner")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    
                    Text(response.content)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Text(response.respondedAt, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Actions
            HStack(spacing: 20) {
                Button(action: { showHelpfulFeedback = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.thumbsup")
                        Text("Helpful (\(review.helpfulVotes))")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "flag")
                        Text("Report")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var ratingColor: Color {
        switch review.rating {
        case 4.5...5.0: return .green
        case 3.5..<4.5: return .orange
        case 2.5..<3.5: return .yellow
        default: return .red
        }
    }
}

// MARK: - Star Rating View
struct StarRatingView: View {
    let rating: Double
    var size: CGFloat = 16
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: starImage(for: star))
                    .font(.system(size: size))
                    .foregroundColor(.orange)
            }
        }
    }
    
    private func starImage(for star: Int) -> String {
        let value = rating - Double(star) + 1.0
        if value >= 1.0 {
            return "star.fill"
        } else if value >= 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

// MARK: - Write Review View
struct WriteReviewView: View {
    let targetId: UUID
    let targetType: ReviewTargetType
    let targetName: String
    @EnvironmentObject var viewModel: ContentViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var rating: Double = 0
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedTags: Set<ReviewTag> = []
    @State private var selectedMealType: MealType?
    @State private var partySize: Int?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Overall Rating") {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Text(String(format: "%.1f", rating))
                                .font(.system(size: 48, weight: .bold))
                            
                            HStack(spacing: 8) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= Int(rating) ? "star.fill" : "star")
                                        .font(.system(size: 32))
                                        .foregroundColor(star <= Int(rating) ? .orange : .gray)
                                        .onTapGesture {
                                            rating = Double(star)
                                        }
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 20)
                }
                
                Section("Review Details") {
                    TextField("Headline (e.g., 'Amazing food!')", text: $title)
                    
                    TextEditor(text: $content)
                        .frame(height: 120)
                        .overlay(
                            Group {
                                if content.isEmpty {
                                    Text("Share your experience...")
                                        .foregroundColor(.gray)
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                Section("Visit Details (Optional)") {
                    Picker("Meal Type", selection: $selectedMealType) {
                        Text("Select").tag(nil as MealType?)
                        ForEach(MealType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type as MealType?)
                        }
                    }
                    
                    Picker("Party Size", selection: $partySize) {
                        Text("Select").tag(nil as Int?)
                        ForEach(1...20, id: \.self) { size in
                            Text("\(size) people").tag(size as Int?)
                        }
                    }
                }
                
                Section("What stood out?") {
                    FlowLayout(spacing: 8) {
                        ForEach(ReviewTag.allCases.filter { $0.isPositive }, id: \.self) { tag in
                            Button(action: {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Text(tag.icon)
                                    Text(tag.rawValue)
                                }
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedTags.contains(tag) ? Color.orange : Color.gray.opacity(0.1))
                                .foregroundColor(selectedTags.contains(tag) ? .white : .primary)
                                .cornerRadius(16)
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: submitReview) {
                        HStack {
                            Spacer()
                            Text("Post Review")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .disabled(rating == 0 || title.isEmpty || content.isEmpty)
                }
            }
            .navigationTitle("Write a Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func submitReview() {
        // In real app, would submit to backend
        dismiss()
    }
}

// MARK: - Flow Layout Helper
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

#Preview {
    ReviewsListView(
        targetId: MockData.vendors[0].id,
        targetType: .vendor,
        targetName: MockData.vendors[0].name
    )
    .environmentObject(ContentViewModel())
}
