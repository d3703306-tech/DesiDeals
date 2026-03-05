import SwiftUI

struct EventsView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @State private var showFilters = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header
                        headerView
                        
                        // Search
                        searchBar
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                        
                        // Upcoming Events
                        if !viewModel.upcomingEvents.isEmpty {
                            upcomingSection
                        }
                        
                        // All Events
                        eventsList
                    }
                }
            }
            .navigationTitle("Events 🎉")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showFilters = true }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title3)
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterSheet()
                    .environmentObject(viewModel)
            }
            .navigationDestination(for: Event.self) { event in
                EventDetailView(event: event)
                    .environmentObject(viewModel)
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Parties, DJ Nights & Cultural Events")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.title3)
            
            TextField("Search events, venues...", text: $viewModel.searchText)
                .font(.body)
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Upcoming Section
    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Happening Soon 🎊")
                .font(.title2.bold())
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.upcomingEvents.prefix(3)) { event in
                        NavigationLink(value: event) {
                            FeaturedEventCard(event: event)
                                .environmentObject(viewModel)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Events List
    private var eventsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("All Events")
                    .font(.title2.bold())
                
                Spacer()
                
                Text("\(viewModel.filteredEvents.count) found")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            if viewModel.filteredEvents.isEmpty {
                EmptyStateView(message: "No events found")
                    .padding(.top, 40)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.filteredEvents.sorted(by: { $0.date < $1.date })) { event in
                        NavigationLink(value: event) {
                            ElegantEventCard(event: event)
                                .environmentObject(viewModel)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - Featured Event Card
struct FeaturedEventCard: View {
    let event: Event
    @EnvironmentObject var viewModel: ContentViewModel
    
    var vendor: Vendor? {
        viewModel.getVendor(for: event.restaurantId)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Area
            ZStack(alignment: .bottomLeading) {
                Image(event.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.black.opacity(0.2))
                    )
                
                // Gradient
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: 300, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                // Date Badge
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.eventType.rawValue)
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(eventTypeColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    
                    Text(ContentViewModel.dateFormatter.string(from: event.date))
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .padding(12)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(2)
                
                if let vendor = vendor {
                    Text(vendor.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack {
                    if let fee = event.entryFee, fee > 0 {
                        Text("$")
                            .font(.caption)
                        + Text(String(format: "%.0f", fee))
                            .font(.title3.bold())
                            .foregroundColor(.green)
                        Text("entry")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("FREE Entry")
                            .font(.title3.bold())
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                        .foregroundColor(eventTypeColor)
                }
            }
            .padding(12)
        }
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
        )
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

// MARK: - Elegant Event Card
struct ElegantEventCard: View {
    let event: Event
    @EnvironmentObject var viewModel: ContentViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Date Column
            VStack(spacing: 4) {
                Text(event.date, format: .dateTime.day())
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(event.date, format: .dateTime.month(.abbreviated))
                    .font(.subheadline.bold())
                    .foregroundColor(.white.opacity(0.9))
                    .textCase(.uppercase)
            }
            .frame(width: 70, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(eventTypeColor)
            )
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Event Type Badge
                Text(event.eventType.rawValue)
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(eventTypeColor.opacity(0.15))
                    .foregroundColor(eventTypeColor)
                    .clipShape(Capsule())
                
                // Title
                Text(event.title)
                    .font(.headline)
                    .lineLimit(2)
                
                // Time & Price
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(ContentViewModel.timeFormatter.string(from: event.date))
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Entry Fee
                    if let fee = event.entryFee, fee > 0 {
                        Text("$")
                            .font(.caption)
                        + Text(String(format: "%.0f", fee))
                            .font(.subheadline.bold())
                    } else {
                        Text("FREE")
                            .font(.subheadline.bold())
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 15, x: 0, y: 8)
        )
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
