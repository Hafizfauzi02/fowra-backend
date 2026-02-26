# How to Start the Fowra Backend Server

If you have downloaded the Fowra `.apk` system to another phone, the phone needs to connect to the backend server to function. **If the server is not hosted on the cloud (like Render or Vercel), it must be running on your local computer, and both your computer and the phone must be on the exact same Wi-Fi network.**

Here are the step-by-step instructions to start the backend server on your computer:

### Step 1: Connect to the Same Network
Ensure your computer (hosting the backend) and the Android phone (running the APK) are connected to the **same Wi-Fi network**.

### Step 2: Find Your Computer's IP Address
The Android app is currently configured to look for the server at `10.18.144.8`.
1. Open your Mac's **System Settings**.
2. Click on **Network** or **Wi-Fi**.
3. Look for your connected network's details. You should see an IP Address.
4. If your new IP address is different from `10.18.144.8`, you must change it in the Flutter app code (e.g., inside `lib/services/auth_service.dart`) and rebuild the APK.

### Step 3: Start MySQL Database
Ensure your MySQL database server is running on your Mac. If you are using an app like XAMPP, MAMP, or DBngin, open it and click "Start" for the MySQL service. Wait until the status says running on Port 3306.

### Step 4: Open the Terminal
Open the `Terminal` application on your Mac.

### Step 5: Navigate to the Backend Folder
Use the `cd` (change directory) command to go into the folder where your backend code is located.
```bash
cd /Users/hafizfauzi/development/fowra/backend
```

### Step 6: Start the Server
Run the Node.js server using the following command:
```bash
node index.js
```
*Alternatively, if you use `npm`, you might also be able to run `npm start` (if it's defined in your `package.json`).*

### Step 7: Verify it's Running
If successful, you will see a message like this in the terminal:
```
Server running at http://localhost:3000
```
**Leave this terminal window open!** If you close it, the server stops.

### Step 8: Test the App
You can now open the app on your Android phone and try to log in or use its features. It should connect successfully to the backend!
