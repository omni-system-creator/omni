
import sharp from 'sharp';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const assetsDir = path.join(__dirname, 'assets');
const splashSvg = path.join(assetsDir, 'splash.svg');
const splashPng = path.join(assetsDir, 'splash.png');
const logoSvg = path.join(assetsDir, 'logo.svg');
const iconPng = path.join(assetsDir, 'icon.png');

async function convert() {
  try {
    // Convert splash.svg to splash.png
    console.log('Converting splash.svg to splash.png...');
    await sharp(splashSvg)
      .resize(2732, 2732)
      .png()
      .toFile(splashPng);
    console.log('splash.png created successfully.');

    // Convert logo.svg to icon.png
    if (fs.existsSync(logoSvg)) {
      console.log('Converting logo.svg to icon.png...');
      await sharp(logoSvg)
        .resize(1024, 1024)
        .png()
        .toFile(iconPng);
      console.log('icon.png created successfully.');
    }
  } catch (error) {
    console.error('Error converting images:', error);
    process.exit(1);
  }
}

convert();
