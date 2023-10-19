import json

# Read the JSON file
with open('save.json') as file:
    data = json.load(file)

# Get the data dictionary from the JSON
data_dict = data['Record']

# Clear the numerator and denominator values for each column
for column in data_dict:
    data_dict[column] = [0, 0]

# Update the JSON data with cleared values
data['data'] = data_dict

# Write the updated JSON data to a new file
with open('save.json', 'w') as file:
    json.dump(data, file)
