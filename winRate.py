import json
import csv

def calculate_percentage(numerator, denominator):
    if denominator == 0:
        return 0
    else:
        return (numerator / denominator) * 100

def show_column_percentages(data):
    sorted_data = []

    for package, columns in data.items():
        for column, values in columns.items():
            numerator = values[0]
            denominator = values[1]
            percentage = calculate_percentage(numerator, denominator)
            sorted_data.append([package, column, percentage, denominator])

    sorted_data.sort(key=lambda x: x[2], reverse=True)  # Sort by percentage in descending order

    with open('winRate.csv', 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["Package", "Gerenal", "lord主", "loyalist忠", "rebel反", "renegade內", "Percentage", "GameTimes"])

        for row in sorted_data:
            writer.writerow(row)

# Read data from JSON file
with open('save.json') as file:
    json_data = json.load(file)

# Extract data and show column percentages
data = json_data['Record']
show_column_percentages(data)