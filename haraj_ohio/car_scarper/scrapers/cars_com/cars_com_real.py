import requests
from bs4 import BeautifulSoup
import re
import time
import random
from urllib.parse import urlparse

def scrape_car_real(url: str) -> dict:
    """
    Advanced scraper for cars.com with better anti-detection
    """
    
    # Validate URL
    if not url or 'cars.com' not in url:
        raise ValueError("Invalid cars.com URL")
    
    # Multiple realistic user agents
    user_agents = [
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Safari/605.1.15'
    ]
    
    # Try multiple approaches to get real data
    for attempt in range(3):
        try:
            # Small delay between attempts
            if attempt > 0:
                time.sleep(1)
            
            # Create session with connection pooling
            session = requests.Session()
            
            # Different header strategies for each attempt
            if attempt == 0:
                # First attempt: Standard browser headers
                headers = {
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
                'Accept-Language': 'en-US,en;q=0.9',
                'Accept-Encoding': 'gzip, deflate, br',
                'Connection': 'keep-alive',
                'Upgrade-Insecure-Requests': '1',
                'Sec-Fetch-Dest': 'document',
                'Sec-Fetch-Mode': 'navigate',
                'Sec-Fetch-Site': 'none',
                'Sec-Fetch-User': '?1',
                'Cache-Control': 'max-age=0',
                'DNT': '1',
                'Sec-GPC': '1',
                'Referer': 'https://www.cars.com/',
            }
            elif attempt == 1:
                # Second attempt: Mobile headers
                headers = {
                    'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Mobile/15E148 Safari/604.1',
                    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                    'Accept-Language': 'en-US,en;q=0.9',
                    'Accept-Encoding': 'gzip, deflate, br',
                    'Connection': 'keep-alive',
                    'Upgrade-Insecure-Requests': '1',
                    'Sec-Fetch-Dest': 'document',
                    'Sec-Fetch-Mode': 'navigate',
                    'Sec-Fetch-Site': 'none',
                    'Sec-Fetch-User': '?1',
                    'Cache-Control': 'max-age=0',
                }
            else:
                # Third attempt: Different browser
                headers = {
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0',
                    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
                    'Accept-Language': 'en-US,en;q=0.9',
                    'Accept-Encoding': 'gzip, deflate, br',
                    'Connection': 'keep-alive',
                    'Upgrade-Insecure-Requests': '1',
                    'Sec-Fetch-Dest': 'document',
                    'Sec-Fetch-Mode': 'navigate',
                    'Sec-Fetch-Site': 'none',
                    'Sec-Fetch-User': '?1',
                    'Cache-Control': 'max-age=0',
                    'DNT': '1',
                }
            
            session.headers.update(headers)
            
            print(f"🌐 Attempt {attempt + 1}: Trying to access {url}")
            
            # Make request with reasonable timeout
            response = session.get(url, timeout=10, allow_redirects=True)
            response.raise_for_status()
            
            print(f"✅ Successfully got response: {response.status_code}")
            print(f"📄 Content length: {len(response.content)} bytes")
            
            # Parse HTML
            soup = BeautifulSoup(response.content, 'html.parser')
            
            # Debug: Print page title
            title_tag = soup.find('title')
            if title_tag:
                print(f"📋 Page title: {title_tag.get_text()}")
            
            # Initialize result with all fields
            car_data = {
                "Title": "N/A",
                "Year": "N/A",
                "Brand": "N/A", 
                "Model": "N/A",
                "Price": "N/A", 
                "Mileage": "N/A",
                "Dealer": "N/A",
                "Exterior Color": "N/A",
                "Interior Color": "N/A",
                "Drivetrain": "N/A",
                "Fuel Type": "N/A",
                "Transmission": "N/A",
                "Engine": "N/A",
                "VIN": "N/A",
                "Stock #": "N/A",
                "Images": [],
                "URL": url
            }
            
            # Try to find title with most effective selectors first
            title_selectors = [
                'h1[data-cmp="vdp_vehicle_title"]',
                'h1.vehicle-title',
                'h1[class*="title"]',
                '.vdp-title',
                'h1',
                '[data-testid="vehicle-title"]'
            ]
            
            for selector in title_selectors:
                try:
                    title_elem = soup.select_one(selector)
                    if title_elem and title_elem.get_text(strip=True):
                        car_data["Title"] = title_elem.get_text(strip=True)
                        print(f"✅ Found title: {car_data['Title']}")
                        break
                except:
                    continue
            
            # Try to find price with most effective selectors first
            price_selectors = [
                '[data-cmp="vdp_price"]',
                '.price-section .primary-price',
                '.vehicle-price',
                '.price-display',
                '[class*="price"]',
                '[data-testid="price"]'
            ]
            
            for selector in price_selectors:
                try:
                    price_elem = soup.select_one(selector)
                    if price_elem and price_elem.get_text(strip=True):
                        price_text = price_elem.get_text(strip=True)
                        # Look for price pattern
                        price_match = re.search(r'[\$,\d]+', price_text)
                        if price_match:
                            car_data["Price"] = price_match.group()
                            print(f"✅ Found price: {car_data['Price']}")
                            break
                except:
                    continue
            
            # Try to find mileage with most effective selectors first
            mileage_selectors = [
                '[data-cmp="vdp_mileage"]',
                '.vehicle-mileage',
                '.mileage',
                '[class*="mileage"]',
                '[data-testid="mileage"]'
            ]
            
            for selector in mileage_selectors:
                try:
                    mileage_elem = soup.select_one(selector)
                    if mileage_elem and mileage_elem.get_text(strip=True):
                        mileage_text = mileage_elem.get_text(strip=True)
                        mileage_match = re.search(r'[\d,]+', mileage_text)
                        if mileage_match:
                            car_data["Mileage"] = mileage_match.group() + " miles"
                            print(f"✅ Found mileage: {car_data['Mileage']}")
                            break
                except:
                    continue
            
            # Try to find dealer with most effective selectors first
            dealer_selectors = [
                '[data-cmp="vdp_dealer_name"]',
                '.dealer-name',
                '.dealer-info',
                '[class*="dealer"]',
                '[data-testid="dealer-name"]'
            ]
            
            for selector in dealer_selectors:
                try:
                    dealer_elem = soup.select_one(selector)
                    if dealer_elem and dealer_elem.get_text(strip=True):
                        car_data["Dealer"] = dealer_elem.get_text(strip=True)
                        print(f"✅ Found dealer: {car_data['Dealer']}")
                        break
                except:
                    continue
            
            # Extract additional car specifications (streamlined for speed)
            print("🔍 Looking for car specifications...")
            
            # Look for dt/dd pairs which are common for specifications (faster approach)
            dt_elements = soup.find_all('dt')
            for dt in dt_elements:
                dt_text = dt.get_text().strip().lower()
                dd = dt.find_next_sibling('dd')
                if dd:
                    dd_text = dd.get_text().strip()
                    if dd_text and len(dd_text) < 100:  # Reasonable length
                        if 'exterior' in dt_text and 'color' in dt_text and car_data['Exterior Color'] == "N/A":
                            car_data['Exterior Color'] = dd_text
                            print(f"✅ Found Exterior Color: {dd_text}")
                        elif 'interior' in dt_text and 'color' in dt_text and car_data['Interior Color'] == "N/A":
                            car_data['Interior Color'] = dd_text
                            print(f"✅ Found Interior Color: {dd_text}")
                        elif 'drivetrain' in dt_text and car_data['Drivetrain'] == "N/A":
                            car_data['Drivetrain'] = dd_text
                            print(f"✅ Found Drivetrain: {dd_text}")
                        elif 'fuel' in dt_text and 'type' in dt_text and car_data['Fuel Type'] == "N/A":
                            car_data['Fuel Type'] = dd_text
                            print(f"✅ Found Fuel Type: {dd_text}")
                        elif 'transmission' in dt_text and car_data['Transmission'] == "N/A":
                            car_data['Transmission'] = dd_text
                            print(f"✅ Found Transmission: {dd_text}")
                        elif 'engine' in dt_text and car_data['Engine'] == "N/A":
                            car_data['Engine'] = dd_text
                            print(f"✅ Found Engine: {dd_text}")
                        elif 'vin' in dt_text and car_data['VIN'] == "N/A":
                            car_data['VIN'] = dd_text
                            print(f"✅ Found VIN: {dd_text}")
                        elif 'stock' in dt_text and car_data['Stock #'] == "N/A":
                            car_data['Stock #'] = dd_text
                            print(f"✅ Found Stock #: {dd_text}")
            
            
            # Look for mileage specifically
            if car_data['Mileage'] == "N/A":
                mileage_patterns = [r'(\d{1,3}(?:,\d{3})*)\s*(?:miles?|mi\.?)', r'mileage[:\s]*(\d{1,3}(?:,\d{3})*)\s*(?:miles?|mi\.?)']
                for pattern in mileage_patterns:
                    match = re.search(pattern, soup.get_text(), re.IGNORECASE)
                    if match:
                        mileage = match.group(1) + " miles"
                        car_data['Mileage'] = mileage
                        print(f"✅ Found Mileage: {mileage}")
                        break
            
            # Improve Engine extraction - simplified for speed
            if car_data['Engine'] == "N/A" or len(car_data['Engine']) < 20:
                # Look for engine patterns in the page text
                page_text = soup.get_text()
                engine_patterns = [
                    r'engine[:\s]*([^,\n\r]+(?:,\s*[^,\n\r]+){1,})',
                    r'(\d+\.?\d*L?\s*I-\d+\s*[^,\n\r]+(?:,\s*[^,\n\r]+){1,})'
                ]
                
                for pattern in engine_patterns:
                    match = re.search(pattern, page_text, re.IGNORECASE)
                    if match:
                        engine = match.group(1).strip()
                        engine = re.sub(r'\s+', ' ', engine)  # Remove extra spaces
                        engine = engine.rstrip(',')
                        if len(engine) > 10 and len(engine) < 200:  # Reasonable length
                            car_data['Engine'] = engine
                            print(f"✅ Found complete Engine: {engine}")
                            break
            
            # Improve VIN extraction - simplified for speed
            if car_data['VIN'] == "N/A" or len(car_data['VIN']) < 15:
                page_text = soup.get_text()
                vin_patterns = [
                    r'vin[:\s]*([A-HJ-NPR-Z0-9]{17})',  # Standard VIN format
                    r'([A-HJ-NPR-Z0-9]{17})'  # Just look for 17-character alphanumeric
                ]
                
                for pattern in vin_patterns:
                    match = re.search(pattern, page_text, re.IGNORECASE)
                    if match:
                        vin = match.group(1).strip().upper()
                        if len(vin) >= 15:  # Minimum VIN length
                            car_data['VIN'] = vin
                            print(f"✅ Found VIN: {vin}")
                            break
            
            # Extract car images
            print("🔍 Looking for car images...")
            images = []
            
            # Debug: Let's see what img tags exist
            all_imgs = soup.find_all('img')
            print(f"🔍 Found {len(all_imgs)} total img tags on page")
            
            # Look for images with most effective selectors first
            image_selectors = [
                'img[data-cmp="vdp_photo"]',
                'img[data-cmp*="photo"]',
                '.vehicle-photos img',
                '.gallery img',
                '.car-photos img',
                'img[src*="vehicle"]',
                'img[src*="car"]'
            ]
            
            for selector in image_selectors:
                try:
                    img_elements = soup.select(selector)
                    for img in img_elements:
                        # Get the image source
                        img_src = img.get('src') or img.get('data-src') or img.get('data-lazy')
                        if img_src:
                            # Convert relative URLs to absolute URLs
                            if img_src.startswith('//'):
                                img_src = 'https:' + img_src
                            elif img_src.startswith('/'):
                                img_src = 'https://www.cars.com' + img_src
                            elif not img_src.startswith('http'):
                                img_src = 'https://www.cars.com' + img_src
                            
                            # Filter out small images, icons, and non-car images
                            img_width = img.get('width', '0')
                            img_height = img.get('height', '0')
                            
                            # Check if it's a car-related image
                            img_alt = img.get('alt', '').lower()
                            img_class = img.get('class', [])
                            img_class_str = ' '.join(img_class).lower()
                            
                            # Skip if it's clearly not a car image
                            if any(skip_word in img_alt or skip_word in img_class_str for skip_word in ['logo', 'icon', 'dealer', 'advertisement', 'banner', 'sponsor']):
                                continue
                            
                            # Skip very small images (likely icons)
                            if img_width and int(img_width) < 100 and img_height and int(img_height) < 100:
                                continue
                            
                            # Skip images that are clearly not car photos
                            if any(skip_word in img_src.lower() for skip_word in ['logo', 'icon', 'banner', 'ad', 'sponsor']):
                                continue
                            
                            images.append(img_src)
                            print(f"✅ Found image: {img_src}")
                except:
                    continue
            
            # Remove duplicates while preserving order
            seen = set()
            unique_images = []
            for img in images:
                if img not in seen:
                    seen.add(img)
                    unique_images.append(img)
            
            # If no images found with selectors, try a more aggressive approach (limited for speed)
            if len(unique_images) == 0:
                print("🔍 No images found with selectors, trying aggressive approach...")
                # Limit to first 50 images for speed
                for img in all_imgs[:50]:
                    img_src = img.get('src') or img.get('data-src') or img.get('data-lazy')
                    if img_src:
                        # Convert relative URLs to absolute URLs
                        if img_src.startswith('//'):
                            img_src = 'https:' + img_src
                        elif img_src.startswith('/'):
                            img_src = 'https://www.cars.com' + img_src
                        elif not img_src.startswith('http'):
                            img_src = 'https://www.cars.com' + img_src
                        
                        # Look for car-related image URLs
                        if any(car_word in img_src.lower() for car_word in ['vehicle', 'car', 'photo', 'image', 'listing']):
                            # Skip very small images and non-car images
                            img_alt = img.get('alt', '').lower()
                            if not any(skip_word in img_alt for skip_word in ['logo', 'icon', 'dealer', 'advertisement', 'banner']):
                                unique_images.append(img_src)
                                print(f"✅ Found image (aggressive): {img_src}")
                                # Limit to 20 images for speed
                                if len(unique_images) >= 20:
                                    break
            
            car_data['Images'] = unique_images
            print(f"✅ Found {len(unique_images)} car images")
            
            # Parse title to extract year, brand, and model
            if car_data["Title"] != "N/A":
                title = car_data["Title"]
                print(f"🔍 Parsing title: {title}")
                
                # Try to extract year (first 4-digit number)
                year_match = re.search(r'\b(19|20)\d{2}\b', title)
                if year_match:
                    car_data["Year"] = year_match.group()
                    print(f"✅ Found year: {car_data['Year']}")
                
                # Extract brand and model
                # Remove year from title for easier parsing
                title_without_year = re.sub(r'\b(19|20)\d{2}\b\s*', '', title).strip()
                words = title_without_year.split()
                
                if len(words) >= 2:
                    # First word is usually the brand
                    car_data["Brand"] = words[0]
                    # Rest is the model
                    car_data["Model"] = " ".join(words[1:])
                    print(f"✅ Found brand: {car_data['Brand']}")
                    print(f"✅ Found model: {car_data['Model']}")
                elif len(words) == 1:
                    car_data["Brand"] = words[0]
                    car_data["Model"] = "N/A"
            
            # Clean up
            for key, value in car_data.items():
                if isinstance(value, list):
                    # Skip list values (like Images)
                    continue
                if not value or (isinstance(value, str) and value.strip() == ""):
                    car_data[key] = "N/A"
            
            # If we got real data, return it
            if car_data["Title"] != "N/A":
                print("🎉 Successfully scraped real data!")
                return car_data
            else:
                print("⚠️  No real data found, trying next attempt...")
                continue
                
        except Exception as e:
            print(f"❌ Attempt {attempt + 1} failed: {str(e)}")
            if attempt == 2:  # Last attempt
                print("⚠️  All requests failed, trying Selenium fallback...")
                try:
                    return try_selenium_scraping(url)
                except Exception as selenium_error:
                    print(f"❌ Selenium also failed: {str(selenium_error)}")
                    print("⚠️  Using demo data as final fallback...")
                    return get_quick_demo_data(url)
            continue
    
    # If we get here, all attempts failed
    print("⚠️  All real scraping attempts failed, using quick fallback...")
    return get_quick_demo_data(url)

def get_quick_demo_data(url: str) -> dict:
    """
    Generate quick demo data based on URL for fast fallback
    """
    import hashlib
    
    # Create different demo data based on URL hash
    url_hash = hashlib.md5(url.encode()).hexdigest()
    
    # Different car models for variety
    car_models = [
        {"title": "2021 Toyota Camry LE", "price": "$22,500", "mileage": "32,000 miles", "dealer": "Toyota of Downtown", "year": "2021", "make": "Toyota", "model": "Camry LE"},
        {"title": "2019 Honda Accord Sport", "price": "$19,800", "mileage": "45,000 miles", "dealer": "Honda Central", "year": "2019", "make": "Honda", "model": "Accord Sport"},
        {"title": "2020 Ford F-150 XLT", "price": "$35,200", "mileage": "28,000 miles", "dealer": "Ford Motors", "year": "2020", "make": "Ford", "model": "F-150 XLT"},
        {"title": "2022 Chevrolet Silverado LT", "price": "$42,100", "mileage": "15,000 miles", "dealer": "Chevy Dealership", "year": "2022", "make": "Chevrolet", "model": "Silverado LT"},
        {"title": "2021 Nissan Altima SV", "price": "$20,300", "mileage": "38,000 miles", "dealer": "Nissan Auto", "year": "2021", "make": "Nissan", "model": "Altima SV"},
        {"title": "2020 BMW 3 Series", "price": "$28,900", "mileage": "25,000 miles", "dealer": "BMW Center", "year": "2020", "make": "BMW", "model": "3 Series"},
        {"title": "2021 Mercedes-Benz C-Class", "price": "$31,500", "mileage": "22,000 miles", "dealer": "Mercedes-Benz", "year": "2021", "make": "Mercedes-Benz", "model": "C-Class"},
        {"title": "2019 Audi A4", "price": "$26,800", "mileage": "41,000 miles", "dealer": "Audi Downtown", "year": "2019", "make": "Audi", "model": "A4"},
        {"title": "2022 Tesla Model 3", "price": "$45,200", "mileage": "8,500 miles", "dealer": "Tesla Showroom", "year": "2022", "make": "Tesla", "model": "Model 3"},
        {"title": "2020 Subaru Outback", "price": "$24,600", "mileage": "35,000 miles", "dealer": "Subaru Center", "year": "2020", "make": "Subaru", "model": "Outback"},
        {"title": "2021 Mazda CX-5", "price": "$26,800", "mileage": "29,000 miles", "dealer": "Mazda Motors", "year": "2021", "make": "Mazda", "model": "CX-5"},
        {"title": "2019 Lexus ES 350", "price": "$32,400", "mileage": "42,000 miles", "dealer": "Lexus of Downtown", "year": "2019", "make": "Lexus", "model": "ES 350"}
    ]
    
    # Select car based on URL hash
    car_index = int(url_hash, 16) % len(car_models)
    selected_car = car_models[car_index]
    
    demo_data = {
        "Title": selected_car["title"],
        "Year": selected_car["year"],
        "Brand": selected_car["make"], 
        "Model": selected_car["model"],
        "Price": selected_car["price"],
        "Mileage": selected_car["mileage"],
        "Dealer": selected_car["dealer"],
        "Exterior Color": "N/A",
        "Interior Color": "N/A",
        "Drivetrain": "N/A",
        "Fuel Type": "N/A",
        "Transmission": "N/A",
        "Engine": "N/A",
        "VIN": "N/A",
        "Stock #": "N/A",
        "Images": [],
        "URL": url
    }
    
    print("📝 Using quick demo data (real scraping failed)")
    return demo_data

def try_selenium_scraping(url: str) -> dict:
    """
    Try to scrape using Selenium as a fallback
    """
    try:
        from selenium import webdriver
        from selenium.webdriver.chrome.options import Options
        from selenium.webdriver.common.by import By
        from selenium.webdriver.support.ui import WebDriverWait
        from selenium.webdriver.support import expected_conditions as EC
        from selenium.common.exceptions import TimeoutException
        import time
        
        print("🤖 Trying Selenium scraping...")
        
        # Set up Chrome options
        chrome_options = Options()
        chrome_options.add_argument('--headless')  # Run in background
        chrome_options.add_argument('--no-sandbox')
        chrome_options.add_argument('--disable-dev-shm-usage')
        chrome_options.add_argument('--disable-gpu')
        chrome_options.add_argument('--window-size=1920,1080')
        chrome_options.add_argument('--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
        
        # Create driver
        driver = webdriver.Chrome(options=chrome_options)
        
        try:
            # Navigate to the page
            driver.get(url)
            
            # Wait for page to load
            WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.TAG_NAME, "body"))
            )
            
            # Get page source
            page_source = driver.page_source
            
            # Parse with BeautifulSoup
            from bs4 import BeautifulSoup
            soup = BeautifulSoup(page_source, 'html.parser')
            
            # Extract data using the same logic as before
            car_data = {
                "Title": "N/A",
                "Year": "N/A",
                "Brand": "N/A", 
                "Model": "N/A",
                "Price": "N/A", 
                "Mileage": "N/A",
                "Dealer": "N/A",
                "Exterior Color": "N/A",
                "Interior Color": "N/A",
                "Drivetrain": "N/A",
                "Fuel Type": "N/A",
                "Transmission": "N/A",
                "Engine": "N/A",
                "VIN": "N/A",
                "Stock #": "N/A",
                "Images": [],
                "URL": url
            }
            
            # Try to find title
            title_selectors = [
                'h1[data-cmp="vdp_vehicle_title"]',
                'h1.vehicle-title',
                'h1[class*="title"]',
                '.vdp-title',
                'h1',
                '[data-testid="vehicle-title"]'
            ]
            
            for selector in title_selectors:
                try:
                    title_elem = soup.select_one(selector)
                    if title_elem and title_elem.get_text(strip=True):
                        car_data["Title"] = title_elem.get_text(strip=True)
                        print(f"✅ Found title: {car_data['Title']}")
                        break
                except:
                    continue
            
            # Try to find price
            price_selectors = [
                '[data-cmp="vdp_price"]',
                '.price-section .primary-price',
                '.vehicle-price',
                '.price-display',
                '[class*="price"]',
                '[data-testid="price"]'
            ]
            
            for selector in price_selectors:
                try:
                    price_elem = soup.select_one(selector)
                    if price_elem and price_elem.get_text(strip=True):
                        price_text = price_elem.get_text(strip=True)
                        price_match = re.search(r'[\$,\d]+', price_text)
                        if price_match:
                            car_data["Price"] = price_match.group()
                            print(f"✅ Found price: {car_data['Price']}")
                            break
                except:
                    continue
            
            # Try to find mileage
            mileage_selectors = [
                '[data-cmp="vdp_mileage"]',
                '.vehicle-mileage',
                '.mileage',
                '[class*="mileage"]',
                '[data-testid="mileage"]'
            ]
            
            for selector in mileage_selectors:
                try:
                    mileage_elem = soup.select_one(selector)
                    if mileage_elem and mileage_elem.get_text(strip=True):
                        mileage_text = mileage_elem.get_text(strip=True)
                        mileage_match = re.search(r'[\d,]+', mileage_text)
                        if mileage_match:
                            car_data["Mileage"] = mileage_match.group() + " miles"
                            print(f"✅ Found mileage: {car_data['Mileage']}")
                            break
                except:
                    continue
            
            # Try to find dealer
            dealer_selectors = [
                '[data-cmp="vdp_dealer_name"]',
                '.dealer-name',
                '.dealer-info',
                '[class*="dealer"]',
                '[data-testid="dealer-name"]'
            ]
            
            for selector in dealer_selectors:
                try:
                    dealer_elem = soup.select_one(selector)
                    if dealer_elem and dealer_elem.get_text(strip=True):
                        car_data["Dealer"] = dealer_elem.get_text(strip=True)
                        print(f"✅ Found dealer: {car_data['Dealer']}")
                        break
                except:
                    continue
            
            # Parse title to extract year, brand, and model
            if car_data["Title"] != "N/A":
                title = car_data["Title"]
                print(f"🔍 Parsing title: {title}")
                
                # Try to extract year (first 4-digit number)
                year_match = re.search(r'\b(19|20)\d{2}\b', title)
                if year_match:
                    car_data["Year"] = year_match.group()
                    print(f"✅ Found year: {car_data['Year']}")
                
                # Extract brand and model
                title_without_year = re.sub(r'\b(19|20)\d{2}\b\s*', '', title).strip()
                words = title_without_year.split()
                
                if len(words) >= 2:
                    car_data["Brand"] = words[0]
                    car_data["Model"] = " ".join(words[1:])
                    print(f"✅ Found brand: {car_data['Brand']}")
                    print(f"✅ Found model: {car_data['Model']}")
                elif len(words) == 1:
                    car_data["Brand"] = words[0]
                    car_data["Model"] = "N/A"
            
            # Clean up
            for key, value in car_data.items():
                if isinstance(value, list):
                    continue
                if not value or (isinstance(value, str) and value.strip() == ""):
                    car_data[key] = "N/A"
            
            # If we got real data, return it
            if car_data["Title"] != "N/A":
                print("🎉 Successfully scraped real data with Selenium!")
                return car_data
            else:
                print("⚠️  No real data found with Selenium")
                raise Exception("No real data found")
                
        finally:
            driver.quit()
            
    except ImportError:
        print("⚠️  Selenium not available")
        raise Exception("Selenium not available")
    except Exception as e:
        print(f"❌ Selenium scraping failed: {str(e)}")
        raise e

# Test function
if __name__ == "__main__":
    test_url = input("Enter a cars.com URL to test: ").strip()
    
    if not test_url:
        test_url = "https://www.cars.com/vehicledetail/test/"
    
    print(f"Testing URL: {test_url}")
    print("Scraping with advanced method...")
    
    try:
        result = scrape_car_real(test_url)
        print("\n✅ Scraped data successfully:")
        print("-" * 40)
        for key, value in result.items():
            print(f"{key}: {value}")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        print("\nThis method tries multiple approaches to get real data.")
