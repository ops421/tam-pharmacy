# TAM Pharmacy Hero Animation Prompt Pack
**Concept: "Wireframe Capsule"**

Matched to the TAM Global hero, which was pulled apart frame by frame from
`tam.global/assets/tam-globe-video-web.mp4` rather than guessed at.

## What the parent site actually does

Their hero is a **3D render, not a photograph**:

| Element | TAM Global | Ours |
|---|---|---|
| Subject | one object, dead centre, floating | same |
| Material | glossy black sphere, raised gold continents | pure gold wireframe capsule |
| Background | flat near-black void, no environment | same |
| Floor | dark polished surface, faint gold reflection smear | same |
| Atmosphere | thin light streaks and specks drifting past camera | same |
| Colour | gold is the only chroma against near-black | same |
| Motion | slow dolly-in plus slow rotation, 5s at 24fps | same |
| Framing | wide empty margins, object occupies the middle third | same |

Palette: near-black `#050505`, gold `#c9a04a`, bright gold `#f1d48a`.

Generate the still at **1920x1080**. WaveSpeed has no resolution parameter, so
the video inherits the dimensions of the image you feed it.

---

## 1. Still image prompt (first frame)

> A single pharmaceutical capsule rendered entirely as a glowing gold wireframe,
> floating in the exact centre of an empty black void. The capsule is a classic
> two-piece elongated capsule lying almost horizontally, tilted roughly fifteen
> degrees, seen at a slight three-quarter angle. It is built only from luminous
> gold lines: a dense series of longitudinal contour lines running the length of
> the form, evenly spaced circular cross-section rings around its girth, and a
> brighter double ring at the seam where the cap overlaps the body. Small bright
> nodes glow where the lines intersect. There are no solid surfaces and no fill
> of any kind. The black background is fully visible through the mesh. The lines
> are thin, precise and technical, warm gold in the depth of the form and
> brighter pale gold where they catch the light, with a soft bloom around the
> brightest edges. Beneath the capsule is a dark polished floor that reflects it
> as a faint, soft, elongated gold smear. Fine dust specks and a few thin
> horizontal light streaks drift through the empty space around it. Pure black
> background, deep shadow, no environment, no props, no surface texture, no
> text, no logo, no labels. Cinematic 3D render, minimal, luxurious, futuristic,
> very high contrast gold on near-black. Centred composition with wide empty
> margins, the capsule occupying only the middle third of the frame. Aspect
> ratio 16:9, 1920x1080.

**Negative prompt:**
> solid surfaces, filled shading, opaque capsule, plastic, gelatin, glossy
> plastic pill, photographic product shot, macro photography, white background,
> grey background, blue tint, cyan, neon pink, rainbow colours, text, watermark,
> logo, branding, letters, numbers, scattered pills, multiple capsules, hands,
> people, table, laboratory, clutter, busy background, low contrast, flat
> lighting, cartoon, illustration, sketch

---

## 2. Motion prompt (image-to-video)

> The capsule rotates slowly and steadily around its long axis while the camera
> makes one slow continuous dolly-in toward it over five seconds. As it turns,
> the longitudinal gold lines sweep around the form and the cross-section rings
> catch the light one after another, so the brightest highlight travels along
> the mesh. The seam rings glint as they pass through the light. Fine specks and
> thin light streaks drift steadily past the camera from back to front,
> reinforcing the forward movement. The reflection on the floor below stretches
> and brightens slightly as the capsule draws nearer. Locked, weighted,
> deliberate motion throughout. No shake, no cuts, no speed changes.

**Negative prompt:**
> camera shake, handheld, fast motion, zoom snap, whip pan, cuts, scene change,
> morphing, the capsule opening, capsule splitting apart, powder spilling, lines
> dissolving, mesh breaking up, flickering, strobing, text appearing, logo
> appearing, colour shift, background lightening

**Params:** `duration: 5`, `cfg_scale: 0.7`, `sound: false`, `shot_type: "customize"`

---

## 3. Why this staging works

- **Same slot, different subject.** The parent puts one gold-on-black object in
  the centre of a void over a reflective floor. Keeping that staging and
  swapping the globe for a capsule makes the two sites read as siblings without
  copying the globe itself, which belongs to TAM Global.
- **Wireframe beats a photo here.** A photographic vial competes with the page:
  it brings its own light, its own colour temperature, its own texture. Pure
  linework has none of that, so the hero and the UI share one visual language.
- **Near-black falloff** matches `--bg: #050505`, so the canvas edge dissolves
  into the page with no seam and no vignette.
- **A slow dolly-in is a monotonic depth cue**, so scrubbing forward and
  backward both feel intentional. Anything that oscillates looks broken in
  reverse, which matters because this hero is driven by scroll position.
- **Wide empty margins are deliberate.** The headline sits over the lower left
  of the frame, so the subject must stay small and centred or the two fight.

---

## 4. Getting it onto the site

Generate the video in WaveSpeed, download the MP4 to
`~/liquid-web/sites/tam-pharmacy/assets/hero-loop.mp4`, then:

```bash
cd ~/liquid-web/sites/tam-pharmacy
scripts/extract-frames.sh assets/hero-loop.mp4 24
```

That writes the JPEG sequence **and** `assets/frames/manifest.json`, which
`site.js` reads for the frame count. Nothing in the HTML needs editing.

Preview before pushing:

```bash
python3 -m http.server 8799   # then http://127.0.0.1:8799/index.html
```

**Cost:** image free, video roughly $0.56 at Kling O3 Pro, deployment free.
