from flask import Flask, request, jsonify
import sys
import os

# Add the car_scarper directory to the Python path
car_scraper_path = os.path.join(os.path.dirname(__file__), 'haraj_cars', 'car_scarper')
scrapers_path = os.path.join(car_scraper_path, 'scrapers')

if car_scraper_path not in sys.path:
    sys.path.insert(0, car_scraper_path)
if scrapers_path not in sys.path:
    sys.path.insert(0, scrapers_path)

# Import the scraper manager
from scraper_manager import scrape_car

app = Flask(__name__)

@app.route('/scrape', methods=['GET'])
def scrape_endpoint():
    """
    Flask endpoint that accepts a URL query parameter and returns scraped car data
    """
    try:
        url = request.args.get('url')
        
        if not url:
            return jsonify({
                'success': False,
                'error': 'URL parameter is required'
            }), 400
        
        # Validate URL format
        if not url.startswith(('http://', 'https://')):
            return jsonify({
                'success': False,
                'error': 'Invalid URL format. URL must start with http:// or https://'
            }), 400
        
        # Check if URL contains car data instead of being a proper URL
        if any(keyword in url.lower() for keyword in ['odometer', 'colour', 'transmission', 'engine', 'body', 'features', 'details', 'build year', 'compliance', 'make:', 'model:', 'vin']):
            return jsonify({
                'success': False,
                'error': 'Invalid URL. Please provide a proper car listing URL, not car data text. Example: https://www.manheim.com.au/passenger-vehicles/7259077/2021-chevrolet-silverado-1500-ltz-premium-4d-dual-cab-utility'
            }), 400
        
        # Call your real scraper function
        car_data = scrape_car(url)
        
        return jsonify({
            'success': True,
            'data': car_data
        })
        
    except Exception as e:
        print(f"❌ Scraping error: {str(e)}")
        return jsonify({
            'success': False,
            'error': f'Scraping failed: {str(e)}'
        }), 500

@app.route('/sites', methods=['GET'])
def get_sites():
    """
    Get list of supported car websites
    """
    from scraper_manager import get_supported_sites
    sites = get_supported_sites()
    site_info = {
        'cars.com': 'Cars.com',
        'manheim.com.au': 'Manheim Australia'
    }
    
    return jsonify({
        'success': True,
        'sites': {site: site_info.get(site, site) for site in sites}
    })

@app.route('/', methods=['GET'])
def home():
    """
    Simple home endpoint with API information
    """
    from scraper_manager import get_supported_sites
    sites = get_supported_sites()
    
    return jsonify({
        'message': 'Car Scraper API',
        'supported_sites': sites,
        'endpoints': {
            '/scrape': 'GET /scrape?url=<car-url> - Scrape car data',
            '/sites': 'GET /sites - List supported websites'
        },
        'example': 'http://127.0.0.1:5000/scrape?url=https://www.cars.com/vehicledetail/example/'
    })

if __name__ == '__main__':
    print("🚀 Starting Car Scraper API...")
    print("📍 API available at: http://127.0.0.1:5000")
    print("🔍 Using REAL scraper from cars_com.py")
    app.run(debug=True, host='127.0.0.1', port=5000)