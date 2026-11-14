# Animations

Teaching GIFs that will be attached to cards as material (one folder per animation).
Not bundled into the app yet: when a card starts showing one, copy the GIFs into the
app's resources at that point.

## Layout

```
design/animations/
├── README.md          ← this file
├── render.js          ← page → PNG frames (headless Chrome)
└── <id>/              ← snake_case, named after the topic (e.g. alagille_jag1)
    ├── <id>.html      ← source: time-driven SVG, also a player (Space = pause, ←/→ = ±1 s, theme toggle)
    ├── <id>_light.gif ← for light mode
    └── <id>_dark.gif  ← for dark mode
```

## Format (iPhone card)

- Canvas **360 × 480 pt (3:4 portrait)**, exported **@2x → 720 × 960 px**, 12 fps, infinite loop.
- Two exports per animation: **light** and **dark**. Backgrounds are the `background` token
  (`#FFFFFF` / `#121417`), so the GIF blends into the screen.
- Style strictly per CLAUDE.md §12 "Clinical Editorial": Avenir Next only; colors from §12.2
  (`navy`, `blue`, `ink`, `muted`, `surface`, `rule`, `crit`, `urg`, `ok`, `gap`, `onSolid`).
  Captions are section blocks (`surface`, 4 pt `navy` top stripe) in `hepTakeaway` (Bold Italic).
- No scene titles, counters or legends; label structures right next to them.
- Target ≤ 3 MB per GIF.

## Export

```bash
# once, in any scratch folder
npm i puppeteer-core@22.15.0
pip install imageio-ffmpeg   # provides an ffmpeg binary if Homebrew ffmpeg is absent

# per theme
mkdir -p /tmp/frames_light
NODE_PATH=<scratch>/node_modules node design/animations/render.js \
  design/animations/<id>/<id>.html /tmp/frames_light light
ffmpeg -y -framerate 12 -i /tmp/frames_light/f%04d.png \
  -vf "split[a][b];[a]palettegen=max_colors=160:stats_mode=full[p];[b][p]paletteuse=dither=none:diff_mode=rectangle" \
  -loop 0 design/animations/<id>/<id>_light.gif
```

Repeat with `dark`. Check a few frames of both GIFs before committing.

## Catalog

| id | Topic | Length | Scenes |
|---|---|---|---|
| `alagille_jag1` | JAG1–Notch signaling and Alagille syndrome | 44.5 s | gene & protein · Notch signaling · bile duct development · haploinsufficiency |
| `alagille_pruritus` | How cholestatic itch becomes a nerve signal | 24 s | one stacked frame: nerve ending (MRGPRX4 and LPAR → Gq → PLC → TRPA1/TRPV1) · generator potential and spikes · spinal itch relay (NPPB → GRP → GRPR → lamina I) |
