#!/home/rajesh/projects/scrapping/web_crawling/bin/python3
### Script usage ###
# ./crawling.py <url>
import requests
from urllib.parse import urlparse, urljoin
from bs4 import BeautifulSoup as bs
import sys
import os
import re

#Loading the web page
#url = "https://www.epam.com/"
url = sys.argv[1]
r = requests.get(url)

domain_name = urlparse(url).netloc
#Convert to a beautifulsoup object
soup = bs(r.content, "html.parser")
links = []
for link in soup.findAll('a'):
  if re.search('contact', link.text, re.IGNORECASE):
    if re.search('contact', link.attrs.get("href"), re.IGNORECASE):
      links.append(link.attrs.get("href"))

contactlinks = []
for link in links:
  if 'http' in link:
    contactlinks.append(link)
    continue
  contactlinks.append(url+link)

#Removing duplicate links from the contactlinks list.
cl = []
[cl.append(x) for x in contactlinks if x not in cl]

#print(cl)
tels = []
mailids = []

for l in cl:
  page = requests.get(l)
  soup1 = bs(page.content, "html.parser")
  for link in soup1.findAll('a'):
    if "tel:" in str(link.attrs.get("href")):
      tels.append("tel: " + link.text)

    if "mailto:" in str(link.attrs.get("href")):
      mailids.append(link.attrs.get("href"))
#Removing duplicate telphone numbers
phones = []
[phones.append(x) for x in tels if x not in phones]
tn, ids = "",""
for t in phones:
  tn = tn + t.split(":")[0] + "," + (t.split(":")[1]).strip() + "\n"

for m in mailids:
  ids = ids + m.split(":")[0] + "," + m.split(":")[1] + "\n"

f = open("outputfile.csv", "w")
f.write(tn + ids)
f.close()
