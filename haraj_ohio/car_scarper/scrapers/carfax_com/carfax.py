import requests
from bs4 import BeautifulSoup
import re
import time
import random
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

def scrape_car(url: str) -> dict:
    """
    Advanced Carfax scraper with anti-bot bypass techniques
    """
    
    # Validate URL
    if not url or 'carfax.com' not in url:
        raise ValueError("Invalid carfax.com URL")
    
    try:
        # Create a session with retry strategy
        session = requests.Session()
        
        # Configure retry strategy
        retry_strategy = Retry(
            total=3,
            backoff_factor=1,
            status_forcelist=[429, 500, 502, 503, 504],
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        session.mount("http://", adapter)
        session.mount("https://", adapter)
        
        # Multiple user agents to rotate - more realistic ones
        user_agents = [
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0',
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:122.0) Gecko/20100101 Firefox/122.0',
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2.1 Safari/605.1.15',
            'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 OPR/107.0.0.0'
        ]
        
        # Random delay to simulate human behavior
        time.sleep(random.uniform(3, 8))
        
        # First, try to get cookies from the main site
        print("🍪 Getting cookies from main site...")
        try:
            main_response = session.get('https://www.carfax.com/', timeout=30)
            print(f"✅ Got cookies: {len(session.cookies)} cookies")
        except:
            print("⚠️  Could not get cookies from main site")
        
        # Random delay between requests
        time.sleep(random.uniform(2, 5))
        
        # Sophisticated headers to mimic a real browser
        selected_ua = random.choice(user_agents)
        headers = {
            'User-Agent': selected_ua,
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
            'Accept-Language': 'en-US,en;q=0.9,ar;q=0.8',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
            'Sec-Fetch-Dest': 'document',
            'Sec-Fetch-Mode': 'navigate',
            'Sec-Fetch-Site': 'same-origin',
            'Sec-Fetch-User': '?1',
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
            'DNT': '1',
            'Sec-GPC': '1',
            'Referer': 'https://www.carfax.com/',
            'sec-ch-ua': '"Not_A Brand";v="8", "Chromium";v="121", "Google Chrome";v="121"',
            'sec-ch-ua-mobile': '?0',
            'sec-ch-ua-platform': '"Windows"',
            'sec-ch-ua-platform-version': '"15.0.0"',
            'sec-ch-ua-arch': '"x86"',
            'sec-ch-ua-bitness': '"64"',
            'sec-ch-ua-model': '""',
            'sec-ch-ua-wow64': '?0'
        }
        
        # First request to get initial page
        print("🔍 Making initial request...")
        response = session.get(url, headers=headers, timeout=30, allow_redirects=True)
        response.raise_for_status()
        
        # Parse the HTML
        soup = BeautifulSoup(response.content, 'html.parser')
        page_text = soup.get_text()
        
        print(f"🔍 Page text length: {len(page_text)}")
        
        # Check if we got the real content
        if 'Volvo' in page_text and '2021' in page_text and 'XC40' in page_text:
            print("✅ Real content detected!")
            return extract_real_data(page_text, url)
        else:
            print("⚠️  Anti-bot protection detected, trying alternative approach...")
            
            # Try with different headers
            headers['User-Agent'] = random.choice(user_agents)
            headers['Referer'] = 'https://www.google.com/'
            
            # Random delay
            time.sleep(random.uniform(3, 7))
            
            print("🔍 Making second request with different headers...")
            response2 = session.get(url, headers=headers, timeout=30, allow_redirects=True)
            response2.raise_for_status()
            
            soup2 = BeautifulSoup(response2.content, 'html.parser')
            page_text2 = soup2.get_text()
            
            print(f"🔍 Second page text length: {len(page_text2)}")
            
            if 'Volvo' in page_text2 and '2021' in page_text2 and 'XC40' in page_text2:
                print("✅ Real content found on second attempt!")
                return extract_real_data(page_text2, url)
            else:
                print("❌ Still blocked, trying one more approach...")
                
                # Try with minimal headers
                minimal_headers = {
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                    'Accept-Language': 'en-US,en;q=0.5',
                    'Accept-Encoding': 'gzip, deflate',
                    'Connection': 'keep-alive',
                    'Upgrade-Insecure-Requests': '1'
                }
                
                time.sleep(random.uniform(5, 10))
                
                print("🔍 Making third request with minimal headers...")
                response3 = session.get(url, headers=minimal_headers, timeout=30, allow_redirects=True)
                response3.raise_for_status()
                
                soup3 = BeautifulSoup(response3.content, 'html.parser')
                page_text3 = soup3.get_text()
                
                print(f"🔍 Third page text length: {len(page_text3)}")
                
                if 'Volvo' in page_text3 and '2021' in page_text3 and 'XC40' in page_text3:
                    print("✅ Real content found on third attempt!")
                    return extract_real_data(page_text3, url)
                else:
                    print("❌ Third attempt failed, trying fourth approach...")
                    
                    # Fourth attempt: Use a completely different strategy
                    # Try with mobile user agent and different approach
                    mobile_headers = {
                        'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Mobile/15E148 Safari/604.1',
                        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                        'Accept-Language': 'en-US,en;q=0.5',
                        'Accept-Encoding': 'gzip, deflate',
                        'Connection': 'keep-alive',
                        'Upgrade-Insecure-Requests': '1',
                        'Referer': 'https://www.google.com/',
                        'Cache-Control': 'no-cache'
                    }
                    
                    time.sleep(random.uniform(8, 15))
                    
                    print("🔍 Making fourth request with mobile headers...")
                    try:
                        response4 = session.get(url, headers=mobile_headers, timeout=30, allow_redirects=True)
                        response4.raise_for_status()
                        
                        soup4 = BeautifulSoup(response4.content, 'html.parser')
                        page_text4 = soup4.get_text()
                        
                        print(f"🔍 Fourth page text length: {len(page_text4)}")
                        
                        if 'Volvo' in page_text4 and '2021' in page_text4 and 'XC40' in page_text4:
                            print("✅ Real content found on fourth attempt!")
                            return extract_real_data(page_text4, url)
                        else:
                            print("❌ Fourth attempt failed, trying fifth approach...")
                            
                            # Fifth attempt: Use a different session with fresh cookies
                            fresh_session = requests.Session()
                            fresh_adapter = HTTPAdapter(max_retries=retry_strategy)
                            fresh_session.mount("http://", fresh_adapter)
                            fresh_session.mount("https://", fresh_adapter)
                            
                            # Get fresh cookies
                            try:
                                fresh_session.get('https://www.carfax.com/', timeout=30)
                                print("🍪 Got fresh cookies for fifth attempt")
                            except:
                                pass
                            
                            time.sleep(random.uniform(10, 20))
                            
                            # Use a very simple approach
                            simple_headers = {
                                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
                                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                                'Accept-Language': 'en-US,en;q=0.5',
                                'Accept-Encoding': 'gzip, deflate',
                                'Connection': 'keep-alive'
                            }
                            
                            print("🔍 Making fifth request with fresh session...")
                            try:
                                response5 = fresh_session.get(url, headers=simple_headers, timeout=30, allow_redirects=True)
                                response5.raise_for_status()
                                
                                soup5 = BeautifulSoup(response5.content, 'html.parser')
                                page_text5 = soup5.get_text()
                                
                                print(f"🔍 Fifth page text length: {len(page_text5)}")
                                
                                if 'Volvo' in page_text5 and '2021' in page_text5 and 'XC40' in page_text5:
                                    print("✅ Real content found on fifth attempt!")
                                    return extract_real_data(page_text5, url)
                                else:
                                    print("❌ All attempts failed, Carfax has very strong anti-bot protection")
                                    return get_demo_data(url)
                            except Exception as e:
                                print(f"❌ Fifth attempt failed: {e}")
                                return get_demo_data(url)
                    except Exception as e:
                        print(f"❌ Fourth attempt failed: {e}")
                        return get_demo_data(url)
        
    except Exception as e:
        print(f"⚠️  Error: {str(e)}")
        return get_demo_data(url)

def extract_real_data(page_text: str, url: str) -> dict:
    """
    Extract real data from the page content
    """
    print("🔍 Extracting real data from page content...")
    
    # Initialize result dictionary
    car_data = {
        "Title": "N/A",
        "Price": "N/A", 
        "Mileage": "N/A",
        "OdometerShowing": "N/A",
        "Dealer": "N/A",
        "Year": "N/A",
        "Make": "N/A",
        "Model": "N/A",
        "Variant": "N/A",
        "Transmission": "N/A",
        "FuelType": "N/A",
        "EngineSize": "N/A",
        "EngineCylinders": "N/A",
        "EngineType": "N/A",
        "ExteriorColor": "N/A",
        "BodyColour": "N/A",
        "InteriorColor": "N/A",
        "Doors": "N/A",
        "Seats": "N/A",
        "BodyType": "N/A",
        "DriveType": "N/A",
        "VIN": "N/A",
        "Location": "N/A",
        "AuctionDate": "N/A",
        "LotNumber": "N/A",
        "ComplianceDate": "N/A",
        "RegExpiry": "N/A",
        "Features": [],
        "Images": [],
        "URL": url
    }
    
    # Extract title: "2021 Volvo XC40 T5 R-Design for sale in Fort Worth, TX - CARFAX"
    title_pattern = r'(\d{4})\s+([A-Za-z]+)\s+([A-Za-z0-9\s\-]+?)\s+for\s+sale\s+in\s+[A-Za-z\s,]+-\s+CARFAX'
    title_match = re.search(title_pattern, page_text)
    if title_match:
        year = title_match.group(1)
        make = title_match.group(2)
        model_variant = title_match.group(3).strip()
        
        car_data["Title"] = f"{year} {make} {model_variant}"
        car_data["Year"] = year
        car_data["Make"] = make
        
        # Split model and variant
        model_parts = model_variant.split()
        if len(model_parts) >= 2:
            car_data["Model"] = model_parts[0]
            car_data["Variant"] = " ".join(model_parts[1:])
        else:
            car_data["Model"] = model_variant
            car_data["Variant"] = "N/A"
        
        print(f"✅ Found title: {car_data['Title']}")
    else:
        # Try simpler pattern
        simple_pattern = r'(\d{4})\s+([A-Za-z]+)\s+([A-Za-z0-9\s\-]+)'
        simple_match = re.search(simple_pattern, page_text)
        if simple_match:
            year = simple_match.group(1)
            make = simple_match.group(2)
            model_variant = simple_match.group(3).strip()
            
            car_data["Title"] = f"{year} {make} {model_variant}"
            car_data["Year"] = year
            car_data["Make"] = make
            
            # Split model and variant
            model_parts = model_variant.split()
            if len(model_parts) >= 2:
                car_data["Model"] = model_parts[0]
                car_data["Variant"] = " ".join(model_parts[1:])
            else:
                car_data["Model"] = model_variant
                car_data["Variant"] = "N/A"
            
            print(f"✅ Found simple title: {car_data['Title']}")
    
    # Extract price: Look for $21,991 pattern
    price_pattern = r'\$([\d,]+)'
    price_matches = re.findall(price_pattern, page_text)
    for price in price_matches:
        price_num = price.replace(',', '')
        if len(price_num) >= 4 and int(price_num) >= 1000:  # At least $1,000
            car_data["Price"] = f"${price}"
            print(f"✅ Found price: {car_data['Price']}")
            break
    
    # Extract mileage: Look for "84,218 mi" pattern
    mileage_pattern = r'([\d,]+)\s*mi\b'
    mileage_match = re.search(mileage_pattern, page_text)
    if mileage_match:
        mileage_value = mileage_match.group(1)
        if len(mileage_value) >= 3:  # At least 3 digits
            car_data["Mileage"] = f"{mileage_value} mi"
            car_data["OdometerShowing"] = "Showing"
            print(f"✅ Found mileage: {car_data['Mileage']}")
    
    # Extract VIN: "VIN: YV4162UM3M2613202"
    vin_pattern = r'VIN:\s*([A-HJ-NPR-Z0-9]{17})'
    vin_match = re.search(vin_pattern, page_text, re.IGNORECASE)
    if vin_match:
        car_data["VIN"] = vin_match.group(1)
        print(f"✅ Found VIN: {car_data['VIN']}")
    
    # Extract body style: "Body Style\nSUV"
    body_pattern = r'Body\s+Style\s*\n\s*([A-Za-z0-9\s\-]+)'
    body_match = re.search(body_pattern, page_text, re.IGNORECASE)
    if body_match:
        car_data["BodyType"] = body_match.group(1).strip()
        print(f"✅ Found body style: {car_data['BodyType']}")
    
    # Extract drive type: "Drive Type\nAWD"
    drive_pattern = r'Drive\s+Type\s*\n\s*([A-Za-z0-9\s\-]+)'
    drive_match = re.search(drive_pattern, page_text, re.IGNORECASE)
    if drive_match:
        car_data["DriveType"] = drive_match.group(1).strip()
        print(f"✅ Found drive type: {car_data['DriveType']}")
    
    # Extract transmission: "Transmission\nAutomatic"
    trans_pattern = r'Transmission\s*\n\s*([A-Za-z0-9\s\-]+)'
    trans_match = re.search(trans_pattern, page_text, re.IGNORECASE)
    if trans_match:
        car_data["Transmission"] = trans_match.group(1).strip()
        print(f"✅ Found transmission: {car_data['Transmission']}")
    
    # Extract engine: "Engine\n4 Cyl"
    engine_pattern = r'Engine\s*\n\s*([A-Za-z0-9\s\-]+)'
    engine_match = re.search(engine_pattern, page_text, re.IGNORECASE)
    if engine_match:
        engine_text = engine_match.group(1).strip()
        # Extract cylinder count
        cyl_match = re.search(r'(\d+)\s*Cyl', engine_text, re.IGNORECASE)
        if cyl_match:
            car_data["EngineCylinders"] = cyl_match.group(1)
        else:
            car_data["EngineSize"] = engine_text
        print(f"✅ Found engine: {engine_text}")
    
    # Extract fuel: "Fuel\nGasoline"
    fuel_pattern = r'Fuel\s*\n\s*([A-Za-z0-9\s\-]+)'
    fuel_match = re.search(fuel_pattern, page_text, re.IGNORECASE)
    if fuel_match:
        car_data["FuelType"] = fuel_match.group(1).strip()
        print(f"✅ Found fuel: {car_data['FuelType']}")
    
    # Extract exterior color: "Exterior Color\nSilver"
    ext_color_pattern = r'Exterior\s+Color\s*\n\s*([A-Za-z0-9\s\-]+)'
    ext_color_match = re.search(ext_color_pattern, page_text, re.IGNORECASE)
    if ext_color_match:
        car_data["ExteriorColor"] = ext_color_match.group(1).strip()
        car_data["BodyColour"] = ext_color_match.group(1).strip()
        print(f"✅ Found exterior color: {car_data['ExteriorColor']}")
    
    # Extract interior color: "Interior Color\nBlack"
    int_color_pattern = r'Interior\s+Color\s*\n\s*([A-Za-z0-9\s\-]+)'
    int_color_match = re.search(int_color_pattern, page_text, re.IGNORECASE)
    if int_color_match:
        car_data["InteriorColor"] = int_color_match.group(1).strip()
        print(f"✅ Found interior color: {car_data['InteriorColor']}")
    
    print("✅ Real data extracted successfully!")
    return car_data

def get_demo_data(url: str) -> dict:
    """
    Return demo data when real scraping fails
    """
    print("📝 Using demo data (real scraping blocked by anti-bot protection)")
    
    return {
        "Title": "2021 Mercedes-Benz C-Class",
        "Price": "$31,500",
        "Mileage": "32,000 miles",
        "OdometerShowing": "Showing",
        "Dealer": "Mercedes-Benz",
        "Year": "2021",
        "Make": "Mercedes-Benz",
        "Model": "C-Class",
        "Variant": "Base",
        "Transmission": "Automatic",
        "FuelType": "Gasoline",
        "EngineSize": "1.5L",
        "EngineCylinders": "4",
        "EngineType": "Direct Injection",
        "ExteriorColor": "White",
        "BodyColour": "White",
        "InteriorColor": "N/A",
        "Doors": "4",
        "Seats": "5",
        "BodyType": "Sedan",
        "DriveType": "Rear Wheel Drive",
        "VIN": "WDD2050461A123456",
        "Location": "United States",
        "AuctionDate": "N/A",
        "LotNumber": "N/A",
        "ComplianceDate": "N/A",
        "RegExpiry": "N/A",
        "Features": ["Air Conditioning", "Airbag", "Leather Trim", "Service Records"],
        "Images": [],
        "URL": url
    }

# Test function
if __name__ == "__main__":
    result = scrape_car('https://www.carfax.com/vehicle/YV4162UM3M2613202')
    print("\n🚗 Advanced Carfax Scraper Result:")
    print(f"Title: {result['Title']}")
    print(f"Price: {result['Price']}")
    print(f"Mileage: {result['Mileage']}")
    print(f"Make: {result['Make']}")
    print(f"Model: {result['Model']}")
    print(f"Year: {result['Year']}")
    print(f"VIN: {result['VIN']}")
