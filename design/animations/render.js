// Renders an animation page (design/animations/<id>/<id>.html) to PNG frames.
//
//   node design/animations/render.js <page.html> <out-dir> <light|dark> [fps]
//
// The page must expose `window.draw(t)`, `window.ready` (a Promise) and the
// constant `T` (duration in seconds), and accept `?render=1&theme=<light|dark>`.
// Needs `puppeteer-core` (npm i puppeteer-core@22.15.0 in any scratch folder,
// then run with NODE_PATH pointing at its node_modules) and Google Chrome.
// See design/animations/README.md for the full GIF pipeline.
const path = require('path');
const puppeteer = require('puppeteer-core');

const [, , page, out, theme = 'light', fpsArg = '12'] = process.argv;
if (!page || !out) {
  console.error('usage: node render.js <page.html> <out-dir> <light|dark> [fps]');
  process.exit(1);
}
const fps = Number(fpsArg);
const chrome = process.env.CHROME || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

(async () => {
  const browser = await puppeteer.launch({ executablePath: chrome, headless: true, args: ['--force-color-profile=srgb'] });
  const tab = await browser.newPage();
  const errors = [];
  tab.on('pageerror', e => errors.push(e.message));
  // 360x480 pt design canvas, rendered @2x -> 720x960 px.
  await tab.setViewport({ width: 360, height: 480, deviceScaleFactor: 2 });
  await tab.goto('file://' + path.resolve(page) + '?render=1&theme=' + theme, { waitUntil: 'networkidle0' });
  await tab.evaluate(() => window.ready);
  const fontOk = await tab.evaluate(() => document.fonts.check("700 16px 'Avenir Next'"));
  const duration = await tab.evaluate(() => T);
  const n = Math.round(duration * fps);
  for (let i = 0; i < n; i++) {
    await tab.evaluate(t => draw(t), i / fps);
    await tab.screenshot({ path: path.join(out, `f${String(i).padStart(4, '0')}.png`), clip: { x: 0, y: 0, width: 360, height: 480 } });
  }
  await browser.close();
  console.log(`frames=${n} avenirNext=${fontOk} errors=${errors.length ? errors.join(' | ') : 'none'}`);
  if (errors.length || !fontOk) process.exit(2);
})();
