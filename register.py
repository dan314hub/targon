import pexpect
import time
import sys
import subprocess  # Ensure this is imported for start_m2m_miner function

# Define your password and other constants here
PASSWORD = ""
REGISTER_COMMAND = "btcli subnet register --netuid 4 --subtensor.network finney --wallet.name miner --wallet.hotkey miner_hotkey0"
MINER_START_COMMAND = 'pm2 start miner'
INSUFFICIENT_BALANCE_MESSAGE = "Insufficient balance"
SUCCESS_MESSAGE = "✅"  # Adjusted to check for the check mark as success indication
FAILED_MESSAGE = "❌ Failed:"

def register():
    while True:
        print("Starting registration process...")
        child = pexpect.spawn(REGISTER_COMMAND, encoding='utf-8')
        child.logfile = sys.stdout

        # Step 1 is implicit in spawning the command

        # Step 2: Wait 2 seconds then press enter
        time.sleep(2)
        child.sendline('')  # Simulate pressing Enter

        # Check for insufficient balance before proceeding
        index = child.expect([INSUFFICIENT_BALANCE_MESSAGE, pexpect.TIMEOUT, pexpect.EOF], timeout=10)
        if index == 0:
            print("Insufficient balance detected. Restarting script in 4 seconds...")
            time.sleep(4)
            continue  # Restart the registration process
        
        # Step 3: Wait 2 seconds press y
        time.sleep(7)
        child.sendline('y')
        time.sleep(1)

        # Step 4: Wait 3 seconds enter password (1 more second delay as requested)
        time.sleep(13)
        child.sendline(PASSWORD)

        # Step 5: Wait 4 seconds press y (2 more second delay for the y after password as requested)
        time.sleep(7)
        child.sendline('y')

        # Step 6: Wait for either Failed or Success
        index = child.expect([FAILED_MESSAGE, SUCCESS_MESSAGE, pexpect.TIMEOUT, pexpect.EOF], timeout=90)
        if index == 1:
            print("Registration successful!")
            break  # Exit the loop to proceed to miner start
        else:
            print("Registration failed. Restarting...")
            time.sleep(13)
            continue  # Restart the registration process

def start_m2m_miner():
    print("Starting m2m_miner...")
    subprocess.run(MINER_START_COMMAND, shell=True)

def main():
    register()
    start_m2m_miner()

if __name__ == "__main__":
    main()