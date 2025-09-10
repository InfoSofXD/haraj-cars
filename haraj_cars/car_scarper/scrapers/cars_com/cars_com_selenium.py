from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException
from webdriver_manager.chrome import ChromeDriverManager
import time
import re

def scrape_car_selenium(url: str) -> dict:
    """
    Scrape car data from cars.com using Selenium (bypasses anti-bot protection)
    
    Args:
        url (str): The cars.com listing URL
        
    Returns:
        dict: Dictionary containing car information
    """
    
    # Validate URL
    if not url or 'cars.com' not in url:
        raise ValueError("Invalid cars.com URL")
    
    # Setup Chrome options
    chrome_options = Options()
    chrome_options.add_argument("--headless")  # Run in background
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--disable-blink-features=AutomationControlled")
    chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])
    chrome_options.add_experimental_option('useAutomationExtension', False)
    chrome_options.add_argument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    
    # Additional options to avoid conflicts
    chrome_options.add_argument("--disable-extensions")
    chrome_options.add_argument("--disable-plugins")
    chrome_options.add_argument("--disable-images")  # Faster loading
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--remote-debugging-port=0")  # Use random port
    
    driver = None
    try:
        # Initialize Chrome driver with automatic driver management
        service = Service(ChromeDriverManager().install())
        driver = webdriver.Chrome(service=service, options=chrome_options)
        
        # Execute script to remove webdriver property
        driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")
        
        # Navigate to the URL
        print(f"🌐 Navigating to: {url}")
        driver.get(url)
        
        # Wait for page to load
        wait = WebDriverWait(driver, 10)
        
        # Initialize result dictionary
        car_data = {
            "Title": "N/A",
            "Price": "N/A", 
            "Mileage": "N/A",
            "Dealer": "N/A",
            "URL": url
        }
        
        # Extract title
        title_selectors = [
            "h1[data-cmp='vdp_vehicle_title']",
            "h1.vehicle-title",
            "h1[class*='title']",
            ".vdp-title",
            "h1",
            "[data-testid='vehicle-title']",
            ".vehicle-title",
            ".listing-title"
        ]
        
        for selector in title_selectors:
            try:
                title_elem = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, selector)))
                if title_elem and title_elem.text.strip():
                    car_data["Title"] = title_elem.text.strip()
                    print(f"✅ Found title: {car_data['Title']}")
                    break
            except (TimeoutException, NoSuchElementException):
                continue
        
        # Extract price
        price_selectors = [
            "[data-cmp='vdp_price']",
            ".price-section .primary-price",
            ".vehicle-price",
            ".price-display",
            "[class*='price']",
            "[data-testid='price']",
            ".price",
            ".listing-price"
        ]
        
        for selector in price_selectors:
            try:
                price_elem = driver.find_element(By.CSS_SELECTOR, selector)
                if price_elem and price_elem.text.strip():
                    price_text = price_elem.text.strip()
                    price_match = re.search(r'[\$,\d]+', price_text)
                    if price_match:
                        car_data["Price"] = price_match.group()
                        print(f"✅ Found price: {car_data['Price']}")
                        break
            except NoSuchElementException:
                continue
        
        # Extract mileage
        mileage_selectors = [
            "[data-cmp='vdp_mileage']",
            ".vehicle-mileage",
            ".mileage",
            "[class*='mileage']",
            "[data-testid='mileage']"
        ]
        
        for selector in mileage_selectors:
            try:
                mileage_elem = driver.find_element(By.CSS_SELECTOR, selector)
                if mileage_elem and mileage_elem.text.strip():
                    mileage_text = mileage_elem.text.strip()
                    mileage_match = re.search(r'[\d,]+', mileage_text)
                    if mileage_match:
                        car_data["Mileage"] = mileage_match.group() + " miles"
                        print(f"✅ Found mileage: {car_data['Mileage']}")
                        break
            except NoSuchElementException:
                continue
        
        # Extract dealer information
        dealer_selectors = [
            "[data-cmp='vdp_dealer_name']",
            ".dealer-name",
            ".dealer-info",
            "[class*='dealer']",
            "[data-testid='dealer-name']"
        ]
        
        for selector in dealer_selectors:
            try:
                dealer_elem = driver.find_element(By.CSS_SELECTOR, selector)
                if dealer_elem and dealer_elem.text.strip():
                    car_data["Dealer"] = dealer_elem.text.strip()
                    print(f"✅ Found dealer: {car_data['Dealer']}")
                    break
            except NoSuchElementException:
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
        raise Exception(f"Selenium scraping failed: {str(e)}")
    finally:
        if driver:
            driver.quit()

# Test function
if __name__ == "__main__":
    test_url = input("Enter a cars.com URL to test: ").strip()
    
    if not test_url:
        test_url = "https://www.cars.com/vehicledetail/test/"
    
    print(f"Testing URL: {test_url}")
    print("Scraping with Selenium...")
    
    try:
        result = scrape_car_selenium(test_url)
        print("\n✅ Scraped data successfully:")
        print("-" * 40)
        for key, value in result.items():
            print(f"{key}: {value}")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        print("\nNote: You need to install Selenium and ChromeDriver:")
        print("pip install selenium")
        print("Download ChromeDriver from: https://chromedriver.chromium.org/")
