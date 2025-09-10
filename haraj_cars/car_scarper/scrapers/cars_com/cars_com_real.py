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
    
    # Try multiple approaches
    for attempt in range(3):
        try:
            # Random delay between attempts
            if attempt > 0:
                time.sleep(random.uniform(2, 5))
            
            # Create session
            session = requests.Session()
            
            # Set headers
            headers = {
                'User-Agent': random.choice(user_agents),
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
            
            session.headers.update(headers)
            
            print(f"🌐 Attempt {attempt + 1}: Trying to access {url}")
            
            # Make request
            response = session.get(url, timeout=30, allow_redirects=True)
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
            
            # Try to find title with more comprehensive selectors
            title_selectors = [
                'h1[data-cmp="vdp_vehicle_title"]',
                'h1.vehicle-title',
                'h1[class*="title"]',
                '.vdp-title',
                'h1',
                '[data-testid="vehicle-title"]',
                '.vehicle-title',
                '.listing-title',
                'h1[class*="vehicle"]',
                '.vehicle-name',
                'h1[data-testid*="title"]',
                '.vehicle-details h1',
                '.vehicle-info h1',
                '.car-title',
                '.listing-title h1'
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
                '[data-testid="price"]',
                '.price',
                '.listing-price',
                '[class*="listing-price"]',
                '.vehicle-price-display',
                'span[class*="price"]',
                'div[class*="price"]',
                '.price-value',
                '.vehicle-price-value',
                '.car-price'
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
            
            # Try to find mileage
            mileage_selectors = [
                '[data-cmp="vdp_mileage"]',
                '.vehicle-mileage',
                '.mileage',
                '[class*="mileage"]',
                '[data-testid="mileage"]',
                '.car-mileage',
                '.vehicle-mileage-value'
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
                '[data-testid="dealer-name"]',
                '.car-dealer',
                '.vehicle-dealer'
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
            
            # Extract additional car specifications
            print("🔍 Looking for car specifications...")
            
            # Look for specification sections
            spec_sections = soup.find_all(['div', 'section'], class_=re.compile(r'spec|detail|feature|info'))
            
            # Common patterns for car specs
            spec_patterns = {
                'Exterior Color': [r'exterior\s*color', r'ext\s*color', r'color\s*exterior'],
                'Interior Color': [r'interior\s*color', r'int\s*color', r'color\s*interior'],
                'Drivetrain': [r'drivetrain', r'drive\s*train', r'wheel\s*drive'],
                'Fuel Type': [r'fuel\s*type', r'fuel', r'engine\s*type'],
                'Transmission': [r'transmission', r'trans'],
                'Engine': [r'engine', r'motor'],
                'VIN': [r'vin', r'vehicle\s*identification'],
                'Stock #': [r'stock\s*#', r'stock\s*number', r'stock']
            }
            
            # Search for specifications in a more targeted way
            # Look for specific sections that contain car details
            detail_sections = soup.find_all(['div', 'section', 'ul', 'dl'], class_=re.compile(r'detail|spec|feature|info|description', re.IGNORECASE))
            
            for section in detail_sections:
                section_text = section.get_text()
                
                # Look for key-value pairs in the format "Key: Value"
                for spec_name, patterns in spec_patterns.items():
                    if car_data[spec_name] == "N/A":  # Only if not already found
                        for pattern in patterns:
                            # Look for the pattern followed by a colon and value
                            match = re.search(rf'{pattern}[:\s]*([^\n\r,]+)', section_text, re.IGNORECASE)
                            if match:
                                value = match.group(1).strip()
                                # Clean up the value - remove extra text and keep only relevant parts
                                value = re.sub(r'[^\w\s\-/]', '', value).strip()
                                # Filter out very long values that are likely not what we want
                                if value and len(value) > 1 and len(value) < 50:
                                    car_data[spec_name] = value
                                    print(f"✅ Found {spec_name}: {value}")
                                    break
            
            # Try to find specifications in structured data (definition lists)
            # Look for dt/dd pairs which are common for specifications
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
            
            # Improve Engine extraction - look for more complete engine descriptions
            if car_data['Engine'] == "N/A" or len(car_data['Engine']) < 50:
                engine_patterns = [
                    # Look for the specific pattern you mentioned: "2L I-4 gasoline direct injection, DOHC, variable valve control"
                    r'(2L\s*I-4\s*gasoline\s*direct\s*injection[^,\n\r]*(?:,\s*[^,\n\r]+)*)',
                    # Look for engine with multiple parts separated by commas
                    r'engine[:\s]*([^,\n\r]+(?:,\s*[^,\n\r]+){2,})',
                    # Look for specific engine patterns with more detail
                    r'(\d+\.?\d*L?\s*I-\d+\s*[^,\n\r]+(?:,\s*[^,\n\r]+){1,})',
                    # Look for complete engine descriptions
                    r'(2L\s*I-4\s*[^,\n\r]+(?:,\s*[^,\n\r]+){2,})',
                    r'(EcoBoost\s*[^,\n\r]+(?:,\s*[^,\n\r]+){1,})',
                    r'(VC-Turbo\s*[^,\n\r]+(?:,\s*[^,\n\r]+){1,})',
                    # Look for any engine description that's longer
                    r'engine[:\s]*([^,\n\r]+(?:,\s*[^,\n\r]+)+)'
                ]
                
                page_text = soup.get_text()
                for pattern in engine_patterns:
                    match = re.search(pattern, page_text, re.IGNORECASE)
                    if match:
                        engine = match.group(1).strip()
                        # Clean up the engine description
                        engine = re.sub(r'\s+', ' ', engine)  # Remove extra spaces
                        # Remove trailing comma if present
                        engine = engine.rstrip(',')
                        if len(engine) > 20 and len(engine) < 300:  # Reasonable length
                            car_data['Engine'] = engine
                            print(f"✅ Found complete Engine: {engine}")
                            break
            
            # Improve VIN extraction - look for proper VIN format
            if car_data['VIN'] == "N/A" or len(car_data['VIN']) < 15 or not re.match(r'^[A-HJ-NPR-Z0-9]+$', car_data['VIN']):
                vin_patterns = [
                    r'vin[:\s]*([A-HJ-NPR-Z0-9]{17})',  # Standard VIN format
                    r'vin[:\s]*([A-HJ-NPR-Z0-9]{10,17})',  # Flexible VIN format
                    r'([A-HJ-NPR-Z0-9]{17})',  # Just look for 17-character alphanumeric
                    r'vin[:\s]*([A-Z0-9]{17})'  # Alternative VIN format
                ]
                
                page_text = soup.get_text()
                for pattern in vin_patterns:
                    match = re.search(pattern, page_text, re.IGNORECASE)
                    if match:
                        vin = match.group(1).strip().upper()
                        if len(vin) >= 10:  # Minimum VIN length
                            car_data['VIN'] = vin
                            print(f"✅ Found VIN: {vin}")
                            break
            
            # Extract car images
            print("🔍 Looking for car images...")
            images = []
            
            # Debug: Let's see what img tags exist
            all_imgs = soup.find_all('img')
            print(f"🔍 Found {len(all_imgs)} total img tags on page")
            
            # Look for images in various common selectors
            image_selectors = [
                'img[data-cmp="vdp_photo"]',
                'img[data-cmp*="photo"]',
                'img[data-cmp*="image"]',
                '.vehicle-photos img',
                '.gallery img',
                '.car-photos img',
                '.vehicle-images img',
                '.photo-gallery img',
                '[class*="photo"] img',
                '[class*="image"] img',
                '[class*="gallery"] img',
                '.vdp-photos img',
                '.vehicle-detail-photos img',
                '.vehicle-photo img',
                '.listing-photos img',
                '.car-gallery img',
                '.image-gallery img',
                '.photos img',
                '.images img',
                'img[src*="vehicle"]',
                'img[src*="car"]',
                'img[src*="photo"]'
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
            
            # If no images found with selectors, try a more aggressive approach
            if len(unique_images) == 0:
                print("🔍 No images found with selectors, trying aggressive approach...")
                for img in all_imgs:
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
                raise Exception(f"All attempts failed. Last error: {str(e)}")
            continue
    
    # If we get here, all attempts failed
    raise Exception("Failed to scrape real data after all attempts")

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
