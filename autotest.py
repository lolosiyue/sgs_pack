import subprocess
import pyautogui
import time
import keyboard as kb
from pynput.keyboard import Controller 
import pygetwindow as gw

game_path = "QSanguosha.exe"
batch_file_path = "startclient.bat"
choose_general = "newmspgodzhenji"

num_test_runs = 10

keyboard = Controller()

# Sleep duration between actions (adjust as needed)
action_delay = 2000

def bring_window_to_front(window_title):
    window = gw.getWindowsWithTitle(window_title)
    if len(window) > 0:
        window[0].activate()
        window[0].maximize()  # Optional: maximize the window
    else:
        print("Window not found.")


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
        'path': 'autotest/client1.png',
        'action': 'Click on image 1'
    },
    'image2': {
        'path': 'autotest/client2.png',
        'action': 'Click on image 2'
    },
    # Add more target images as needed
}
target_images3 = {
    'image1': {
        'path': 'autotest/choose.png',
        'action': 'Click on image 1'
    },
    'image2': {
        'path': 'autotest/confirm.png',
        'action': 'Click on image 1'
    }
}
target_images5 = {
    'image1': {
        'path': 'autotest/ai.png',
        'action': 'Click on image 1'
    },
}

# Define the image that indicates the end of the game
end_game_image_path = 'autotest/end.png'

for run in range(num_test_runs):
    # Launch the game
    game_process = subprocess.Popen(game_path)

    # Wait for the game to initialize
    time.sleep(2)  # Adjust as needed

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

    # Simulate typing the batch file command
    vscode_title = "Visual Studio Code"
    bring_window_to_front(vscode_title)
    
    subprocess.Popen(batch_file_path, creationflags=subprocess.CREATE_NEW_CONSOLE)

    time.sleep(2)  # Adjust as needed
   # Simulate keyboard input of '1'
    keyboard.press('1')
    keyboard.release('1')
    time.sleep(4)  # Adjust as needed

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
            time.sleep(2)
    time.sleep(5)
    for image_name, image_data in target_images3.items():
        image_path = image_data['path']
        image_action = image_data['action']

        # Find all occurrences of the target image on the screen
        target_occurrences = pyautogui.locateAllOnScreen(image_path)

        # Iterate over each occurrence and perform a mouse click
        for target_occurrence in target_occurrences:
            # Get the center coordinates of the target occurrence
            x, y, width, height = target_occurrence
            target_x = x - 100
            target_y = y + height // 2

            # Perform a mouse click on the center of the target occurrence
            pyautogui.click(target_x, target_y)
            time.sleep(2)
            kb.write(choose_general)
            time.sleep(2)
            pyautogui.click(target_x + 100 + width // 2, target_y)
            time.sleep(2)
    time.sleep(1)
    for image_name, image_data in target_images3.items():
        image_path = image_data['path']
        image_action = image_data['action']

        # Find all occurrences of the target image on the screen
        target_occurrences = pyautogui.locateAllOnScreen(image_path)

        # Iterate over each occurrence and perform a mouse click
        for target_occurrence in target_occurrences:
            # Get the center coordinates of the target occurrence
            x, y, width, height = target_occurrence
            target_x = x - 100
            target_y = y + height // 2

            # Perform a mouse click on the center of the target occurrence
            pyautogui.click(target_x, target_y)
            time.sleep(2)
            kb.write("☆赵云")
            time.sleep(2)
            pyautogui.click(target_x + 100 + width // 2, target_y)
            time.sleep(2)

    time.sleep(2)
    for image_name, image_data in target_images5.items():
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
    
    while True:
        # Check if the game has finished
        end_game_location = pyautogui.locateOnScreen(end_game_image_path)
        if end_game_location is not None:
            print(f"Test run {run+1} completed.")
            time.sleep(2)
            # Ask the user to press any key to continue or '0' to exit
            user_input = input("Press any key to continue or '0' to exit: ")
            cmd_title = "CMD"
            bring_window_to_front(cmd_title)
            keyboard.press('2')
            keyboard.release('2')
            time.sleep(1)
            keyboard.press('3')
            keyboard.release('3')
            if user_input == '0':
                break
            break
    if user_input == '0':
                break
    time.sleep(2)      
    # ...

    # Terminate the game process
    #game_process.terminate()

    
    

print("All test runs completed.")