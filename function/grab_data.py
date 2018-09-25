#/usr/bin/python3
import requests
from bs4 import BeautifulSoup

eds_url = 'https://roualdes.us'

def retrieve(target):
    page = requests.get(eds_url + '/teaching') ## Grab html page
    soup = BeautifulSoup(page.text, 'html.parser') ## Convert page to soup object
    data_list = soup.find("div", id="MATH385data") ## Grab everything in MATH385 div
    data_list_items = data_list.find_all('li') ## Find all links in div

    for data in data_list_items:
        if target in data.contents[0]:
            res = data.find('a')
            return eds_url + res.get('href')

