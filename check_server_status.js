// Helper function to check server status with proper string formatting
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

async function checkServerStatus(commandId) {
  try {
    // Ensure commandId is always a string
    const stringCommandId = String(commandId);
    console.log(`Checking server status for Command ID: ${stringCommandId}`);
    
    // Check if Python server is running on port 8092
    const { stdout, stderr } = await execPromise('netstat -ano | findstr :8092');
    
    if (stdout.includes(':8092')) {
      console.log('✅ Python web server is running on port 8092');
      return true;
    } else {
      console.log('❌ Python web server is not running on port 8092');
      return false;
    }
  } catch (error) {
    console.log('❌ Error checking server status:', error.message);
    return false;
  }
}

// Test the function
checkServerStatus(10770).then(isRunning => {
  console.log(`Server is ${isRunning ? 'running' : 'not running'}`);
}).catch(console.error);
