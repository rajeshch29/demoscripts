#!/bin/bash
str="Hyderabad,Bangalore,Delhi,Mumbai,Chennai"

IFS=',' read -ra ADDR <<< "$str"
for city in "${ADDR[@]}"; do
echo "City is $city"
done
