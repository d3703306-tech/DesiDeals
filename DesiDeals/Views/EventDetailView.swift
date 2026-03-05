import SwiftUI

struct EventDetailView: View {
    let event: Event
    @EnvironmentObject var viewModel: ContentViewModel
    @State private var scrollOffset: CGFloat = 0
    
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
                    ParallaxEventHeader(event: event, scrollOffset: scrollOffset)
                    
                    // Content Card
                    VStack(spacing: 0) {
                        // Date & Time
                        dateTimeSection
                            .padding(.horizontal)
                            .padding(.top, 24)
                        
                        // Venue
                        venueSection
                            .padding(.horizontal)
                            .padding(.top, 24)
                        
                        // Description
                        descriptionSection
                            .padding(.horizontal)
                            .padding(.top, 24)
                        
                        // Details Grid
                        detailsGrid
                            .padding(.horizontal)
                            .padding(.top, 24)
                        
                        // Performers
                        if let performers = event.performers, !performers.isEmpty {
                            performersSection
                                .padding(.horizontal)
                                .padding(.top, 24)
                        }
                        
                        // CTA Buttons
                        ctaSection
                            .padding(.horizontal)
                            .padding(.top, 32)
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
            TranslucentNavigationBar(title: event.title, scrollOffset: scrollOffset) {
                HStack(spacing: 12) {
                    if event.entryFee == nil || event.entryFee == 0 {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("RSVP Now")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(eventTypeColor)
                            .clipShape(Capsule())
                        }
                    } else {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "ticket.fill")
                                Text("Get Tickets")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(eventTypeColor)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - Date & Time Section
    private var dateTimeSection: some View {
        HStack(spacing: 16) {
            // Date Box
            VStack(spacing: 4) {
                Text(event.date, format: .dateTime.month(.abbreviated))
                    .font(.caption.bold())
                    .textCase(.uppercase)
                Text(event.date, format: .dateTime.day())
                    .font(.system(size: 36, weight: .bold, design: .rounded))
            }
            .frame(width: 80, height: 80)
            .background(eventTypeColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            // Time Info
            VStack(alignment: .leading, spacing: 4) {
                Text(ContentViewModel.dateFormatter.string(from: event.date))
                    .font(.headline)
                
                if let endDate = event.endDate {
                    Text("Until \(ContentViewModel.timeFormatter.string(from: endDate))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: event.eventType.icon)
                        .font(.caption)
                    Text(event.eventType.rawValue)
                        .font(.caption)
                }
                .foregroundColor(eventTypeColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(eventTypeColor.opacity(0.1))
                .clipShape(Capsule())
            }
            
            Spacer()
        }
    }
    
    // MARK: - Venue Section
    private var venueSection: some View {
        Group {
            if let vendor = viewModel.getVendor(for: event.restaurantId) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Venue")
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
                                
                                Text(vendor.fullAddress)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                    Text(String(format: "%.1f", vendor.rating))
                                        .font(.caption)
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
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.headline)
            
            Text(event.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Details Grid
    private var detailsGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        
        return LazyVGrid(columns: columns, spacing: 12) {
            // Entry Fee
            EventDetailTile(
                icon: "ticket.fill",
                title: "Entry",
                value: event.entryFee != nil && event.entryFee! > 0
                    ? String(format: "$%.0f", event.entryFee!)
                    : "FREE",
                color: event.entryFee != nil && event.entryFee! > 0 ? .primary : .green
            )
            
            // Age
            EventDetailTile(
                icon: "person.fill",
                title: "Age",
                value: event.ageRestriction.rawValue,
                color: .blue
            )
            
            // Dress Code
            if let dressCode = event.dressCode {
                EventDetailTile(
                    icon: "tshirt.fill",
                    title: "Dress Code",
                    value: dressCode.rawValue,
                    color: .purple
                )
            }
            
            // Music Genre
            if let genre = event.musicGenre {
                EventDetailTile(
                    icon: "music.note",
                    title: "Music",
                    value: genre.rawValue,
                    color: .pink
                )
            }
        }
    }
    
    // MARK: - Performers Section
    private var performersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performers")
                .font(.headline)
            
            if let performers = event.performers {
                ForEach(performers, id: \.self) { performer in
                    HStack(spacing: 12) {
                        Image(systemName: "mic.fill")
                            .font(.title3)
                            .foregroundColor(.purple)
                            .frame(width: 40, height: 40)
                            .background(Color.purple.opacity(0.1))
                            .clipShape(Circle())
                        
                        Text(performer)
                            .font(.body)
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }
    
    // MARK: - CTA Section
    private var ctaSection: some View {
        VStack(spacing: 12) {
            if let vendor = viewModel.getVendor(for: event.restaurantId) {
                Button(action: {
                    if let url = URL(string: "tel://\(vendor.phone.filter { $0.isNumber })") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Call for Reservations")
                            .font(.subheadline.bold())
                    }
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())
                }
            }
        }
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

// MARK: - Parallax Event Header
struct ParallaxEventHeader: View {
    let event: Event
    let scrollOffset: CGFloat
    let height: CGFloat = 300
    
    var body: some View {
        GeometryReader { geometry in
            let offset = scrollOffset > 0 ? -scrollOffset : 0
            let scale = scrollOffset > 0 ? 1 + (scrollOffset / height) * 0.3 : 1
            
            ZStack(alignment: .bottom) {
                // Background Color
                eventTypeColor.opacity(0.15)
                    .frame(height: height + max(0, scrollOffset))
                
                // Icon
                VStack {
                    Spacer()
                    Image(systemName: event.eventType.icon)
                        .font(.system(size: 100))
                        .foregroundColor(eventTypeColor.opacity(0.3))
                    Spacer()
                }
            }
            .frame(width: geometry.size.width)
            .scaleEffect(scale, anchor: .center)
            .offset(y: offset)
            .clipped()
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .clear,
                        .black.opacity(0.3),
                        .black.opacity(0.5)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                VStack(spacing: 8) {
                    Text(event.eventType.rawValue)
                        .font(.subheadline.bold())
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(eventTypeColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    
                    Text(event.title)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.primary)
                }
                .padding(.bottom, 20)
            )
        }
        .frame(height: height)
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

// MARK: - Event Detail Tile
struct EventDetailTile: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline.bold())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        EventDetailView(event: MockData.events.first!)
            .environmentObject(ContentViewModel())
    }
}
