#!/usr/bin/python3
# Open the file in read mode 
with open("alice30.txt", "r") as file:
	
	# Create an empty dictionary 
	d = dict() 
	
	# Loop through each line of the file 
	for line in file: 
		# Remove the leading spaces and newline character 
		line = line.strip() 
		line = line.lower() 
	
		# Split the line into words 
		words = line.split(" ") 
	
		# Iterate over each word in line 
		for word in words:
			if len(word) == 0:
				continue
			# Check if the word is already in dictionary 
			if word in d: 
				# Increment count of word by 1 
				d[word] += 1
			else: 
				# Add the word to dictionary with count 1 
				d[word] = 1
	
	# Print the top 10 words with most no. of counts 
	flag = 1
	for key in list(sorted(d, key=d.get, reverse=True)): 
		if flag <= 10:
			print("{:6} --> {}".format(key,d[key]))
			#print(key, "-->", d[key])
		else:
			break
		flag += 1

