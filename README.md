
# SafeLink 🚨

**SafeLink** is a mobile application designed as a crucial tool for child and family safety. In a world where immediate access to help is vital, SafeLink provides a simple, direct way for a child to find the nearest safe haven in an emergency and for parents to have peace of mind.

The app's primary function is to help a child quickly locate and navigate to the nearest police station or safe zone, ensuring they can get help when they need it most.

## ✨ Features

  * **Nearby Police Stations:** Automatically detects and lists police stations close to the user's current location.
  * **Dynamic Routing:** Provides a detailed, real-time route from the user's position to the selected police station.
  * **Intuitive UI:** A clean and easy-to-use interface with a Google Maps view for seamless navigation.
  * **Location Permissions Handling:** Gracefully handles location service status and user permissions.

## ⚙️ Setup and Installation

### Prerequisites

  * **Flutter SDK:** Ensure you have Flutter installed on your machine.
  * **Google Maps API Key:** A valid Google Maps API Key is required. Make sure the **Maps SDK for Android** and **Directions API** are enabled on your Google Cloud Console.

### Steps

1.  **Clone the repository:**
    ```bash
    git clone [Your-GitHub-Repository-URL-Here]
    cd safelink
    ```
2.  **Add your API Key:**
      * Open the file `lib/core/services/api_service.dart`.
      * Replace `"YOUR_GOOGLE_MAPS_API_KEY"` with your actual key.
      * Open `android/app/src/main/AndroidManifest.xml` and add the following meta-data tag inside the `<application>` block, replacing the value with your API key:
        ```xml
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
        ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the app:**
    ```bash
    flutter run
    ```

## 📂 Project Structure

The project follows a standard Flutter file structure with a focus on modularity.

```
safelink/
├── android/
├── lib/
│   ├── core/
│   │   └── services/
│   │       └── api_service.dart     # Handles all API calls
│   └── ui/
│       ├── pages/
│       │   └── safe_places_page.dart  # Main page for safe places and map view
│       └── widgets/
│           └── bottom_nav_bar.dart    # Reusable navigation bar widget
└── ...
```

## 🤝 Contributing

Contributions are welcome\! If you find a bug or have a feature request, please open an issue. If you'd like to contribute code, please fork the repository and create a pull request.

