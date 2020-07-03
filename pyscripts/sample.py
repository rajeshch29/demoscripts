#!/usr/bin/python3
"""
This program will cover all python basic topics
"""



def printf():
    name = 'Rajesh'
    number = 9
    print("Name is %s and number is %d" % (name,number))
    print("Used", "concatinated", "operator")

def checkright():
    age = int(input("Enter your age:"))
    if age < 18:
        print("You are minor")
    else:
        print("You are major")

def stars():
    i = 1
    while (i < 10):
        j = 1
        while (j <= i):
            print('*', end='')
            j += 1
        print()
        i += 1

stars()
checkright()
    