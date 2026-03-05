import SwiftUI

// MARK: - Empty State View
struct EmptyStateView: View {
    let message: String
    var icon: String = "magnifyingglass"
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.orange.opacity(0.5))
            
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red.opacity(0.5))
            
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: retryAction) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

// MARK: - Filter Sheet
struct FilterSheet: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Sort By") {
                    Picker("Sort", selection: $viewModel.selectedSortOption) {
                        ForEach(DealSortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Deal Type") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(DealType.allCases, id: \.self) { type in
                                FilterChip(
                                    title: type.rawValue,
                                    isSelected: false
                                ) {}
                            }
                        }
                    }
                }
                
                Section("Categories") {
                    ForEach(DealCategory.allCases.prefix(10), id: \.self) { category in
                        Button(action: {}) {
                            HStack {
                                Text(category.icon)
                                Text(category.rawValue)
                                Spacer()
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Section("Dietary Preferences") {
                    Toggle("Vegetarian Only", isOn: $viewModel.showVegOnly)
                    Toggle("Vegan Options", isOn: .constant(false))
                    Toggle("Gluten Free", isOn: .constant(false))
                }
                
                Section("Price Range") {
                    HStack(spacing: 8) {
                        ForEach(PriceRange.allCases, id: \.self) { range in
                            FilterChip(
                                title: range.rawValue,
                                isSelected: false
                            ) {}
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") { dismiss() }
                        .fontWeight(.bold)
                }
            }
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.orange : Color(.secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            
            Spacer()
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
        }
    }
}

// MARK: - Toast View
struct ToastView: View {
    let message: String
    let type: ToastType
    
    enum ToastType {
        case success
        case error
        case info
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.title3)
                .foregroundColor(type.color)
            
            Text(message)
                .font(.subheadline)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}

// MARK: - Banner View
struct BannerView: View {
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: action) {
                Text(actionTitle)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Promo Banner
struct PromoBanner: View {
    let title: String
    let subtitle: String
    let backgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline.bold())
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [backgroundColor, backgroundColor.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

// MARK: - Stats Card
struct StatsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.bold())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.orange)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
            }
            
            Spacer()
        }
    }
}

// MARK: - Rating Badge
struct RatingBadge: View {
    let rating: Double
    var showCount: Bool = false
    var count: Int? = nil
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption)
            
            Text(String(format: "%.1f", rating))
                .font(.subheadline.bold())
            
            if showCount, let count = count {
                Text("(\(count))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(ratingColor)
        .cornerRadius(8)
    }
    
    private var ratingColor: Color {
        switch rating {
        case 4.5...5.0: return .green
        case 3.5..<4.5: return .orange
        case 2.5..<3.5: return .yellow
        default: return .red
        }
    }
}

// MARK: - Countdown Timer View
struct CountdownView: View {
    let targetDate: Date
    @State private var timeRemaining: TimeInterval = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 8) {
            TimeUnitView(value: Int(timeRemaining) / 86400, unit: "DAYS")
            Text(":")
            TimeUnitView(value: (Int(timeRemaining) % 86400) / 3600, unit: "HRS")
            Text(":")
            TimeUnitView(value: (Int(timeRemaining) % 3600) / 60, unit: "MIN")
            Text(":")
            TimeUnitView(value: Int(timeRemaining) % 60, unit: "SEC")
        }
        .onAppear { updateTime() }
        .onReceive(timer) { _ in updateTime() }
    }
    
    private func updateTime() {
        timeRemaining = targetDate.timeIntervalSinceNow
        if timeRemaining < 0 {
            timeRemaining = 0
        }
    }
}

struct TimeUnitView: View {
    let value: Int
    let unit: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%02d", value))
                .font(.system(size: 24, weight: .bold, design: .monospaced))
            
            Text(unit)
                .font(.caption2)
        }
        .frame(width: 50)
        .padding(.vertical, 8)
        .background(Color.red.opacity(0.1))
        .foregroundColor(.red)
        .cornerRadius(8)
    }
}

// MARK: - Price Tag
struct PriceTag: View {
    let original: Double?
    let discounted: Double?
    let discount: Int?
    
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 8) {
            if let discount = discount {
                Text("\(discount)% OFF")
                    .font(.title3.bold())
                    .foregroundColor(.red)
            }
            
            if let discounted = discounted {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("$")
                        .font(.caption)
                    Text(String(format: "%.0f", discounted))
                        .font(.title2.bold())
                }
                .foregroundColor(.green)
            }
            
            if let original = original {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("$")
                        .font(.caption)
                    Text(String(format: "%.0f", original))
                        .font(.subheadline)
                        .strikethrough()
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Social Share Buttons
struct SocialShareButtons: View {
    let text: String
    let url: URL?
    
    var body: some View {
        HStack(spacing: 20) {
            ShareButton(icon: "message.fill", color: .green, action: {})
            ShareButton(icon: "square.and.arrow.up", color: .blue, action: {})
            ShareButton(icon: "camera.fill", color: .purple, action: {})
            ShareButton(icon: "link", color: .gray, action: {})
        }
    }
}

struct ShareButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.1))
                .clipShape(Circle())
        }
    }
}
