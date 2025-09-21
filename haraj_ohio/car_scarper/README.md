# Car Scraper Module

This module contains the car scraping functionality for the Haraj Cars app, organized by website.

## Structure

```
car_scarper/
├── scrapers/
│   ├── scraper_manager.py       # Main scraper manager (routes by website)
│   ├── cars_com/                # Cars.com scrapers
│   │   ├── __init__.py
│   │   ├── cars_com.py          # Main scraper (fallback to demo data)
│   │   ├── cars_com_real.py     # Advanced real scraper
│   │   ├── cars_com_requests_html.py # JavaScript-enabled scraper
│   │   └── cars_com_selenium.py # Selenium scraper (bypasses anti-bot)
│   └── autotrader/              # AutoTrader scrapers (template)
│       ├── __init__.py
│       └── autotrader.py        # AutoTrader scraper template
├── requirements.txt             # Dependencies
└── README.md                   # This file
```

## How It Works

The `scraper_manager.py` detects the website from the URL and routes to the appropriate scraper:

1. **cars.com** → `cars_com/` folder scrapers
2. **autotrader.com** → `autotrader/` folder scrapers
3. **Future sites** → Add new folders as needed

Each website folder contains multiple scraping methods (real, selenium, requests-html, etc.)

## Dependencies

- **Required**: `requests`, `beautifulsoup4`, `lxml`
- **Optional**: `requests-html`, `selenium`, `webdriver-manager`

## Usage

```python
from scrapers.cars_com import scrape_car

# Scrape a car
car_data = scrape_car("https://www.cars.com/vehicledetail/...")
print(car_data)
```

## Adding New Scrapers

To add a new car website scraper:

1. **Create a new folder** in `scrapers/` (e.g., `cargurus/`)
2. **Add `__init__.py`** with the main scraper function
3. **Create the main scraper** (e.g., `cargurus.py`)
4. **Add to `scraper_manager.py`**:
   ```python
   elif 'cargurus.com' in domain:
       from cargurus.cargurus import scrape_car as cargurus_scraper
       return cargurus_scraper(url)
   ```
5. **Update `get_supported_sites()`** to include the new site

## Notes

- The scraper gracefully falls back to demo data if real scraping fails
- This is normal behavior when websites block requests
- For production, consider using a proxy service or rotating user agents
