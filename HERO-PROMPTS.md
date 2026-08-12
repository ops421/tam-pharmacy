# TAM Pharmacy Hero Animation Prompt Pack
**Concept A: "Amber Vial" (macro)**

Palette locked to the TAM Global system: near-black `#050505`, warm off-white
`#f5f1e8`, gold `#c9a04a`, bright gold `#f1d48a`.

Pipeline: Nano Banana Pro generates the **first frame only** (free), Kling
animates it (~$0.56 for 5s at O3 Pro). Output resolution follows the input
image, so the still must be generated/resized to **1920x1080** for 1080p.

---

## 1. Still image prompt: Nano Banana Pro (first frame)

> Extreme macro photograph of a single amber pharmaceutical glass vial standing
> upright, positioned slightly right of centre on a black polished stone surface
> that fades into pure darkness. The vial is filled two-thirds with a clear
> golden-amber liquid; the meniscus catches a bright specular highlight. A
> single warm gold key light rakes in from the upper left at a low angle,
> refracting through the curved glass and throwing a thin caustic of light
> across the stone. A crimped aluminium seal on top reads as brushed metal with
> a soft cool rim-highlight. Two more vials sit far behind, completely out of
> focus, reduced to soft amber orbs of bokeh. Fine dust motes hang in the air,
> lit by the key. Shot on a 100mm macro lens at f/2.8. The near edge of the
> glass is razor sharp, the label surface falls away into softness. Deep
> shadows, rich blacks, no background clutter, no white background, no text, no
> logo. Cinematic pharmaceutical still life, colour graded warm gold against
> near-black, subtle film grain. Aspect ratio 16:9, 1920x1080.

**Negative prompt:**
> white background, studio seamless, bright lighting, flat lighting, clinical
> blue tint, text, watermark, logo, label typography, hands, people, clutter,
> plastic look, oversaturated, HDR, cartoon, illustration, low detail

---

## 2. Motion prompt: Kling O3 Pro (image-to-video)

> Slow cinematic dolly-in toward the amber vial over five seconds, camera
> drifting a few degrees to the right as it advances, so the gold caustic on the
> stone sweeps slowly across frame. The liquid inside settles with a barely
> perceptible sway, the meniscus highlight travelling along the glass as the
> angle changes. Dust motes drift lazily through the key light. Background bokeh
> orbs shift gently apart with the parallax. Locked, weighted, deliberate
> movement. No shake, no snap, no cuts. Shallow depth of field held throughout.

**Negative prompt:**
> fast motion, camera shake, handheld, zoom snap, cuts, scene change, morphing,
> warping glass, liquid splashing, spilling, hands entering frame, text
> appearing, flickering, strobing

**Params:** `duration: 5`, `cfg_scale: 0.7`, `sound: false`, `shot_type: "customize"`

---

## 3. Why this reads correctly for TAM Pharmacy

- **Amber glass** is the single most legible visual shorthand for compounding.
  It says "prepared here", not "shipped from a warehouse".
- The **gold key light** is the literal brand accent (`#c9a04a`) used as the
  physical light source, so the hero and the UI share one colour logic rather
  than merely coordinating.
- **Near-black falloff** matches `--bg: #050505` exactly, so the canvas edge
  dissolves into the page with no visible seam and no vignette, which the
  builder's hard rules forbid anyway.
- The slow dolly gives a **monotonic depth cue**, so scroll-scrubbing forward
  and backward both feel intentional. Rotational or oscillating motion reads as
  broken when scrubbed in reverse.

---

## 4. Commands

```bash
cd ~/liquid-web/toolkits/cinematic-sites-agent-kit

npm run hero:generate -- \
  --business-name "TAM Pharmacy" \
  --business-type "compounding and specialty pharmacy" \
  --visual-mode cinematic \
  --prompt "<still image prompt above>" \
  --concepts 3
```

Then extract frames into the site (the site renders **frames on canvas**, never
the MP4, because browsers can only seek MP4 keyframes, which stutters):

```bash
cd ~/liquid-web/sites/tam-pharmacy
scripts/extract-frames.sh assets/hero-loop.mp4 24
```

That writes the JPEG sequence **and** `assets/frames/manifest.json`, which
`site.js` reads for the frame count. Nothing in the HTML needs editing.

**Cost:** image free, video ~$0.56, deployment free. Total ≈ $0.56.
