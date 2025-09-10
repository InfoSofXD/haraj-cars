# Car Scraper API

Simple Flask API that works with your Flutter app.

## 🚀 Quick Start

### 1. Install Flask
```bash
pip install Flask
```

### 2. Start the API
```bash
python app.py
```

### 3. Use in Flutter
- Tap the web icon in your Flutter app
- Enter any cars.com URL
- Tap "Scrape Car Data"

## 📡 API Endpoints

- `GET /scrape?url=<cars.com-url>` - Returns car data
- `GET /` - API information

## 📁 Files

- `app.py` - Flask API server
- `haraj_cars/lib/haraj/services/car_scraper_service.dart` - Flutter service
- `haraj_cars/lib/haraj/screens/car_scraper_example.dart` - Flutter UI

That's it! 🎉