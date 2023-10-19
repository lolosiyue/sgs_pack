import json
import csv

# Read the JSON file
with open('save.json') as file:
    data = json.load(file)

# Get the data dictionary from the JSON
data_dict = data['Record']

# Calculate the percentage for each column
column_percentages = []
for column, values in data_dict.items():
    numerator, denominator = values
    if denominator != 0:
        percentage = (numerator / denominator) * 100
        column_percentages.append([column, f'{percentage:.2f}%', denominator])
    else:
        column_percentages.append([column, 'not play yet', denominator])

# Sort the rows by the percentage column in descending order
sorted_rows = sorted(column_percentages, key=lambda x: float('-inf') if x[1] == 'not play yet' else float(x[1][:-1]), reverse=True)

# Write the results to a CSV file
with open('output.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['Gerenal', 'WinRate', 'GameTimes'])
    writer.writerows(sorted_rows)

print("Output saved to output.csv file.")