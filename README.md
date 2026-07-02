# Health Mango Scanner - Full-Stack App

A complete Flutter health & nutrition app with **MVC architecture**, **Firebase authentication**, **fruit ripeness AI analysis**, and **product nutrition scanning** with OpenFoodFacts API.

## Features

✅ **Firebase Authentication** - Email/password signup & login
✅ **Health Profile Onboarding** - Collect health conditions, allergies, preferences
✅ **Fruit Scanning** - AI color analysis for ripeness, Brix, sugar, fructose
✅ **Product Barcode Scanning** - OpenFoodFacts nutrition data lookup
✅ **Personalized Recommendations** - Health condition-specific advice (diabetes, hypertension, kidney, heart, celiac)
✅ **Beautiful UI** - Material 3 design with health-focused color scheme
✅ **Offline First** - Core analysis runs on-device
✅ **Firebase Firestore** - Save scan history & health profile

## Architecture: MVC Pattern

```
lib/
├── models/              # Data classes (User, HealthProfile, ProductScan, etc.)
│   └── models.dart
├── views/               # UI Screens
│   ├── onboarding_screen.dart    # Health condition & allergy setup
│   ├── auth_screens.dart         # Login & signup
│   ├── home_screen.dart          # Main app with bottom nav (Fruit + Product)
│   ├── fruit_result_screen.dart  # Fruit analysis results
│   └── product_result_screen.dart# Product nutrition & warnings
├── controllers/         # Business logic & state management
│   └── controllers.dart          # Auth, Health, Fruit, Product controllers
├── services/            # External integrations
│   ├── firebase_auth_service.dart    # Firebase Auth
│   ├── firestore_service.dart        # Firestore CRUD
│   ├── fruit_analysis_service.dart   # Color algorithm (on-device)
│   ├── openfoodfacts_service.dart    # Product API
│   └── health_recommendations_service.dart  # Personalized advice
└── main.dart            # App entry + Firebase init
```

## Setup Instructions

### 1. Prerequisites
- Flutter 3.2+: https://docs.flutter.dev/get-started/install
- Firebase account: https://firebase.google.com
- Android/iOS device or emulator

### 2. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project (name: "health-mango-scanner")
3. **Enable Authentication:**
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"
4. **Create Firestore Database:**
   - Go to Firestore Database
   - Create a database (production mode, any region)
   - Set security rules:
     ```
     rules_version = '3';
     service cloud.firestore {
       match /databases/{database}/documents {
         match /users/{userId} {
           allow read, write: if request.auth.uid == userId;
           match /{document=**} {
             allow read, write: if request.auth.uid == userId;
           }
         }
       }
     }
     ```

### 3. Configure Firebase for Flutter

#### Using FlutterFire CLI (Recommended)
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
This will automatically generate `lib/firebase_options.dart`.

#### Manual Setup
If flutterfire_cli doesn't work:
1. Copy your Firebase project credentials
2. Open `lib/firebase_options.dart`
3. Fill in your Firebase project details:
   ```dart
   static const FirebaseOptions currentPlatform = FirebaseOptions(
     apiKey: 'YOUR_WEB_API_KEY',
     appId: 'YOUR_APP_ID',
     messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
     projectId: 'your-project-id',
     authDomain: 'your-project-id.firebaseapp.com',
     databaseURL: 'https://your-project-id.firebaseio.com',
     storageBucket: 'your-project-id.appspot.com',
   );
   ```

### 4. Android Setup

Edit `android/app/build.gradle`:
```gradle
android {
  compileSdkVersion 34  // or higher
  defaultConfig {
    minSdkVersion 21    // Required for camera plugin
    targetSdkVersion 34
  }
}
```

Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

### 5. iOS Setup

Edit `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Needed to scan fruit and barcode products</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Needed to pick fruit photos from gallery</string>
```

### 6. Run the App

```bash
flutter pub get
flutter run

# Or target a specific device:
flutter run -d <device_id>

# Build for production:
flutter build apk --release    # Android
flutter build ios --release     # iOS
```

## Usage Flow

### First-Time User
1. **Sign Up** - Email & password
2. **Onboarding** - Select health conditions (diabetes, hypertension, etc.), add allergies
3. **Home Screen** - Two tabs: Fruit Scanning + Product Scanning

### Fruit Scanning
1. Tap "Fruits" tab → "Take Photo" or "Choose from Gallery"
2. App analyzes color to estimate:
   - Ripeness score (0-100)
   - Brix (sugar %)
   - Total sugar & fructose content
   - Estimated glycemic index
   - **Recommended portion** (based on glycemic load)
3. Health-specific warnings (e.g., "High sugar - watch portion for diabetes")

### Product Scanning
1. Tap "Products" tab → "Scan Barcode"
2. Enter barcode or search product name
3. OpenFoodFacts API returns:
   - Nutrition facts (calories, protein, carbs, fat, sodium, etc.)
   - Ingredient list
   - Allergen warnings
4. App checks against your health profile:
   - ⚠️ **Hypertension** → High sodium warning
   - ⚠️ **Diabetes** → High sugar warning
   - ⚠️ **Heart Disease** → High saturated fat warning
   - ⚠️ **Kidney Disease** → Potassium/protein warnings
   - ⚠️ **Celiac** → Gluten check
   - ⚠️ **Allergies** → Allergen detection

## Key Controllers

### AuthController
- **Methods:**
  - `signup(email, password, displayName)` → Create account
  - `login(email, password)` → Sign in
  - `logout()` → Sign out
  - `currentUser` → Get logged-in user
  - `authStateChanges` → Stream of auth state

### HealthController
- **Methods:**
  - `loadHealthProfile(userId)` → Fetch from Firestore
  - `saveHealthProfile(profile)` → Save to Firestore
  - `updateConditions(conditions)` → Update health conditions
  - `updateAllergies(allergies)` → Update allergies

### FruitController
- **Methods:**
  - `analyzeFruitImage(bytes, userId, health)` → Run color algorithm
  - **Outputs:** ripeness, Brix, sugar, portion recommendations + saves to Firestore

### ProductController
- **Methods:**
  - `scanBarcode(barcode, userId, health)` → Query OpenFoodFacts API
  - `searchProducts(query)` → Search for products

## Health Recommendation Logic

**Diabetes (Type 2):**
- Target: Carbs <225g/day, Sugar <25g/day, Fiber ≥30g/day
- Fruits: Limit to 1 serving if >12g sugar per 100g
- Products: Warn on high sugar (>10g/100g), high carbs (>30g/100g)

**Hypertension:**
- Target: Sodium <1500mg/day, Potassium ≥3500mg/day
- Fruits: Encourage (high potassium)
- Products: Warn on high sodium (>400mg/100g)

**Heart Disease:**
- Target: Sat fat <13g/day, Trans fat <2g/day, Sodium <2000mg/day
- Fruits: Encourage (low saturated fat)
- Products: Warn on high sat fat (>5g/100g), sodium (>400mg/100g)

**Kidney Disease:**
- Target: Protein <51g/day, Potassium <2000mg/day, Sodium <2000mg/day
- Fruits: Monitor potassium
- Products: Warn on potassium (>200mg/100g), protein (>15g/100g)

**Celiac / Gluten Sensitivity:**
- Target: 0g gluten
- Fruits: All natural fruits are safe
- Products: Scan ingredients for wheat, barley, rye; warn on gluten

## API Integration

### OpenFoodFacts API
- **Endpoint:** `https://world.openfoodfacts.org/api/v3/product/{barcode}`
- **Returns:** Product name, brand, nutrition (per 100g), ingredients, allergens, image
- **No authentication required** (free tier)

### Firestore Structure
```
users/
  {userId}/
    health/
      profile/
        {health profile data}
    scans/
      {scanId}: {ripeness, brix, sugar, etc.}
    products/
      {productId}: {barcode, nutrition, allergens, etc.}
```

## Testing Barcodes
- `5901234123457` - Example product (may not exist)
- Use any real product barcode: UPC (13 digits) or EAN (13 digits)

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Firebase options error | Run `flutterfire configure` or manually edit `firebase_options.dart` |
| Camera permission denied | Grant camera permission in device settings |
| OpenFoodFacts not returning data | Try a different barcode; API is volunteer-run and may be incomplete |
| Firestore rules error | Ensure security rules allow `request.auth.uid == userId` |
| Image not decoding | Try a different photo; ensure image is JPEG/PNG |

## Future Enhancements

- [ ] Real barcode scanning (use `qr_flutter` + device camera)
- [ ] Photo history & trend tracking
- [ ] Meal planning based on daily health targets
- [ ] Export nutrition reports as PDF
- [ ] Cloud-based fruit identification model (TensorFlow Lite)
- [ ] Offline OpenFoodFacts cache
- [ ] Multi-language support
- [ ] Dark mode

## License
MIT

## Support
For issues or questions, create a GitHub issue or contact the development team.
