from selenium import webdriver
from selenium.webdriver.common.by import By
import time

# Launch browser (Chrome here)
driver = webdriver.Chrome()

# Open the Carfax vehicle page
url = "https://www.carfax.com/vehicle/7JDE23KL7SG005920"
driver.get(url)

time.sleep(5)  # wait for JS to load (increase if needed)

# Extract name (title)
try:
    name = driver.find_element(By.CSS_SELECTOR, "h1").text
except:
    name = "N/A"

# Extract price (Carfax usually puts price in a span/div with $)
try:
    price = driver.find_element(By.XPATH, "//*[contains(text(), '$')]").text
except:
    price = "N/A"

print("Car Name:", name)
print("Car Price:", price)

driver.quit()
