// flutter-web-server.js - Proper Flutter web server with routing support
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8080;
const WEB_DIR = path.join(__dirname, 'build/web');

// MIME types
const mimeTypes = {
  '.html': 'text/html',
  '.js': 'application/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.wav': 'audio/wav',
  '.mp4': 'video/mp4',
  '.woff': 'application/font-woff',
  '.ttf': 'application/font-ttf',
  '.eot': 'application/vnd.ms-fontobject',
  '.otf': 'application/font-otf',
  '.wasm': 'application/wasm'
};

const server = http.createServer((req, res) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);

  // Handle CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // Parse URL
  let filePath = req.url;
  
  // Remove query parameters
  if (filePath.includes('?')) {
    filePath = filePath.split('?')[0];
  }

  // Handle Flutter client-side routing
  // For any route that doesn't match a file, serve index.html
  if (filePath === '/') {
    filePath = '/index.html';
  } else if (!filePath.includes('.')) {
    // This is a route like /login/customer, /login/staff, etc.
    // Serve index.html to let Flutter handle the routing
    filePath = '/index.html';
  }

  // Construct full file path
  const fullPath = path.join(WEB_DIR, filePath);

  // Get file extension for MIME type
  const ext = path.extname(filePath).toLowerCase();
  const mimeType = mimeTypes[ext] || 'application/octet-stream';

  // Check if file exists
  fs.access(fullPath, fs.constants.F_OK, (err) => {
    if (err) {
      // File not found, try serving index.html for client-side routing
      const indexPath = path.join(WEB_DIR, 'index.html');
      fs.access(indexPath, fs.constants.F_OK, (indexErr) => {
        if (indexErr) {
          // Index file also not found
          console.error(`File not found: ${fullPath}`);
          res.writeHead(404, { 'Content-Type': 'text/plain' });
          res.end('404 Not Found');
        } else {
          // Serve index.html for client-side routing
          fs.readFile(indexPath, (err, content) => {
            if (err) {
              console.error(`Error reading index.html: ${err}`);
              res.writeHead(500, { 'Content-Type': 'text/plain' });
              res.end('500 Internal Server Error');
            } else {
              res.writeHead(200, { 'Content-Type': 'text/html' });
              res.end(content);
              console.log(`Served index.html for route: ${req.url}`);
            }
          });
        }
      });
    } else {
      // File exists, serve it
      fs.readFile(fullPath, (err, content) => {
        if (err) {
          console.error(`Error reading file: ${err}`);
          res.writeHead(500, { 'Content-Type': 'text/plain' });
          res.end('500 Internal Server Error');
        } else {
          res.writeHead(200, { 'Content-Type': mimeType });
          res.end(content);
          console.log(`Served file: ${filePath}`);
        }
      });
    }
  });
});

server.listen(PORT, () => {
  console.log(`🚀 Flutter Web Server started at http://localhost:${PORT}`);
  console.log(`📁 Serving files from: ${WEB_DIR}`);
  console.log('');
  console.log('🔗 Available routes:');
  console.log('   http://localhost:8080/ - Main login chooser');
  console.log('   http://localhost:8080/login/customer - Customer login');
  console.log('   http://localhost:8080/login/staff - Staff login');
  console.log('   http://localhost:8080/login/admin - Admin login');
  console.log('');
  console.log('🎯 This server properly handles Flutter client-side routing!');
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('\n🛑 SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('✅ Server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('\n🛑 SIGINT received, shutting down gracefully');
  server.close(() => {
    console.log('✅ Server closed');
    process.exit(0);
  });
});
