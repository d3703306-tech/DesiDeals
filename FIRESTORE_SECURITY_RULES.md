# Firestore Security Rules - Dallas Desi Hub

## Complete Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    function validListing() {
      return request.resource.data.keys().hasAll(['title', 'description', 'category', 'timestamp']) &&
        request.resource.data.title is string &&
        request.resource.data.title.size() > 0 &&
        request.resource.data.title.size() < 200 &&
        request.resource.data.description is string &&
        request.resource.data.description.size() > 20 &&
        request.resource.data.category in ['Housing', 'Jobs', 'Services', 'Marketplace', 'Community'];
    }
    
    // Listings Collection
    match /listings/{listingId} {
      // Anyone can read active listings
      allow read: if resource == null || resource.data.status == 'active' || isAuthenticated();
      
      // Authenticated users can create listings
      allow create: if isAuthenticated() 
        && validListing()
        && request.resource.data.authorId == request.auth.uid;
      
      // Only owner or admin can update
      allow update: if isOwner(resource.data.authorId) || isAdmin();
      
      // Only owner or admin can delete
      allow delete: if isOwner(resource.data.authorId) || isAdmin();
    }
    
    // Users Collection
    match /users/{userId} {
      // Users can read any profile
      allow read: if true;
      
      // Users can only create/update their own profile
      allow create, update: if isOwner(userId);
      
      // Only owner or admin can delete
      allow delete: if isOwner(userId) || isAdmin();
    }
    
    // Reports Collection (for flagging)
    match /reports/{reportId} {
      // Only admins can read reports
      allow read: if isAdmin();
      
      // Authenticated users can create reports
      allow create: if isAuthenticated()
        && request.resource.data.reporterId == request.auth.uid
        && request.resource.data.keys().hasAll(['listingId', 'reason', 'timestamp']);
      
      // Only admins can update/delete
      allow update, delete: if isAdmin();
    }
    
    // Favorites subcollection
    match /users/{userId}/favorites/{listingId} {
      allow read: if isOwner(userId);
      allow create, delete: if isOwner(userId);
    }
    
    // Featured Listings (for monetization)
    match /featured/{listingId} {
      allow read: if true;
      allow write: if isAdmin();
    }
  }
}
```

## Indexes Required

```json
{
  "indexes": [
    {
      "collectionGroup": "listings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "listings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "category", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "listings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "neighborhood", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "listings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "authorId", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    }
  ]
}
```

## Setup Instructions

1. Go to Firebase Console > Firestore Database > Rules
2. Replace default rules with the rules above
3. Deploy rules
4. Create indexes in Firebase Console > Firestore Database > Indexes
