"""
Main scraper manager that handles multiple car websites
"""

import sys
import os
from urllib.parse import urlparse

# Add the scrapers directory to the path
sys.path.append(os.path.dirname(__file__))

def scrape_car(url: str) -> dict:
    """
    Main scraper function that detects the website and calls the appropriate scraper
    
    Args:
        url (str): The car listing URL
        
    Returns:
        dict: Dictionary containing car information
    """
    
    if not url:
        raise ValueError("URL is required")
    
    # Parse the URL to determine the website
    parsed_url = urlparse(url)
    domain = parsed_url.netloc.lower()
    
    # Route to the appropriate scraper based on domain
    if 'cars.com' in domain:
        from cars_com.cars_com import scrape_car as cars_com_scraper
        return cars_com_scraper(url)
    
    elif 'manheim.com.au' in domain:
        from manheim_com_au.manheim import scrape_car as manheim_scraper
        return manheim_scraper(url)
    
    else:
        supported_sites = ', '.join(get_supported_sites())
        raise ValueError(f"Unsupported website: {domain}. Supported sites: {supported_sites}")

def get_supported_sites():
    """
    Returns a list of supported car websites
    """
    return ['cars.com', 'manheim.com.au']

def is_supported_site(url: str) -> bool:
    """
    Check if the URL is from a supported website
    
    Args:
        url (str): The car listing URL
        
    Returns:
        bool: True if supported, False otherwise
    """
    try:
        parsed_url = urlparse(url)
        domain = parsed_url.netloc.lower()
        return any(site in domain for site in get_supported_sites())
    except:
        return False 