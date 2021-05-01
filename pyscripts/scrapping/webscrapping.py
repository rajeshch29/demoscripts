#!/home/rajesh/projects/scrapping/web_crawling/bin/python3
import requests
from urllib.parse import urlparse, urljoin
from bs4 import BeautifulSoup as bs

#Loading the web page
url = "https://www.epam.com/"
r = requests.get(url)

def is_valid(url):
    """
    Checks whether `url` is a valid URL.
    """
    parsed = urlparse(url)
    return bool(parsed.netloc) and bool(parsed.scheme)

domain_name = urlparse(url).netloc
#Convert to a beautifulsoup object
soup = bs(r.content, "html.parser")
links = []
for link in soup.findAll('a'):
  href = link.attrs.get("href")
  if href == "" or href is None:
    continue

#  if is_valid(href):
  href = urljoin(url, href)
  #parsed_href = urlparse(href)
  # remove URL GET parameters, URL fragments, etc.
  #href = parsed_href.scheme + "://" + parsed_href.netloc + parsed_href.path
  if domain_name in href:

    links.append(href)

for link in links:
  print(link)
    


