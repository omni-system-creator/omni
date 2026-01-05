import fs from 'fs';
import path from 'path';
import https from 'https';
import { fileURLToPath } from 'url';

// Helper to get __dirname in ESM
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Configuration matching gas.vue
const LOCATION = {
  lat: 45.603,
  lon: 84.886,
  zoom: 16
};
const RANGE = 1; // 3x3 grid

// Web Mercator Helpers
const long2tile = (lon, zoom) => {
  return (Math.floor((lon + 180) / 360 * Math.pow(2, zoom)));
};

const lat2tile = (lat, zoom) => {
  return (Math.floor((1 - Math.log(Math.tan(lat * Math.PI / 180) + 1 / Math.cos(lat * Math.PI / 180)) / Math.PI) / 2 * Math.pow(2, zoom)));
};

const centerX = long2tile(LOCATION.lon, LOCATION.zoom);
const centerY = lat2tile(LOCATION.lat, LOCATION.zoom);

// Ensure directory exists
const outputDir = path.join(__dirname, 'public', 'tiles', LOCATION.zoom.toString());
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

const downloadFile = (url, dest) => {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    https.get(url, (response) => {
      if (response.statusCode !== 200) {
        reject(new Error(`Failed to download: ${response.statusCode}`));
        return;
      }
      response.pipe(file);
      file.on('finish', () => {
        file.close();
        resolve();
      });
    }).on('error', (err) => {
      fs.unlink(dest, () => {});
      reject(err);
    });
  });
};

console.log(`Downloading tiles for center [${centerX}, ${centerY}] at zoom ${LOCATION.zoom}...`);

const downloadAll = async () => {
  for (let dx = -RANGE; dx <= RANGE; dx++) {
    for (let dy = -RANGE; dy <= RANGE; dy++) {
      const x = centerX + dx;
      const y = centerY + dy;
      
      // Create Y directory
      const yDir = path.join(outputDir, y.toString());
      if (!fs.existsSync(yDir)) {
        fs.mkdirSync(yDir, { recursive: true });
      }

      const filename = path.join(yDir, `${x}.jpg`);
      const url = `https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/${LOCATION.zoom}/${y}/${x}`;
      
      console.log(`Downloading ${url} -> ${filename}`);
      try {
        await downloadFile(url, filename);
      } catch (e) {
        console.error(`Error downloading tile ${x},${y}:`, e);
      }
    }
  }
  console.log('All tiles downloaded!');
};

downloadAll();
