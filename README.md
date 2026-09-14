# Quarto teaching slides

A plain-text workflow for teaching slides using [Quarto](https://quarto.org) and [Reveal.js](https://revealjs.com). Each `.qmd` source file renders to a single self-contained HTML file that can be presented or read in a browser.

This repository contains the build scripts, theme, slide controls, a template deck, and example outputs.

## Background

The workflow was developed for [DESIGN 240: Designing with Data](https://study.auckland.ac.nz/ords/r/uoa/catalogue/course?p6_code=DESIGN%20240&clear=6), an elective course in the Bachelor of Design programme at the University of Auckland, and was used to produce the slides for every week of the course. No course content is included here.

Plain text source files work naturally with Git, making it straightforward to track changes, revert to earlier versions, and maintain a clear history of the course materials over time.

Students in the course document their work in Markdown and publish via GitHub Pages throughout the semester. Authoring slides in the same ecosystem (plain text, version controlled, rendered to the web) means the teacher's own tools are consistent with what students are using.

The teacher works in Emacs on Linux, using org-mode for notes and task management. A plain text slide workflow fits naturally into this environment.

## Slide outputs

Each weekly `.qmd` source file produces two outputs:

| File | Audience | Speaker notes |
|---|---|---|
| `week-NN-speaker.html` | Teacher | Included |
| `week-NN.html` | Students, uploaded to a learning management system such as Canvas | Stripped |

Both files use `embed-resources: true` so they are fully self-contained (fonts, JS, CSS, and images inlined as base64). They work offline and can be distributed directly.

Speaker notes are stripped from handout outputs using the [speakernotes](https://github.com/pagiraud/speakernotes) Quarto extension, which removes `{.notes}` divs entirely — they are absent from the output, not merely hidden. The extension exists because Quarto otherwise dumps notes into non-slide output, with no way for the reader to tell them apart from the slide content.

In Reveal.js, pressing `S` opens the speaker view (current slide, next slide, notes, timer) in a second browser window.

Native Unicode emoji (e.g. 🎉 🔥) can be typed directly and render in full colour via OS emoji fonts in the font stack. Additional icons are available via the [Font Awesome](https://github.com/quarto-ext/fontawesome) shortcode extension: `{{< fa icon-name >}}` (e.g. `{{< fa brands github >}}`).

## Building slides

Render a single week:
```sh
./build.sh --week 1
```

Render all weeks:
```sh
./build.sh --all
```

The build script resizes images in `assets/images/week-NN/` to fit within 1920×1080 before rendering. Only the directory for the week being built is processed, so adding images to one week does not trigger re-processing of the others. Images here are working copies; originals should be kept elsewhere.

## Development preview

`build.sh` inlines all assets as base64 (`embed-resources: true`), which is correct for distribution but slow when authoring. For a fast edit loop, use `dev.sh` instead:

```sh
./dev.sh --week 1
```

This runs `quarto preview` with the dev profile (`_quarto-dev.yml`), which sets `embed-resources: false`, and serves the deck at `http://localhost:8888/slides/week-01.html` (use `--port` to change the port). Quarto watches the source file and reloads the browser on every save. A `slides/assets` symlink is created automatically and removed on Ctrl+C.

When ready to produce distributable output, run `build.sh` as normal. Dev and built files coexist in `_output` without conflict, so no cleanup is needed when switching between the two workflows.

`preview.sh` serves `_output/` over HTTP (default port 8888), which is useful when building on a remote machine or for PDF export (see below).

## Slide controls (`slide-controls.js`)

`assets/slide-controls.js` is injected into every slide deck. It handles:

- **Logos**: both the black and white logos are embedded as base64 in the script, because an image path swapped in at runtime is not inlined by `embed-resources`. On each slide transition, the script swaps between them: dark slides get the white logo, all other slides get the black logo.
- **Footer colour**: the footer text is dimmed on dark slides and restored to the default colour on light slides.
- **Per-slide visibility**: slide classes control what is shown:
  - `{.no-footer}`: hide footer
  - `{.no-logo}`: hide logo
  - `{.clean-slide}`: hide footer, logo, and slide number
  - `data-hide-slide-number="true"`: hide slide number on a specific slide
  - The slide number is also hidden automatically on the title slide and full-bleed image slides.

## Quarto profiles

- `_quarto.yml`: default speaker profile (includes speaker notes)
- `_quarto-handout.yml`: handout profile (speakernotes filter applied)
- `_quarto-dev.yml`: dev profile (disables `embed-resources` for fast preview)

## Slide templates

`slides/week-00.qmd` is a template deck of the slide layouts used throughout the course: incremental lists, striped tables, dark section dividers, text-and-image columns, full-width and full-bleed images, pull quotes, code, callouts, activities, a consultation schedule, and the per-slide visibility controls listed above. Copy a slide from it to start a new one.

Custom classes defined in `assets/custom.scss`:

- `{.dark-slide}`: dark background variant
- `[text]{.accent}`: accent colour (orange by default)
- `[text]{.mono-highlighted}`: monospace text on a highlighted background, used for weightings and due dates
- `::: {.emoji-list}`: list items with an emoji in place of each bullet

Rendered versions of the template deck (speaker HTML and student HTML) are in `example-outputs/`. The sample images are from Unsplash; see `assets/images/week-00/image-credits.md`.

## Customising

- **Logos**: replace `assets/logo-black.png` and `assets/logo-white.png` (the placeholders are 564×286 and 601×286 pixels), then regenerate the two constants at the top of `assets/slide-controls.js`:
  ```sh
  echo "const blackLogo = 'data:image/png;base64,$(base64 -w0 assets/logo-black.png)';"
  echo "const whiteLogo = 'data:image/png;base64,$(base64 -w0 assets/logo-white.png)';"
  ```
- **Footer**: edit `footer` in `_quarto.yml`.
- **Colours and fonts**: edit the variables at the top of `assets/custom.scss`.

## PDF export

PDFs are exported manually from the student HTML, using either of the following methods.

Quarto's PDF export mode:

1. Open `week-NN.html` in a browser (e.g. Firefox)
2. Use the Quarto menu: **Tools → PDF Export Mode** (or press `E`)
3. Print (Ctrl+P / Cmd+P) with **Print backgrounds** enabled
4. Save as PDF

Reveal.js print mode:

1. Open `week-NN.html?print-pdf` in Chrome or Chromium (via `preview.sh` or a `file://` URL)
2. Print (Ctrl+P / Cmd+P) with **Landscape** layout, **Margins** set to none, and **Background graphics** enabled
3. Save as PDF

Slides with fragments are printed on a single page (`pdf-separate-fragments: false` in the handout profile).

## Directory structure

```
quarto-teaching-slides/
├── _quarto.yml               # default speaker profile
├── _quarto-handout.yml       # handout profile: strips speaker notes
├── _quarto-dev.yml           # dev profile: embed-resources: false
├── _extensions/
│   ├── pagiraud/speakernotes/
│   └── quarto-ext/fontawesome/
├── assets/
│   ├── custom.scss
│   ├── slide-controls.js
│   ├── logo-black.png        # placeholder logo, light slides
│   ├── logo-white.png        # placeholder logo, dark slides
│   └── images/
│       └── week-00/          # working copies; resized in-place by build.sh
├── slides/
│   └── week-00.qmd           # template deck
├── example-outputs/          # rendered from slides/week-00.qmd
├── build.sh
├── dev.sh
├── preview.sh
├── LICENSE
├── README.md
└── _output/                  # gitignored; all rendered files go here
    ├── week-NN-speaker.html
    └── week-NN.html
```

## Dependencies

- [Quarto](https://quarto.org)
- [ImageMagick](https://imagemagick.org) (`mogrify`) for image resizing

Bundled Quarto extensions (already in `_extensions/`, no separate install needed):

- [speakernotes](https://github.com/pagiraud/speakernotes): strips `{.notes}` divs from handout output
- [fontawesome](https://github.com/quarto-ext/fontawesome): Font Awesome icon shortcodes (`{{< fa icon-name >}}`)

## Licence

This repository is released under the MIT Licence (see `LICENSE`). Bundled third-party components keep their own licences: the speakernotes extension is GPL v3 (Pierre-Amiel Giraud), and the Font Awesome extension includes Font Awesome Free (icons CC BY 4.0, fonts SIL OFL 1.1, code MIT). The sample images are used under the [Unsplash Licence](https://unsplash.com/license).
