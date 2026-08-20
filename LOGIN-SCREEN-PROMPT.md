# TAM Pharmacy Login Screen Wallpaper
**2560 x 1440, gold on near-black, logo centred**

## Read this first

**Generate the background only. No text, no logo, no lettering of any kind.**

Image models cannot render a wordmark reliably. Ask one for "the TAM Pharmacy
logo" and you get a warped approximation with a bent M or a missing serif, which
is worse than useless as branding. The logo goes on afterwards, composited from
`assets/logo/tam-pharmacy.svg`, which is true vector and stays razor sharp at
any size.

Workflow:

1. Generate the plate with the prompt below
2. Save it to `~/Downloads/`
3. Run `scripts/make-login-image.sh <plate>` to composite the logo and export
   the finished 2560 x 1440 PNG

Palette, matched to the site: near-black `#050505`, gold `#c9a04a`, bright gold
`#f1d48a`, warm off-white `#f5f1e8`.

---

## 1. The prompt

> A cinematic still life in a darkened apothecary, lit almost entirely by warm
> gold light. Across the lower third of the frame, a low arrangement of amber
> pharmaceutical glassware: a tall beaker holding a clear golden liquid slightly
> left of centre, a stoppered vial and a shallow dish beside it, and the soft
> curve of further vessels behind, already dissolving out of focus. A warm gold
> key light rakes in low from the left, refracting through the curved glass and
> throwing thin caustics of light across a dark polished surface. Fine motes of
> dust drift through the beam. Above the glassware the frame opens into deep,
> still, near-black space, empty except for a scattering of small out-of-focus
> gold highlights drifting far in the background, soft and unhurried. Rich
> blacks, no grey haze, no visible horizon line. Shot on an 85mm lens at f/2,
> shallow depth of field, the near edge of the glass sharp and everything behind
> it falling away. Colour graded warm gold against near-black, subtle film
> grain. Absolutely no text, no lettering, no numbers, no labels, no logo, no
> watermark. Wide cinematic composition, the upper half of the frame calm and
> uncluttered. 16:9, 2560 x 1440.

**Negative prompt:**

> text, lettering, words, numbers, labels, logo, watermark, signature, brand
> name, typography, blue tint, cyan, teal, purple, neon, rainbow, white
> background, grey background, bright lighting, flat lighting, studio seamless,
> clutter, busy composition, people, hands, faces, cartoon, illustration, low
> contrast, oversaturated, HDR, tilted horizon

---

## 2. Why the detail sits low

The wordmark lands in the **upper middle** of the frame, so everything above the
glassware has to stay quiet. Detail behind a logo does two bad things: it eats
the counters of the letterforms, and it forces a drop shadow heavy enough to
look cheap.

Keeping the interest in the bottom third also matches how the site hero behaves,
where the headline sits over the darkest part of the frame rather than over the
lit glass.

The gold bokeh in the upper background is deliberate. It stops the empty half
reading as a flat black rectangle without introducing anything the eye has to
resolve.

---

## 3. Logo placement, applied automatically

`scripts/make-login-image.sh` composites the wordmark at:

- **Width:** 620px, about 24% of the frame
- **Position:** horizontally centred, baseline at 42% of frame height, which
  puts it in the calm zone above the glassware
- **Colour:** warm off-white `#f5f1e8`
- **Treatment:** a soft dark halo behind it, wide and low opacity, so the mark
  stays legible if the plate came out brighter than expected

All four are flags on the script, so any of them can be changed in one run
without regenerating the plate.

---

## 4. Generating

Most models will not emit 2560 x 1440 directly. Generate at the largest 16:9
size offered, commonly 1920 x 1080 or 2048 x 1152, and let the script upscale.
This particular image upscales cleanly because it is mostly soft gradient and
bokeh, with sharp detail confined to one small area.

Do not generate at another aspect ratio and crop to 16:9. Cropping moves the
glassware out of the lower third and puts detail where the logo needs to sit.
