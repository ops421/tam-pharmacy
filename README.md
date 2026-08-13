# TAM Pharmacy website

Single-page lander plus three policy pages for **TAM Pharmacy**, the compounding
and specialty pharmacy of the TAM Global medical ecosystem.

Built with the Liquid Web `cinematic-sites` builder. Static HTML/CSS/JS. No
build step, no framework, no npm install to deploy.

---

## Status

**Draft, not ready to publish.** The site carries `[[PLACEHOLDER]]` tokens for
business facts that must be verified rather than guessed (licensure, states
served, hours, metrics, carriers). Run the gate before deploying:

```bash
scripts/check-placeholders.sh
```

It exits non-zero and lists every unfilled token. See "Placeholders" below.

---

## Structure

```
index.html                     lander
privacy-policy.html            \
return-and-refund-policy.html   >  policy pages
shipping-policy.html           /
assets/
  site.css                     shared design system (all four pages)
  site.js                      hero scrub, nav, marquee, tilt, counters
  favicon.svg                  gold TAM mark on near-black
  logo/tam-pharmacy.svg        vector wordmark, currentColor-driven
  frames/                      hero JPEG sequence + manifest.json (generated)
scripts/
  extract-frames.sh            video -> frames + manifest
  check-placeholders.sh        pre-publish gate
HERO-PROMPTS.md                WaveSpeed / Nano Banana prompt pack
```

## Design system

Tokens are lifted from the live TAM Global stylesheet
(`tam.global/assets/site.css`) so the two sites are genuine siblings:

| Token | Value | Use |
|---|---|---|
| `--bg` | `#050505` | page ground |
| `--text` | `#f5f1e8` | warm off-white |
| `--body` | `rgba(245,241,232,0.82)` | paragraph text |
| `--muted` | `rgba(245,241,232,0.68)` | captions only |
| `--gold` | `#c9a04a` | accent |
| `--gold-bright` | `#f1d48a` | eyebrows, emphasis |

Type: **Cormorant Garamond** for display, **Inter** for UI/body, **JetBrains
Mono** for step indices. Film-grain overlay at 2.5% opacity, matching the parent.

## Hero

The hero is a **scroll-scrubbed JPEG frame sequence drawn on `<canvas>`**, not
a `<video>`. Browsers can only seek to keyframes in a compressed MP4, so
`video.currentTime` scrubbing stutters visibly.

Generate the art (see `HERO-PROMPTS.md`), then:

```bash
scripts/extract-frames.sh                      # defaults: 12fps, WebP q75, 1280px
scripts/extract-frames.sh assets/hero-loop.mp4 16 80 1280   # smoother, heavier
```

That writes `assets/frames/frame-NNNN.webp` plus a `manifest.json` holding the
frame count **and the extension**. `site.js` reads both, so there is nothing to
hand-edit when the encoding changes. If the manifest is missing, the hero falls
back to the poster image and the page still works.

### Weight

Visitors download the whole sequence, so it is the single biggest thing on the
page. Current settings put it at **3.3MB / 61 frames**, down from 9.6MB / 121
JPEG frames.

| Lever | Effect |
|---|---|
| `fps` | Scales payload linearly. This is the main dial. |
| WebP vs JPEG | Roughly 65% lighter on this footage. |
| `quality` | Diminishing returns; the canvas is dimmed to 58% opacity anyway. |
| `width` | Last resort. The canvas cover-fits, so this softens the image. |

Frames load in three passes so the page never waits on the hero: frame 1 first
(the loader lifts as soon as it paints), then every 5th frame for coarse
scrubbing, then the remainder at low priority. `drawFrame` falls back to the
nearest loaded frame, so a half-loaded sequence scrubs at reduced resolution
instead of freezing.

## Local preview

```bash
python3 -m http.server 8799
# http://127.0.0.1:8799/index.html
```

Use a server, not `file://`; the manifest is loaded with `fetch()`.

## Publishing

```bash
scripts/check-placeholders.sh && \
  ~/liquid-web/scripts/publish-site.sh tam-pharmacy ops421/tam-pharmacy
```

`.nojekyll` is present so GitHub Pages serves `assets/` unmodified.

## Placeholders

| Token | What's needed |
|---|---|
| `[[METRIC_1..4_VALUE]]` / `[[..._LABEL]]` | Four headline numbers and their labels |
| `[[STATES_SERVED]]` | States where the pharmacy holds licensure |
| `[[LICENSE_NUMBER]]` | Tennessee pharmacy license number |
| `[[CONFIRM: USP <797>]]` / `[[CONFIRM: USP <795>]]` | Confirm before asserting compliance |
| `[[CONFIRM: scope & claims]]` | Metabolic/weight-management scope and permitted claims |
| `[[HOURS_WEEKDAY/SATURDAY/SUNDAY]]` | Opening hours |
| `[[CARRIERS]]`, `[[STANDARD_TRANSIT]]`, `[[EXPEDITED_TRANSIT]]` | Shipping carriers and transit times |
| `[[REFUND_PROCESSING_DAYS]]` | Refund processing window |
| `[[EFFECTIVE_DATE]]`, `[[LAST_UPDATED]]` | Policy dates |

The policy pages were drafted using cadre-labs.com's policies as a structural
reference and rewritten for a compounding pharmacy. **They have not been
reviewed by counsel.** Treat them as a solid first draft, not as legal advice.

## Contact used throughout

525 Metroplex Dr, Nashville, TN 37211 · 888-423-5988 · contact@tampharmacy.com
