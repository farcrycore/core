Handlebars.js v4.7.9 — pre-built minified UMD
====================================================

Source: https://registry.npmjs.org/handlebars/-/handlebars-4.7.9.tgz
        (file: package/dist/handlebars.min.js)
Downloaded: 2026-06-05
Licence: MIT (Handlebars-lang)
Project: https://handlebarsjs.com / https://github.com/handlebars-lang/handlebars.js

Previously shipped: Handlebars 1.0.0 (May 2013).

Upgraded to close the following CVEs:
  - CVE-2019-19919 — Prototype Pollution leading to RCE (pre 3.0.8 / 4.3.0)
  - CVE-2019-20920 — Arbitrary code execution via lookup helper (pre 4.6.0)
  - CVE-2019-20922 — RCE if template options compiled at runtime (pre 4.6.0)
  - CVE-2021-23369 — Template RCE via lookup compilation flags (pre 4.7.7)
  - CVE-2026-33916 — Prototype Pollution leading to XSS through Partial
                     Template Injection (4.0.0 through 4.7.8; fixed in 4.7.9)
  - CVE-2026-33941 — CLI Precompiler Injection (4.0.0 through 4.7.8; fixed
                     in 4.7.9, not exploitable here as FarCry compiles at runtime)

CVE-2026-33937 (AST Injection RCE) requires the caller to pass an AST object
to Handlebars.compile() — FarCry only ever passes template strings, so this
vector is not exploitable in current code; the upgrade closes it defensively.

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
