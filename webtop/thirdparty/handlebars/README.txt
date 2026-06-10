Handlebars.js v4.7.9 — pre-built minified UMD
====================================================

Source: https://registry.npmjs.org/handlebars/-/handlebars-4.7.9.tgz
        (file: package/dist/handlebars.min.js)
Downloaded: 2026-06-05
Licence: MIT (Handlebars-lang)
Project: https://handlebarsjs.com / https://github.com/handlebars-lang/handlebars.js

Previously shipped: Handlebars 1.0.0 (May 2013).

Upgraded from 1.0.0 (2013) to close known vulnerabilities accumulated over
the intervening decade and to land on a maintained release.

API stability:
  - Handlebars.compile(string)       — stable since 1.x, unchanged
  - Handlebars.registerHelper(...)   — stable since 1.x, unchanged
  - new Handlebars.SafeString(...)   — stable since 1.x, unchanged

FarCry uses only the above three APIs, all in static-template contexts (no
partials registered, no user-supplied template source). Upgrade is therefore
a drop-in replacement.

Loaded via:
  packages/lib/registerLibraries.cfc — id="fc-handlebars" / alias "handlebars"

To update:
  1. Pick the new version from https://github.com/handlebars-lang/handlebars.js/releases
  2. Download https://registry.npmjs.org/handlebars/-/handlebars-<X.Y.Z>.tgz
  3. Extract package/dist/handlebars.min.js into this directory
  4. Update the version above
  5. Skim the upstream changelog for breaking changes
