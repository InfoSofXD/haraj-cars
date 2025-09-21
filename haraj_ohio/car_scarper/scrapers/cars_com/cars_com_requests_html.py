from requests_html import HTMLSession
import re
import time

def scrape_car_requests_html(url: str) -> dict:
    """
    Scrape car data from cars.com using requests-html (handles JavaScript)
    
    Args:
        url (str): The cars.com listing URL
        
    Returns:
        dict: Dictionary containing car information
    """
    
    # Validate URL
    if not url or 'cars.com' not in url:
        raise ValueError("Invalid cars.com URL")
    
    session = HTMLSession()
    
    try:
        # Set headers to mimic a real browser
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
            'Cache-Control': 'max-age=0',
            'DNT': '1',
            'Sec-GPC': '1'
        }
        
        print(f"🌐 Navigating to: {url}")
        
        # Get the page and render JavaScript
        r = session.get(url, headers=headers, timeout=30)
        r.html.render(timeout=20, wait=2)  # Wait 2 seconds for JS to load
        
        # Initialize result dictionary
        car_data = {
            "Title": "N/A",
            "Price": "N/A", 
            "Mileage": "N/A",
            "Dealer": "N/A",
            "URL": url
        }
        
        # Extract title - try multiple selectors
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
            'h1[data-testid*="title"]'
        ]
        
        for selector in title_selectors:
            try:
                title_elem = r.html.find(selector, first=True)
                if title_elem and title_elem.text.strip():
                    car_data["Title"] = title_elem.text.strip()
                    print(f"✅ Found title: {car_data['Title']}")
                    break
            except:
                continue
        
        # Extract price - try multiple selectors
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
            'div[class*="price"]'
        ]
        
        for selector in price_selectors:
            try:
                price_elem = r.html.find(selector, first=True)
                if price_elem and price_elem.text.strip():
                    price_text = price_elem.text.strip()
                    price_match = re.search(r'[\$,\d]+', price_text)
                    if price_match:
                        car_data["Price"] = price_match.group()
                        print(f"✅ Found price: {car_data['Price']}")
                        break
            except:
                continue
        
        # Extract mileage
        mileage_selectors = [
            '[data-cmp="vdp_mileage"]',
            '.vehicle-mileage',
            '.mileage',
            '[class*="mileage"]',
            '[data-testid="mileage"]'
        ]
        
        for selector in mileage_selectors:
            try:
                mileage_elem = r.html.find(selector, first=True)
                if mileage_elem and mileage_elem.text.strip():
                    mileage_text = mileage_elem.text.strip()
                    mileage_match = re.search(r'[\d,]+', mileage_text)
                    if mileage_match:
                        car_data["Mileage"] = mileage_match.group() + " miles"
                        print(f"✅ Found mileage: {car_data['Mileage']}")
                        break
            except:
                continue
        
        # Extract dealer information
        dealer_selectors = [
            '[data-cmp="vdp_dealer_name"]',
            '.dealer-name',
            '.dealer-info',
            '[class*="dealer"]',
            '[data-testid="dealer-name"]'
        ]
        
        for selector in dealer_selectors:
            try:
                dealer_elem = r.html.find(selector, first=True)
                if dealer_elem and dealer_elem.text.strip():
                    car_data["Dealer"] = dealer_elem.text.strip()
                    print(f"✅ Found dealer: {car_data['Dealer']}")
                    break
            except:
                continue
        
        # Additional data extraction
        if car_data["Title"] != "N/A":
            title = car_data["Title"]
            # Try to extract year
            year_match = re.search(r'\b(19|20)\d{2}\b', title)
            if year_match:
                car_data["Year"] = year_match.group()
            
            # Try to extract make and model
            words = title.split()
            if len(words) >= 2:
                car_data["Make"] = words[0] if words[0] else "N/A"
                car_data["Model"] = " ".join(words[1:3]) if len(words) > 1 else "N/A"
        
        # Clean up any remaining "N/A" values
        for key, value in car_data.items():
            if not value or value.strip() == "":
                car_data[key] = "N/A"
        
        return car_data
        
    except Exception as e:
        raise Exception(f"Requests-HTML scraping failed: {str(e)}")
    finally:
        session.close()

# Test function
if __name__ == "__main__":
    test_url = input("Enter a cars.com URL to test: ").strip()
    
    if not test_url:
        test_url = "https://www.cars.com/vehicledetail/test/"
    
    print(f"Testing URL: {test_url}")
    print("Scraping with requests-html...")
    
    try:
        result = scrape_car_requests_html(test_url)
        print("\n✅ Scraped data successfully:")
        print("-" * 40)
        for key, value in result.items():
            print(f"{key}: {value}")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        print("\nNote: This uses requests-html which can handle JavaScript")
