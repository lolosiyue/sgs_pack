import subprocess
import pyautogui
import time
from pynput.keyboard import Controller

game_path = "QSanguosha.exe"
bat_file_path = "startclient.bat"
num_test_runs = 1

keyboard = Controller()

# Sleep duration between actions (adjust as needed)
action_delay = 100


# Define a dictionary of target images and their corresponding actions
target_images = {
    'image1': {
        'path': 'autotest/server1.png',
        'action': 'Click on image 1'
    },
    'image2': {
        'path': 'autotest/server2.png',
        'action': 'Click on image 2'
    },
    # Add more target images as needed
}
target_images2 = {
    'image1': {
        'path': 'path/to/image1.png',
        'action': 'Click on image 1'
    },
    'image2': {
        'path': 'path/to/image2.png',
        'action': 'Click on image 2'
    },
    # Add more target images as needed
}

# Define the image that indicates the end of the game
end_game_image_path = 'path/to/end_game_image.png'

for run in range(num_test_runs):
    # Launch the game
    game_process = subprocess.Popen(game_path)

    # Wait for the game to initialize
    time.sleep(5)  # Adjust as needed

    # Perform AI testing logic
    # ...

    # Iterate over each target image and perform mouse clicks
    for image_name, image_data in target_images.items():
        image_path = image_data['path']
        image_action = image_data['action']

        # Find all occurrences of the target image on the screen
        target_occurrences = pyautogui.locateAllOnScreen(image_path)

        # Iterate over each occurrence and perform a mouse click
        for target_occurrence in target_occurrences:
            # Get the center coordinates of the target occurrence
            x, y, width, height = target_occurrence
            target_x = x + width // 2
            target_y = y + height // 2

            # Perform a mouse click on the center of the target occurrence
            pyautogui.click(target_x, target_y)
            time.sleep(2)  # Adjust as needed

            print(f'{image_action}: {image_name}')

    # Simulate typing the batch file command
    keyboard.type('startclient.bat')
    keyboard.press('\n')
    keyboard.release('\n')
    time.sleep(2)  # Adjust as needed

   # Simulate keyboard input of '1'
    keyboard.press('1')
    keyboard.release('1')

    for image_name, image_data in target_images2.items():
        image_path = image_data['path']
        image_action = image_data['action']

        # Find all occurrences of the target image on the screen
        target_occurrences = pyautogui.locateAllOnScreen(image_path)

        # Iterate over each occurrence and perform a mouse click
        for target_occurrence in target_occurrences:
            # Get the center coordinates of the target occurrence
            x, y, width, height = target_occurrence
            target_x = x + width // 2
            target_y = y + height // 2

            # Perform a mouse click on the center of the target occurrence
            pyautogui.click(target_x, target_y)

            print(f'{image_action}: {image_name}')

    # Wait for the action to complete
    time.sleep(action_delay)

    # Check if the game has finished
    end_game_location = pyautogui.locateOnScreen(end_game_image_path)
    if end_game_location is not None:
        print(f"Test run {run+1} completed.")
        # Ask the user to press any key to continue or '0' to exit
        user_input = input("Press any key to continue or '0' to exit: ")
        keyboard.press('2')
        keyboard.release('2')
        keyboard.press('3')
        keyboard.release('3')
        if user_input == '0':
            break


    # ...

    # Terminate the game process
    #game_process.terminate()

    
    

print("All test runs completed.")