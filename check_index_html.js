const fs = require('fs');

try {
  const indexPath = 'build/web/index.html';
  const indexContent = fs.readFileSync(indexPath, 'utf8');
  console.log('Index HTML content:');
  console.log(indexContent);
} catch (error) {
  console.error('Error reading index.html:', error.message);
}
