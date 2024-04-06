import json
import csv

def calculate_percentage(numerator, denominator):
    if denominator == 0:
        return 0
    else:
        return (numerator / denominator) * 100

def show_column_percentages(data):
    sorted_data = []
    lord_winRate = 0
    loyalist_winRate = 0
    rebel_winRate = 0
    renegade_winRate = 0
    total_game = 0
    max_winRate = [[0,0], [0,0], [0,0], [0,0]]
    max_lord = ""
    max_loyalist = ""
    max_rebel = ""
    max_renegade = ""
    max_win_rate = {}  # Dictionary to store the maximum win rates and columns
    
    for package, columns in data.items():
        for column, values in columns.items():
            numerator = values[0]
            denominator = values[1]
            lord_winRate = lord_winRate + values[2]
            loyalist_winRate = loyalist_winRate + values[3]
            rebel_winRate = rebel_winRate + values[4]
            renegade_winRate = renegade_winRate + values[5]
            total_game = total_game + values[2] + values[3] + values[4] + values[5]
            percentage = calculate_percentage(numerator, denominator)
            
            if calculate_percentage(values[2], denominator) > max_winRate[0][1] and values[2] > max_winRate[0][0]:
                max_winRate[0][1] = calculate_percentage(values[2], denominator)
                max_winRate[0][0] = values[2]
                max_lord = column
            if calculate_percentage(values[3], denominator) > max_winRate[1][1] and values[3] > max_winRate[1][0]:
                max_winRate[1][1] = calculate_percentage(values[3], denominator)
                max_winRate[1][0] = values[3]
                max_loyalist = column
            if calculate_percentage(values[4], denominator) > max_winRate[2][1] and values[4] > max_winRate[2][0]:
                max_winRate[2][1] = calculate_percentage(values[4], denominator)
                max_winRate[2][0] = values[4]
                max_rebel = column
            if calculate_percentage(values[5], denominator) > max_winRate[3][1] and values[5] > max_winRate[3][0] :
                max_winRate[3][1] = calculate_percentage(values[5], denominator)
                max_winRate[3][0] = values[5]
                max_renegade = column
            
            sorted_data.append([package, column, values[2],values[3],values[4],values[5],percentage, denominator,values[6]])

    sorted_data.sort(key=lambda x: x[6], reverse=True)  # Sort by percentage in descending order
    
    with open('winRate.csv', 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["WinRate of Role", "lord/loyalist/rebel/renegade/totalGames", calculate_percentage(lord_winRate, total_game), calculate_percentage(loyalist_winRate, total_game), calculate_percentage(rebel_winRate, total_game), calculate_percentage(renegade_winRate, total_game),  total_game])
        writer.writerow("")
        writer.writerow(max_winRate)
        writer.writerow([max_lord, max_loyalist, max_rebel, max_renegade])
        
        
        writer.writerow(["Package", "Gerenal", "lord主", "loyalist忠", "rebel反", "renegade內", "Percentage", "GameTimes", "MVP"])

        for row in sorted_data:
            writer.writerow(row)
        

# Read data from JSON file
with open('save.json') as file:
    json_data = json.load(file)

# Extract data and show column percentages
data = json_data['Record']
show_column_percentages(data)