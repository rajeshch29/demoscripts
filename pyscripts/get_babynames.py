#!/usr/bin/python3 -tt
import sys
import re

# Script Usage: ./get_babynames.py babynames.txt
def getNames(filename):
  with open(filename, 'r') as f:
    nameList = []
    for line in f:
      out = re.search('<td>\d+</td>\s<td>\w+</td>\s<td>\w+</td>',line)
      if out:
        nameList.append(out.group())

    for raw in nameList:
      data = re.findall('\w+',raw)
      print("{:6} | {:8} | {} ".format(data[1], data[4], data[7]))

def main():
  getNames(sys.argv[1])

if __name__ == '__main__':
  main()
