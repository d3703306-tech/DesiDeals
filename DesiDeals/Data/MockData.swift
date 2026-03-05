import Foundation

// MARK: - Complete Mock Data
struct MockData {
    
    // MARK: - Current User
    static let currentUser: UserProfile = UserProfile(
        id: UUID(),
        email: "raj.patel@email.com",
        phone: "+1 (469) 555-0123",
        name: "Raj Patel",
        avatarImage: "user_avatar",
        bio: "Foodie exploring DFW's best Indian cuisine 🍛 | Vegetarian | Spice lover 🌶️",
        location: "Plano, TX",
        favoriteAreas: ["Plano", "Frisco", "Dallas"],
        cuisinePreferences: ["North Indian", "South Indian", "Gujarati", "Street Food"],
        dietaryRestrictions: [.vegetarian],
        pricePreference: "$$",
        reviewCount: 24,
        helpfulVotesReceived: 156,
        redemptionCount: 47,
        savedDealsCount: 12,
        favoriteVendorsCount: 8,
        streakDays: 15,
        badges: [.dealHunter, .vegetarian, .helpfulReviewer],
        memberSince: Date().addingTimeInterval(-86400 * 180), // 6 months ago
        tier: .gold,
        points: 2450,
        isEmailVerified: true,
        isPhoneVerified: true,
        notificationsEnabled: true,
        emailNotificationsEnabled: true,
        locationEnabled: true,
        showProfilePublicly: true
    )
    
    // MARK: - Vendors (Restaurants + Grocery + Catering + Sweet Shops)
    static let vendors: [Vendor] = [
        // MARK: RESTAURANTS (existing + new)
        Vendor(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111") ?? UUID(),
            name: "Namak Indian Cuisine",
            description: "Authentic Indian flavors with modern presentation. Known for exceptional service and rich curries.",
            vendorType: .restaurant,
            cuisine: [.northIndian, .fusion],
            address: "2930 Commerce St",
            city: "Dallas",
            phone: "(214) 555-2006",
            imageName: "restaurant_1",
            rating: 4.8,
            reviewCount: 324,
            priceRange: .high,
            coordinates: Coordinate(latitude: 32.78225, longitude: -96.7968542),
            hours: "Mon-Sun: 11AM-10PM",
            specialties: ["Butter Chicken", "Garlic Naan", "Dal Makhani"],
            amenities: [.wifi, .parking, .reservations, .alcohol, .vegetarian],
            isActive: true,
            joinedDate: Date().addingTimeInterval(-86400 * 730)
        ),
        
        Vendor(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222") ?? UUID(),
            name: "O'Desi Aroma",
            description: "Street food vibes with authentic kebabs and quick bites. Perfect for casual dining.",
            vendorType: .restaurant,
            cuisine: [.streetFood, .northIndian],
            address: "6450 MacArthur Blvd",
            city: "Dallas",
            phone: "(972) 555-8986",
            imageName: "restaurant_2",
            rating: 4.4,
            reviewCount: 189,
            priceRange: .low,
            coordinates: Coordinate(latitude: 32.7793691, longitude: -96.8000295),
            hours: "Mon-Sun: 11AM-11PM",
            specialties: ["Seekh Kebab", "Chole Bhature", "Gol Gappe"],
            amenities: [.takeaway, .delivery, .vegetarian],
            isActive: true,
            joinedDate: Date().addingTimeInterval(-86400 * 500)
        ),
        
        Vendor(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333") ?? UUID(),
            name: "Mehfil Indian Cuisine",
            description: "Punjabi specialties and modern Indian dishes. Famous for their lunch buffet.",
            vendorType: .restaurant,
            cuisine: [.punjabi, .northIndian],
            address: "8440 Preston Rd",
            city: "Plano",
            phone: "(972) 555-9393",
            imageName: "restaurant_4",
            rating: 4.4,
            reviewCount: 278,
            priceRange: .medium,
            coordinates: Coordinate(latitude: 33.0137863, longitude: -96.6133298),
            hours: "Mon-Sun: 11AM-10PM",
            specialties: ["Unlimited Thali", "Paneer Tikka", "Lassi"],
            amenities: [.wifi, .parking, .vegetarian, .vegetarian, .halal],
            isActive: true,
            joinedDate: Date().addingTimeInterval(-86400 * 600)
        ),
        
        Vendor(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444444444") ?? UUID(),
            name: "Chennai Cafe",
            description: "Authentic South Indian vegetarian cuisine. Best dosas and idlis in DFW.",
            vendorType: .restaurant,
            cuisine: [.southIndian],
            address: "2400 W Walnut St",
            city: "Plano",
            phone: "(214) 555-0789",
            imageName: "restaurant_5",
            rating: 4.6,
            reviewCount: 412,
            priceRange: .low,
            coordinates: Coordinate(latitude: 33.0465, longitude: -96.7561),
            hours: "Mon-Sun: 8AM-10PM",
            specialties: ["Masala Dosa", "Filter Coffee", "Idli Sambar"],
            amenities: [.wifi, .vegetarian, .vegan, .takeaway],
            isActive: true,
            joinedDate: Date().addingTimeInterval(-86400 * 800)
        ),
        
        Vendor(
            id: UUID(uuidString: "55555555-5555-5555-5555-555555555555") ?? UUID(),
            name: "Rotate - The Indian Lounge",
            description: "Modern Indian lounge with DJ nights and fusion cuisine. Perfect for parties.",
            vendorType: .restaurant,
            cuisine: [.fusion, .northIndian, .streetFood],
            address: "6959 Lebanon Rd",
            city: "Frisco",
            phone: "(469) 555-0321",
            imageName: "restaurant_2",
            rating: 4.4,
            reviewCount: 156,
            priceRange: .high,
            coordinates: Coordinate(latitude: 33.1284, longitude: -96.8242),
            hours: "Tue-Sun: 5PM-2AM | Mon: Closed",
            specialties: ["Chili Chicken", "Cocktails", "Butter Chicken Pizza"],
            amenities: [.alcohol, .liveMusic, .reservations, .privateDining],
            isActive: true,
            joinedDate: Date().addingTimeInterval(-86400 * 400)
        ),
        
        Vendor(
            id: UUID(uuidString: "66666666-6666-6666-6666-666666666666") ?? UUID(),
            name: "Biryani Pot",
            description: "Authentic Hyderabadi biryani specialist. Fresh ingredients, secret spice blends.",
            vendorType: .restaurant,
            cuisine: [.hyderabadi, .biryani],
            address: "5110 Main St",
            city: "Frisco",
            phone: "(214) 555-0654",
            imageName: "restaurant_3",
            rating: 4.2,
            reviewCount: 234,
            priceRange: .medium,
            coordinates: Coordinate(latitude: 33.1513, longitude: -96.8236),
            hours: "Mon-Sun: 11AM-11PM",
            specialties: ["Hyderabadi Biryani", "Haleem", "Keema Samosa"],
            amenities: [.delivery, .takeaway, .halal],
            isActive: true,
            joinedDate: Date().addingTimeInterval(-86400 * 550)
        ),
        
        // MARK: GROCERY STORES (NEW)
        Vendor(
            id: UUID(uuidString: "77777777-7777-7777-7777-777777777777") ?? UUID(),
            name: "Patel Brothers",
            description: "America's largest Indian grocery chain. Fresh produce, spices, and authentic ingredients.",
            vendorType: .groceryStore,
            cuisine: [],
            address: "3910 W Park Blvd",
            city: "Plano",
            phone: "(972) 555-4521",
            imageName: "restaurant_1",
            rating: 4.5,
            reviewCount: 567,
            priceRange: .low,
            coordinates: Coordinate(latitude: 33.0265, longitude: -96.7133),
            hours: "Mon-Sun: 9AM-9PM",
            specialties: ["Fresh Produce", "Whole Spices", "Frozen Parathas", "Indian Snacks"],
            amenities: [.parking, .wheelchairAccessible, .vegetarian, .vegan],
            isActive: true,
            joinedDate: Date().addingTimeInterval(-86400 * 1000)
        ),
        
        Vendor(
            id: UUID(uuidString: "88888888-8888-8888-8888-888888888888") ?? UUID(),
            name: "India Bazaar",
            description: "Family-run grocery with the freshest vegetables and hard-to-find spices.",
            vendorType: .groceryStore,
            cuisine: [],
            address: "1811 N Greenville Ave",
            city: "Richardson",
            phone: "(972) 555-7834",
            imageName: "restaurant_4",
            rating: 4.3,
            reviewCount: 189,
            priceRange: .low,
            coordinates: Coordinate(latitude: 32.9734, longitude: -96.7689),
            hours: "Mon-Sun: 10AM-8PM",
            specialties: ["Fresh Vegetables", "Organic Lentils", "Millet Flours", "Pickles"],
            amenities: [.parking, .delivery, .vegetarian, .vegan],
            isActive: true,
            joinedDate: Date().addingTimeInterval(-86400 * 700)
        ),
        
        // MARK: SWEET SHOPS (NEW)
        Vendor(
            id: UUID(uuidString: "99999999-9999-9999-9999-999999999999") ?? UUID(),
            name: "Taj Sweets & Snacks",
            description: "Authentic Indian mithai, namkeen, and fresh snacks. Made fresh daily.",
            vendorType: .sweetShop,
            cuisine: [],
            address: "2620 W Pioneer Pkwy",
            city: "Irving",
            phone: "(972) 555-9234",
            imageName: "food_1",
            rating: 4.7,
            reviewCount: 298,
            priceRange: .low,
            coordinates: Coordinate(latitude: 32.8576, longitude: -96.9634),
            hours: "Mon-Sun: 9AM-9PM",
            specialties: ["Gulab Jamun", "Kaju Katli", "Samosa", "Jalebi"],
            amenities: [.parking, .takeaway, .vegetarian],
            isActive: true,
            joinedDate: Date().addingTimeInterval(-86400 * 900)
        ),
        
        Vendor(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID(),
            name: "Bengal Sweet House",
            description: "Bengali sweets specialist. Famous for rasgullas and sandesh.",
            vendorType: .sweetShop,
            cuisine: [.bengali],
            address: "101 S Coit Rd",
            city: "Richardson",
            phone: "(972) 555-6543",
            imageName: "food_2",
            rating: 4.6,
            reviewCount: 156,
            priceRange: .low,
            coordinates: Coordinate(latitude: 32.9789, longitude: -96.7698),
            hours: "Mon-Sun: 10AM-8PM",
            specialties: ["Rasgulla", "Sandesh", "Mishti Doi", "Cham Cham"],
            amenities: [.parking, .takeaway, .vegetarian],
            isActive: true,
            joinedDate: Date().addingTimeInterval(-86400 * 650)
        ),
        
        // MARK: CATERING SERVICES (NEW)
        Vendor(
            id: UUID(uuidString: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa") ?? UUID(),
            name: "Royal Catering Dallas",
            description: "Premium Indian catering for weddings, corporate events, and parties. 50-500 guests.",
            vendorType: .cateringService,
            cuisine: [.northIndian, .southIndian, .gujarati],
            address: "1850 N MacArthur Blvd",
            city: "Irving",
            phone: "(214) 555-8765",
            imageName: "food_3",
            rating: 4.8,
            reviewCount: 89,
            priceRange: .luxury,
            coordinates: Coordinate(latitude: 32.8576, longitude: -96.9634),
            hours: "Mon-Sun: 8AM-8PM (By Appointment)",
            specialties: ["Wedding Catering", "Corporate Lunch", "Buffet Setup", "Live Dosa Station"],
            amenities: [.delivery, .halal, .vegetarian, .vegan],
            isActive: true,
            joinedDate: Date().addingTimeInterval(-86400 * 750)
        ),
        
        // MARK: FOOD TRUCK (NEW)
        Vendor(
            id: UUID(uuidString: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb") ?? UUID(),
            name: "Curry on Wheels",
            description: "Authentic Indian street food on wheels. Find us at DFW food truck parks!",
            vendorType: .foodTruck,
            cuisine: [.streetFood, .northIndian],
            address: "Various Locations - Check Instagram",
            city: "Dallas",
            phone: "(469) 555-2345",
            imageName: "event_1",
            rating: 4.5,
            reviewCount: 134,
            priceRange: .low,
            coordinates: Coordinate(latitude: 32.7789, longitude: -96.7969),
            hours: "Wed-Sun: 11AM-8PM",
            specialties: ["Kathi Rolls", "Pav Bhaji", "Vada Pav", "Masala Chai"],
            amenities: [.takeaway, .vegetarian, .vegan],
            isActive: true,
            joinedDate: Date().addingTimeInterval(-86400 * 300)
        ),
        
        // MARK: SPICE MARKET (NEW)
        Vendor(
            id: UUID(uuidString: "cccccccc-cccc-cccc-cccc-cccccccccccc") ?? UUID(),
            name: "Spice Route Market",
            description: "Premium whole spices, masalas, and rare ingredients. Grind fresh on request.",
            vendorType: .spiceMarket,
            cuisine: [],
            address: "4009 W Plano Pkwy",
            city: "Plano",
            phone: "(972) 555-3456",
            imageName: "restaurant_5",
            rating: 4.9,
            reviewCount: 78,
            priceRange: .medium,
            coordinates: Coordinate(latitude: 33.0265, longitude: -96.7133),
            hours: "Tue-Sun: 10AM-7PM | Mon: Closed",
            specialties: ["Whole Spices", "Garam Masala", "Saffron", "Rare Spices"],
            amenities: [.parking, .wheelchairAccessible, .vegetarian, .vegan],
            isActive: true,
            joinedDate: Date().addingTimeInterval(-86400 * 400)
        )
    ]
    
    // Helper to get vendor by ID
    static func getVendor(id: UUID) -> Vendor? {
        vendors.first { $0.id == id }
    }
}

// MARK: - Deals Data
extension MockData {
    static let deals: [Deal] = {
        let calendar = Calendar.current
        let now = Date()
        
        guard let namak = vendors.first(where: { $0.name == "Namak Indian Cuisine" }),
              let rotate = vendors.first(where: { $0.name == "Rotate - The Indian Lounge" }),
              let biryaniPot = vendors.first(where: { $0.name == "Biryani Pot" }),
              let chennai = vendors.first(where: { $0.name == "Chennai Cafe" }),
              let mehfil = vendors.first(where: { $0.name == "Mehfil Indian Cuisine" }),
              let patel = vendors.first(where: { $0.name == "Patel Brothers" }),
              let indiaBazaar = vendors.first(where: { $0.name == "India Bazaar" }),
              let tajSweets = vendors.first(where: { $0.name == "Taj Sweets & Snacks" }),
              let royalCatering = vendors.first(where: { $0.name == "Royal Catering Dallas" }),
              let curryTruck = vendors.first(where: { $0.name == "Curry on Wheels" }),
              let spiceRoute = vendors.first(where: { $0.name == "Spice Route Market" })
        else { return [] }
        
        return [
            // RESTAURANT DEALS
            Deal(
                id: UUID(),
                vendorId: mehfil.id,
                title: "Buy 2 Get 1 FREE Thali",
                description: "Weekday special! Buy 2 unlimited thalis and get 1 absolutely free. Homestyle Punjabi flavors with 20+ items.",
                dealType: .bogo,
                discountPercentage: 33,
                originalPrice: 45.00,
                discountedPrice: nil,
                validDays: [.weekdays],
                validUntil: now.addingTimeInterval(86400 * 60),
                terms: "Dine-in only. Valid Mon-Fri 11AM-3PM. Cannot combine offers.",
                isVeg: true,
                imageName: "food_1",
                category: .thali,
                subcategory: "Unlimited Punjabi Thali",
                redemptionCount: 342,
                maxRedemptions: 1,
                isLimitedTime: false,
                featuredUntil: now.addingTimeInterval(86400 * 14),
                createdAt: now.addingTimeInterval(-86400 * 30)
            ),
            
            Deal(
                id: UUID(),
                vendorId: biryaniPot.id,
                title: "BOGO Chicken Biryani",
                description: "Buy one Hyderabadi Chicken Biryani, get one free. Authentic dum-cooked biryani with raita and salan.",
                dealType: .bogo,
                discountPercentage: 50,
                originalPrice: 18.99,
                discountedPrice: nil,
                validDays: [.tuesday, .thursday],
                validUntil: now.addingTimeInterval(86400 * 30),
                terms: "Tue & Thu only. Dine-in only. Limited to 2 per table.",
                isVeg: false,
                imageName: "food_2",
                category: .biryani,
                subcategory: "Hyderabadi Chicken Biryani",
                redemptionCount: 567,
                maxRedemptions: 2,
                isLimitedTime: true,
                featuredUntil: now.addingTimeInterval(86400 * 7),
                createdAt: now.addingTimeInterval(-86400 * 15)
            ),
            
            Deal(
                id: UUID(),
                vendorId: chennai.id,
                title: "Weekend Breakfast Special $9.99",
                description: "Any 2 Dosas + 2 Filter Coffees for just $9.99. Choose from Masala, Mysore, Plain, or Onion Dosa.",
                dealType: .fixedPrice,
                discountPercentage: nil,
                originalPrice: 16.00,
                discountedPrice: 9.99,
                validDays: [.saturday, .sunday],
                validUntil: nil,
                terms: "Valid 8AM-12PM on weekends only. Dine-in only.",
                isVeg: true,
                imageName: "food_3",
                category: .dosa,
                subcategory: "South Indian Breakfast Combo",
                redemptionCount: 892,
                maxRedemptions: nil,
                isLimitedTime: false,
                featuredUntil: nil,
                createdAt: now.addingTimeInterval(-86400 * 60)
            ),
            
            Deal(
                id: UUID(),
                vendorId: namak.id,
                title: "Date Night Dinner for 2 - $69",
                description: "3-course romantic dinner for 2 with appetizer, 2 mains, dessert & 2 cocktails. Regular price $95.",
                dealType: .combo,
                discountPercentage: nil,
                originalPrice: 95.00,
                discountedPrice: 69.00,
                validDays: [.wednesday, .thursday, .sunday],
                validUntil: now.addingTimeInterval(86400 * 90),
                terms: "Reservation required. 18% gratuity added. Wine can substitute cocktails.",
                isVeg: false,
                imageName: "restaurant_1",
                category: .thali,
                subcategory: "Date Night Package",
                redemptionCount: 156,
                maxRedemptions: 2,
                isLimitedTime: false,
                featuredUntil: now.addingTimeInterval(86400 * 21),
                createdAt: now.addingTimeInterval(-86400 * 10)
            ),
            
            Deal(
                id: UUID(),
                vendorId: rotate.id,
                title: "Happy Hour - 50% OFF Appetizers",
                description: "Half price on all appetizers: Chili Chicken, Samosas, Tandoori Wings, Fish Amritsari & more!",
                dealType: .happyHour,
                discountPercentage: 50,
                originalPrice: nil,
                discountedPrice: nil,
                validDays: [.wednesday, .thursday, .friday],
                validUntil: nil,
                terms: "4PM-7PM. Must purchase beverage. Dine-in only.",
                isVeg: false,
                imageName: "restaurant_2",
                category: .appetizer,
                subcategory: "All Appetizers",
                redemptionCount: 423,
                maxRedemptions: nil,
                isLimitedTime: false,
                featuredUntil: nil,
                createdAt: now.addingTimeInterval(-86400 * 45)
            ),
            
            // GROCERY DEALS (NEW)
            Deal(
                id: UUID(),
                vendorId: patel.id,
                title: "20% OFF All Spices",
                description: "Huge discount on all whole and ground spices. Stock up on turmeric, cumin, coriander, garam masala & more!",
                dealType: .percentage,
                discountPercentage: 20,
                originalPrice: nil,
                discountedPrice: nil,
                validDays: [.allWeek],
                validUntil: now.addingTimeInterval(86400 * 14),
                terms: "In-store only. Excludes sale items. No minimum purchase.",
                isVeg: true,
                imageName: "restaurant_3",
                category: .spices,
                subcategory: "All Spices",
                redemptionCount: 234,
                maxRedemptions: nil,
                isLimitedTime: true,
                featuredUntil: now.addingTimeInterval(86400 * 7),
                createdAt: now.addingTimeInterval(-86400 * 3)
            ),
            
            Deal(
                id: UUID(),
                vendorId: indiaBazaar.id,
                title: "Buy 5lb Basmati Rice Get 1lb Free",
                description: "Premium aged basmati rice. Long grain, aromatic, perfect for biryani and everyday cooking.",
                dealType: .bogo,
                discountPercentage: 17,
                originalPrice: 12.99,
                discountedPrice: nil,
                validDays: [.allWeek],
                validUntil: now.addingTimeInterval(86400 * 30),
                terms: "While supplies last. In-store only.",
                isVeg: true,
                imageName: "restaurant_4",
                category: .grains,
                subcategory: "Basmati Rice",
                redemptionCount: 567,
                maxRedemptions: 3,
                isLimitedTime: false,
                featuredUntil: nil,
                createdAt: now.addingTimeInterval(-86400 * 20)
            ),
            
            Deal(
                id: UUID(),
                vendorId: patel.id,
                title: "Frozen Foods Flash Sale - 30% OFF",
                description: "All frozen parathas, samosas, pakoras, and ready-to-eat meals. Stock your freezer!",
                dealType: .flashSale,
                discountPercentage: 30,
                originalPrice: nil,
                discountedPrice: nil,
                validDays: [.friday, .saturday, .sunday],
                validUntil: now.addingTimeInterval(86400 * 5),
                terms: "Weekend only. Limited stock.",
                isVeg: true,
                imageName: "food_1",
                category: .frozen,
                subcategory: "All Frozen Items",
                redemptionCount: 189,
                maxRedemptions: nil,
                isLimitedTime: true,
                featuredUntil: now.addingTimeInterval(86400 * 3),
                createdAt: now.addingTimeInterval(-86400 * 1)
            ),
            
            // SWEET SHOP DEALS (NEW)
            Deal(
                id: UUID(),
                vendorId: tajSweets.id,
                title: "Diwali Special - 15% OFF All Sweets",
                description: "Freshly made mithai for your celebrations. Kaju katli, gulab jamun, rasgulla, peda & more.",
                dealType: .percentage,
                discountPercentage: 15,
                originalPrice: nil,
                discountedPrice: nil,
                validDays: [.allWeek],
                validUntil: now.addingTimeInterval(86400 * 20),
                terms: "Pre-orders recommended for large quantities. Fresh made daily.",
                isVeg: true,
                imageName: "food_2",
                category: .sweets,
                subcategory: "All Indian Sweets",
                redemptionCount: 456,
                maxRedemptions: nil,
                isLimitedTime: true,
                featuredUntil: now.addingTimeInterval(86400 * 10),
                createdAt: now.addingTimeInterval(-86400 * 5)
            ),
            
            Deal(
                id: UUID(),
                vendorId: tajSweets.id,
                title: "Samosa Party Pack - $19.99",
                description: "20 assorted samosas (veg + paneer) with chutneys. Perfect for parties and gatherings!",
                dealType: .fixedPrice,
                discountPercentage: nil,
                originalPrice: 28.00,
                discountedPrice: 19.99,
                validDays: [.allWeek],
                validUntil: nil,
                terms: "24-hour advance order required. Pickup only.",
                isVeg: true,
                imageName: "food_3",
                category: .snacks,
                subcategory: "Samosa Party Pack",
                redemptionCount: 123,
                maxRedemptions: 2,
                isLimitedTime: false,
                featuredUntil: nil,
                createdAt: now.addingTimeInterval(-86400 * 40)
            ),
            
            // CATERING DEALS (NEW)
            Deal(
                id: UUID(),
                vendorId: royalCatering.id,
                title: "Wedding Catering - 10% OFF Orders $2000+",
                description: "Full-service wedding catering with setup, service staff, and cleanup. Customizable menu.",
                dealType: .percentage,
                discountPercentage: 10,
                originalPrice: 2500,
                discountedPrice: nil,
                validDays: [.allWeek],
                validUntil: now.addingTimeInterval(86400 * 180),
                terms: "Book by Dec 31. Minimum 100 guests. Valid for 2025 events.",
                isVeg: false,
                imageName: "event_2",
                category: .catering,
                subcategory: "Wedding Catering Package",
                redemptionCount: 23,
                maxRedemptions: 1,
                isLimitedTime: false,
                featuredUntil: now.addingTimeInterval(86400 * 60),
                createdAt: now.addingTimeInterval(-86400 * 25)
            ),
            
            Deal(
                id: UUID(),
                vendorId: royalCatering.id,
                title: "Corporate Lunch Box - $12/person",
                description: "Individual boxed lunches with biryani, curry, naan, raita & dessert. Min 20 people.",
                dealType: .fixedPrice,
                discountPercentage: nil,
                originalPrice: 18.00,
                discountedPrice: 12.00,
                validDays: [.monday, .tuesday, .wednesday, .thursday, .friday],
                validUntil: nil,
                terms: "24-hour notice required. Delivery within 10 miles included.",
                isVeg: false,
                imageName: "event_3",
                category: .catering,
                subcategory: "Corporate Lunch Boxes",
                redemptionCount: 89,
                maxRedemptions: nil,
                isLimitedTime: false,
                featuredUntil: nil,
                createdAt: now.addingTimeInterval(-86400 * 50)
            ),
            
            // FOOD TRUCK DEALS (NEW)
            Deal(
                id: UUID(),
                vendorId: curryTruck.id,
                title: "Kathi Roll Combo - $8.99",
                description: "Any 2 Kathi Rolls + Fries + Drink. Chicken, paneer, or veggie options available.",
                dealType: .combo,
                discountPercentage: nil,
                originalPrice: 13.00,
                discountedPrice: 8.99,
                validDays: [.wednesday, .thursday, .friday, .saturday, .sunday],
                validUntil: nil,
                terms: "Valid at all locations. Check Instagram for daily locations.",
                isVeg: false,
                imageName: "event_1",
                category: .snacks,
                subcategory: "Kathi Roll Combo",
                redemptionCount: 234,
                maxRedemptions: nil,
                isLimitedTime: false,
                featuredUntil: nil,
                createdAt: now.addingTimeInterval(-86400 * 35)
            ),
            
            // SPICE MARKET DEALS (NEW)
            Deal(
                id: UUID(),
                vendorId: spiceRoute.id,
                title: "Fresh Ground Masala - Buy 3 Get 1 Free",
                description: "Hand-ground fresh daily. Garam masala, biryani masala, chaat masala, sambhar masala.",
                dealType: .bogo,
                discountPercentage: 25,
                originalPrice: 8.99,
                discountedPrice: nil,
                validDays: [.allWeek],
                validUntil: now.addingTimeInterval(86400 * 45),
                terms: "Ground fresh while you wait. Bring your own containers for extra discount.",
                isVeg: true,
                imageName: "restaurant_5",
                category: .spices,
                subcategory: "Fresh Ground Masalas",
                redemptionCount: 67,
                maxRedemptions: nil,
                isLimitedTime: false,
                featuredUntil: now.addingTimeInterval(86400 * 14),
                createdAt: now.addingTimeInterval(-86400 * 15)
            ),
            
            // FIRST VISIT DEALS (NEW)
            Deal(
                id: UUID(),
                vendorId: biryaniPot.id,
                title: "First Visit - 25% OFF Your Order",
                description: "Welcome discount for new customers. Experience authentic Hyderabadi biryani!",
                dealType: .firstVisit,
                discountPercentage: 25,
                originalPrice: nil,
                discountedPrice: nil,
                validDays: [.allWeek],
                validUntil: nil,
                terms: "New customers only. One per customer. Must show this deal.",
                isVeg: false,
                imageName: "restaurant_3",
                category: .biryani,
                subcategory: "First Time Customer",
                redemptionCount: 445,
                maxRedemptions: 1,
                isLimitedTime: false,
                featuredUntil: nil,
                createdAt: now.addingTimeInterval(-86400 * 100)
            )
        ]
    }()
}

// MARK: - Reviews Data
extension MockData {
    static let reviews: [Review] = {
        let calendar = Calendar.current
        let now = Date()
        
        guard let namak = vendors.first(where: { $0.name == "Namak Indian Cuisine" }),
              let mehfil = vendors.first(where: { $0.name == "Mehfil Indian Cuisine" }),
              let chennai = vendors.first(where: { $0.name == "Chennai Cafe" }),
              let patel = vendors.first(where: { $0.name == "Patel Brothers" }),
              let tajSweets = vendors.first(where: { $0.name == "Taj Sweets & Snacks" })
        else { return [] }
        
        let author1 = ReviewAuthor(
            id: UUID(),
            name: "Priya Sharma",
            avatarImage: nil,
            reviewCount: 47,
            helpfulVotesReceived: 234,
            memberSince: now.addingTimeInterval(-86400 * 400),
            isTopContributor: true,
            badges: [.foodCritic, .helpfulReviewer, .explorer]
        )
        
        let author2 = ReviewAuthor(
            id: UUID(),
            name: "Ahmed Khan",
            avatarImage: nil,
            reviewCount: 23,
            helpfulVotesReceived: 89,
            memberSince: now.addingTimeInterval(-86400 * 200),
            isTopContributor: false,
            badges: [.dealHunter, .loyalCustomer]
        )
        
        let author3 = ReviewAuthor(
            id: UUID(),
            name: "Jennifer Liu",
            avatarImage: nil,
            reviewCount: 12,
            helpfulVotesReceived: 45,
            memberSince: now.addingTimeInterval(-86400 * 100),
            isTopContributor: false,
            badges: [.firstReview]
        )
        
        let author4 = ReviewAuthor(
            id: UUID(),
            name: "Raj Patel",
            avatarImage: "user_avatar",
            reviewCount: 24,
            helpfulVotesReceived: 156,
            memberSince: now.addingTimeInterval(-86400 * 180),
            isTopContributor: true,
            badges: [.dealHunter, .vegetarian, .helpfulReviewer]
        )
        
        return [
            // Namak Reviews
            Review(
                id: UUID(),
                targetId: namak.id,
                targetType: .vendor,
                author: author1,
                rating: 5.0,
                title: "Best Butter Chicken in Dallas!",
                content: "I've tried butter chicken at so many places in DFW, but Namak's version is truly exceptional. The gravy is rich, creamy, and perfectly spiced. The garlic naan is the perfect accompaniment - crispy and loaded with garlic. Service was attentive and the ambiance is perfect for date night. Will definitely be back!",
                photos: ["restaurant_1", "food_1"],
                visitDate: now.addingTimeInterval(-86400 * 5),
                mealType: .dinner,
                partySize: 2,
                helpfulVotes: 45,
                unhelpfulVotes: 2,
                isVerifiedPurchase: true,
                isVerifiedVisit: true,
                vendorResponse: VendorResponse(
                    content: "Thank you so much Priya! We're thrilled you enjoyed our butter chicken. It's one of our chef's signature dishes. We look forward to welcoming you back soon!",
                    respondedAt: now.addingTimeInterval(-86400 * 4),
                    respondedBy: "Rahul, Manager"
                ),
                tags: [.deliciousFood, .greatService, .romantic, .generousPortions],
                createdAt: now.addingTimeInterval(-86400 * 4),
                updatedAt: nil
            ),
            
            Review(
                id: UUID(),
                targetId: namak.id,
                targetType: .vendor,
                author: author2,
                rating: 4.0,
                title: "Great food, slightly pricey",
                content: "The food quality is excellent - you can taste the freshness in every dish. We ordered the tandoori platter and dal makhani. Both were delicious. My only gripe is the price - it's definitely on the higher end for Indian food in Dallas. But for special occasions, it's worth it.",
                photos: [],
                visitDate: now.addingTimeInterval(-86400 * 15),
                mealType: .dinner,
                partySize: 4,
                helpfulVotes: 28,
                unhelpfulVotes: 3,
                isVerifiedPurchase: true,
                isVerifiedVisit: true,
                vendorResponse: nil,
                tags: [.deliciousFood, .expensive, .authentic],
                createdAt: now.addingTimeInterval(-86400 * 14),
                updatedAt: nil
            ),
            
            // Mehfil Reviews
            Review(
                id: UUID(),
                targetId: mehfil.id,
                targetType: .vendor,
                author: author4,
                rating: 5.0,
                title: "Unlimited Thali is a Steal!",
                content: "As a vegetarian, finding good options is always a challenge. Mehfil's unlimited thali is incredible value for money. You get endless refills of dal, sabzi, rice, roti, and dessert. Everything is homemade style - not overly oily or spicy. The staff is friendly and doesn't rush you even when it's busy. My go-to spot for lunch!",
                photos: ["food_1"],
                visitDate: now.addingTimeInterval(-86400 * 3),
                mealType: .lunch,
                partySize: 1,
                helpfulVotes: 67,
                unhelpfulVotes: 1,
                isVerifiedPurchase: true,
                isVerifiedVisit: true,
                vendorResponse: VendorResponse(
                    content: "Raj, thank you for being such a loyal customer! We're glad our thali reminds you of home-cooked food. That's exactly what we aim for!",
                    respondedAt: now.addingTimeInterval(-86400 * 2),
                    respondedBy: "Simran, Owner"
                ),
                tags: [.goodValue, .vegetarianFriendly, .authentic, .quickService, .generousPortions],
                createdAt: now.addingTimeInterval(-86400 * 2),
                updatedAt: nil
            ),
            
            Review(
                id: UUID(),
                targetId: mehfil.id,
                targetType: .vendor,
                author: author3,
                rating: 4.5,
                title: "Authentic Punjabi flavors",
                content: "First time trying Punjabi food and I loved it! The thali had so many different items to try. The lassi was thick and creamy. Will definitely come back with friends.",
                photos: [],
                visitDate: now.addingTimeInterval(-86400 * 10),
                mealType: .lunch,
                partySize: 2,
                helpfulVotes: 15,
                unhelpfulVotes: 0,
                isVerifiedPurchase: true,
                isVerifiedVisit: false,
                vendorResponse: nil,
                tags: [.authentic, .goodValue, .familyFriendly],
                createdAt: now.addingTimeInterval(-86400 * 9),
                updatedAt: nil
            ),
            
            // Chennai Cafe Reviews
            Review(
                id: UUID(),
                targetId: chennai.id,
                targetType: .vendor,
                author: author1,
                rating: 5.0,
                title: "Dosa Paradise!",
                content: "As a South Indian, I'm very particular about my dosas. Chennai Cafe hits all the right notes - crispy edges, soft center, perfect fermentation flavor. The sambar is flavorful and the chutneys are fresh. Their filter coffee is the real deal - strong and aromatic. This is my Sunday breakfast spot!",
                photos: ["food_2", "food_3"],
                visitDate: now.addingTimeInterval(-86400 * 2),
                mealType: .breakfast,
                partySize: 3,
                helpfulVotes: 89,
                unhelpfulVotes: 2,
                isVerifiedPurchase: true,
                isVerifiedVisit: true,
                vendorResponse: nil,
                tags: [.authentic, .deliciousFood, .vegetarianFriendly, .quickService],
                createdAt: now.addingTimeInterval(-86400 * 1),
                updatedAt: nil
            ),
            
            // Patel Brothers Reviews
            Review(
                id: UUID(),
                targetId: patel.id,
                targetType: .vendor,
                author: author4,
                rating: 4.5,
                title: "One-stop shop for Indian groceries",
                content: "Patel Brothers has everything you need for Indian cooking. The spice selection is unmatched, and they have fresh vegetables that you won't find at regular grocery stores. Prices are reasonable. Gets crowded on weekends, so go early!",
                photos: [],
                visitDate: now.addingTimeInterval(-86400 * 7),
                mealType: nil,
                partySize: nil,
                helpfulVotes: 34,
                unhelpfulVotes: 1,
                isVerifiedPurchase: true,
                isVerifiedVisit: true,
                vendorResponse: nil,
                tags: [.goodValue, .authentic],
                createdAt: now.addingTimeInterval(-86400 * 6),
                updatedAt: nil
            ),
            
            // Taj Sweets Reviews
            Review(
                id: UUID(),
                targetId: tajSweets.id,
                targetType: .vendor,
                author: author2,
                rating: 5.0,
                title: "Best Gulab Jamun in Town!",
                content: "Soft, syrupy, perfectly sweet - these gulab jamuns are addictive! I always pick up a box for family gatherings and they're always a hit. The samosas are also excellent - crispy and flavorful. Highly recommend!",
                photos: ["food_1"],
                visitDate: now.addingTimeInterval(-86400 * 4),
                mealType: nil,
                partySize: nil,
                helpfulVotes: 52,
                unhelpfulVotes: 0,
                isVerifiedPurchase: true,
                isVerifiedVisit: true,
                vendorResponse: VendorResponse(
                    content: "Thank you Ahmed! Our gulab jamuns are made fresh every morning with pure ghee. We're so glad your family enjoys them!",
                    respondedAt: now.addingTimeInterval(-86400 * 3),
                    respondedBy: "Taj Sweets Team"
                ),
                tags: [.deliciousFood, .authentic, .goodValue],
                createdAt: now.addingTimeInterval(-86400 * 3),
                updatedAt: nil
            )
        ]
    }()
}

// MARK: - Events Data
extension MockData {
    static let events: [Event] = {
        let calendar = Calendar.current
        let now = Date()
        
        guard let rotate = vendors.first(where: { $0.name == "Rotate - The Indian Lounge" }),
              let namak = vendors.first(where: { $0.name == "Namak Indian Cuisine" })
        else { return [] }
        
        func dateFrom(days: Int, hours: Int = 20) -> Date {
            var components = DateComponents()
            components.day = days
            components.hour = hours
            return calendar.date(byAdding: components, to: now) ?? now
        }
        
        return [
            Event(
                id: UUID(),
                restaurantId: rotate.id,
                title: "Bollywood DJ Night",
                description: "Dance to hottest Bollywood, Punjabi & EDM tracks! DJ Harsh spinning live. Special cocktails & hookah.",
                eventType: .djNight,
                date: dateFrom(days: 2),
                endDate: dateFrom(days: 2, hours: 2),
                entryFee: 20.00,
                ageRestriction: .twentyOnePlus,
                musicGenre: .bollywood,
                performers: ["DJ Harsh"],
                imageName: "event_1",
                dressCode: .partyWear,
                specialGuests: nil,
                ticketURL: nil
            ),
            
            Event(
                id: UUID(),
                restaurantId: rotate.id,
                title: "Punjabi Night - Live Bhangra",
                description: "Authentic Dhol players & Bhangra dancers. Unlimited drinks package available!",
                eventType: .bollywoodNight,
                date: dateFrom(days: 5),
                endDate: dateFrom(days: 5, hours: 3),
                entryFee: 25.00,
                ageRestriction: .twentyOnePlus,
                musicGenre: .punjabi,
                performers: ["Dhol Kingz", "Bhangra Crew DFW"],
                imageName: "event_2",
                dressCode: .ethnic,
                specialGuests: nil,
                ticketURL: nil
            ),
            
            Event(
                id: UUID(),
                restaurantId: namak.id,
                title: "Live Sitar & Dinner",
                description: "Intimate evening with classical sitar performance. Gourmet Indian cuisine. Perfect for date night.",
                eventType: .liveMusic,
                date: dateFrom(days: 3, hours: 19),
                endDate: dateFrom(days: 3, hours: 22),
                entryFee: 45.00,
                ageRestriction: .allAges,
                musicGenre: .classical,
                performers: ["Pandit Ravi Sharma"],
                imageName: "event_3",
                dressCode: .smartCasual,
                specialGuests: nil,
                ticketURL: nil
            )
        ]
    }()
}

// MARK: - Redemptions Data
extension MockData {
    static let redemptions: [Redemption] = {
        let now = Date()
        let userId = currentUser.id
        
        guard let deal1 = deals.first,
              let deal2 = deals.dropFirst().first,
              let vendor1 = vendors.first
        else { return [] }
        
        return [
            Redemption(
                id: UUID(),
                dealId: deal1.id,
                userId: userId,
                vendorId: deal1.vendorId,
                code: "RED-123456",
                status: .active,
                createdAt: now.addingTimeInterval(-86400),
                expiresAt: deal1.validUntil ?? now.addingTimeInterval(86400 * 7),
                redeemedAt: nil,
                redeemedLocation: nil,
                redeemedByStaffName: nil,
                billAmount: nil,
                savingsAmount: nil,
                reviewPromptedAt: nil,
                reviewCompleted: false
            ),
            
            Redemption(
                id: UUID(),
                dealId: deal2.id,
                userId: userId,
                vendorId: deal2.vendorId,
                code: "RED-789012",
                status: .used,
                createdAt: now.addingTimeInterval(-86400 * 5),
                expiresAt: now.addingTimeInterval(-86400 * 2),
                redeemedAt: now.addingTimeInterval(-86400 * 3),
                redeemedLocation: CLLocationCoordinate2D(latitude: 32.78225, longitude: -96.7968542),
                redeemedByStaffName: "John",
                billAmount: 45.00,
                savingsAmount: 15.00,
                reviewPromptedAt: now.addingTimeInterval(-86400 * 2),
                reviewCompleted: true
            )
        ]
    }()
}

// MARK: - Helper Extensions
import CoreLocation

	extension CLLocationCoordinate2D: @retroactive Codable, @retroactive Hashable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            latitude: try container.decode(Double.self, forKey: .latitude),
            longitude: try container.decode(Double.self, forKey: .longitude)
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

// MARK: - Community Listings Mock Data
extension MockData {
    static let communityListings: [CommunityListing] = [
        // HOUSING
        CommunityListing(
            id: "housing_1",
            title: "2BR Apartment for Rent in Irving",
            description: "Spacious 2 bedroom, 2 bathroom apartment near Las Colinas. Fully renovated kitchen, in-unit washer/dryer, covered parking. Walking distance to Indian grocery stores and restaurants.",
            category: .housing,
            subcategory: "Apartment",
            price: 1850,
            priceType: .fixed,
            neighborhood: .irving,
            city: "Dallas",
            imageURLs: ["listing_housing_1"],
            timestamp: Date().addingTimeInterval(-86400 * 2),
            contactInfo: ContactInfo(phone: "(214) 555-0101", whatsapp: "(214) 555-0101", email: nil, preferredContact: .phone),
            authorId: "user_1",
            authorName: "Rahul Sharma",
            isFeatured: true,
            viewCount: 145,
            status: .active,
            flaggedCount: 0
        ),
        CommunityListing(
            id: "housing_2",
            title: "Room Available - Indian Family Preferred",
            description: "Furnished room in a 4BR house in Frisco. Shared kitchen and living room. Looking for working professional. Vegetarian household. $800/month including utilities.",
            category: .housing,
            subcategory: "Room",
            price: 800,
            priceType: .fixed,
            neighborhood: .frisco,
            city: "Dallas",
            imageURLs: ["listing_housing_2"],
            timestamp: Date().addingTimeInterval(-86400 * 5),
            contactInfo: ContactInfo(phone: "(469) 555-0202", whatsapp: "(469) 555-0202", email: nil, preferredContact: .whatsapp),
            authorId: "user_2",
            authorName: "Priya Patel",
            isFeatured: false,
            viewCount: 89,
            status: .active,
            flaggedCount: 0
        ),
        
        // JOBS
        CommunityListing(
            id: "job_1",
            title: "Software Engineer - React/Node.js",
            description: "Growing tech company in Plano looking for experienced full-stack developer. 3+ years experience required. Competitive salary + benefits. H1B sponsorship available.",
            category: .jobs,
            subcategory: "IT/Tech",
            price: nil,
            priceType: .contact,
            neighborhood: .plano,
            city: "Dallas",
            imageURLs: ["listing_job_1"],
            timestamp: Date().addingTimeInterval(-86400 * 1),
            contactInfo: ContactInfo(phone: nil, whatsapp: nil, email: "careers@techco.com", preferredContact: .email),
            authorId: "user_3",
            authorName: "TechCorp HR",
            isFeatured: true,
            viewCount: 234,
            status: .active,
            flaggedCount: 0
        ),
        CommunityListing(
            id: "job_2",
            title: "Part-time Nanny Needed - Richardson",
            description: "Looking for caring nanny for 2 kids (ages 3 and 5). Mon-Fri 2pm-6pm. Must have own transportation. $20/hour.",
            category: .jobs,
            subcategory: "Childcare",
            price: 20,
            priceType: .fixed,
            neighborhood: .richardson,
            city: "Dallas",
            imageURLs: ["listing_job_2"],
            timestamp: Date().addingTimeInterval(-86400 * 3),
            contactInfo: ContactInfo(phone: "(972) 555-0303", whatsapp: "(972) 555-0303", email: nil, preferredContact: .phone),
            authorId: "user_4",
            authorName: "Anita Gupta",
            isFeatured: false,
            viewCount: 67,
            status: .active,
            flaggedCount: 0
        ),
        
        // SERVICES
        CommunityListing(
            id: "service_1",
            title: "Professional Mehendi Artist - Events & Parties",
            description: "Experienced mehendi artist with 10+ years experience. Available for weddings, festivals, and private events. Bridal packages starting at $150. Home service available.",
            category: .services,
            subcategory: "Beauty",
            price: 150,
            priceType: .negotiable,
            neighborhood: .carrollton,
            city: "Dallas",
            imageURLs: ["listing_service_1"],
            timestamp: Date().addingTimeInterval(-86400 * 7),
            contactInfo: ContactInfo(phone: "(214) 555-0404", whatsapp: "(214) 555-0404", email: nil, preferredContact: .whatsapp),
            authorId: "user_5",
            authorName: "Sana's Mehendi",
            isFeatured: true,
            viewCount: 312,
            status: .active,
            flaggedCount: 0
        ),
        CommunityListing(
            id: "service_2",
            title: "Tax Preparation - CPA Services",
            description: "Certified CPA specializing in individual and small business taxes. 15 years experience. Handle complex returns including foreign income, crypto, and business deductions.",
            category: .services,
            subcategory: "Financial",
            price: nil,
            priceType: .contact,
            neighborhood: .plano,
            city: "Dallas",
            imageURLs: ["listing_service_2"],
            timestamp: Date().addingTimeInterval(-86400 * 10),
            contactInfo: ContactInfo(phone: "(469) 555-0505", whatsapp: nil, email: "cpa@taxpro.com", preferredContact: .email),
            authorId: "user_6",
            authorName: "Rajesh Gupta CPA",
            isFeatured: false,
            viewCount: 178,
            status: .active,
            flaggedCount: 0
        ),
        
        // MARKETPLACE
        CommunityListing(
            id: "market_1",
            title: "Selling: Pressure Cooker (Presto) - Like New",
            description: "6-quart pressure cooker, used only 3 times. Moving sale. Works perfectly. Original box included. Pickup in Allen.",
            category: .marketplace,
            subcategory: "Kitchen",
            price: 45,
            priceType: .negotiable,
            neighborhood: .allen,
            city: "Dallas",
            imageURLs: ["listing_market_1"],
            timestamp: Date().addingTimeInterval(-86400 * 4),
            contactInfo: ContactInfo(phone: "(214) 555-0606", whatsapp: "(214) 555-0606", email: nil, preferredContact: .phone),
            authorId: "user_7",
            authorName: "Vikram Singh",
            isFeatured: false,
            viewCount: 45,
            status: .active,
            flaggedCount: 0
        ),
        CommunityListing(
            id: "market_2",
            title: "Free: Moving Boxes & Packing Supplies",
            description: "Recently moved, have about 20 moving boxes in good condition. Also have bubble wrap and packing paper. Free for pickup in Frisco.",
            category: .marketplace,
            subcategory: "Free Items",
            price: 0,
            priceType: .free,
            neighborhood: .frisco,
            city: "Dallas",
            imageURLs: ["listing_market_2"],
            timestamp: Date().addingTimeInterval(-86400 * 1),
            contactInfo: ContactInfo(phone: "(469) 555-0707", whatsapp: nil, email: nil, preferredContact: .phone),
            authorId: "user_8",
            authorName: "Neha Reddy",
            isFeatured: false,
            viewCount: 23,
            status: .active,
            flaggedCount: 0
        ),
        
        // COMMUNITY
        CommunityListing(
            id: "comm_1",
            title: "Car Pool: Plano to DFW Airport",
            description: "Looking to start a carpool for monthly trips to DFW airport. I travel every first Sunday of the month. Share gas costs. Plano/Frisco area preferred.",
            category: .community,
            subcategory: "Carpool",
            price: nil,
            priceType: .contact,
            neighborhood: .plano,
            city: "Dallas",
            imageURLs: ["listing_comm_1"],
            timestamp: Date().addingTimeInterval(-86400 * 6),
            contactInfo: ContactInfo(phone: nil, whatsapp: "(972) 555-0808", email: nil, preferredContact: .whatsapp),
            authorId: "user_9",
            authorName: "Arun Kumar",
            isFeatured: false,
            viewCount: 156,
            status: .active,
            flaggedCount: 0
        )
    ]
}
