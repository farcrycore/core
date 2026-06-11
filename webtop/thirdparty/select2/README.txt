Select2 v4.1.0 — pre-built full minified bundle
================================================

Source: https://registry.npmjs.org/select2/-/select2-4.1.0.tgz
        (files: package/dist/js/select2.full.min.js, package/dist/css/select2.min.css)
Downloaded: 2026-06-11
Licence: MIT (Kevin Brown, Igor Vaynberg, and Select2 contributors) — see LICENSE.md
Project: https://select2.org / https://github.com/select2/select2

Previously shipped: Select2 3.3.2.

Upgraded from 3.3.2 to close known vulnerabilities accumulated on the old major
and to land on the maintained 4.x release line.

FarCry-custom wrapper — DO NOT discard on upgrade:
  webtop/thirdparty/select2/typeahead.js
  (the `typeahead` jQuery plugin used by packages/formtools/typeahead.cfc;
   wraps .select2() for FarCry's library / XHR-ajax / inline-data / create-new /
   watch flows. Rewritten for the 4.x API: templateResult, ajax.processResults,
   .val(), data: array, new Option().)

The 3 -> 4 upgrade also changed the formtool render and the webtop CSS:
  - packages/formtools/typeahead.cfc renders a <select> (4.x dropped the old
    <input type="hidden"> initialisation); already-selected values are emitted
    server-side as <option selected>.
  - webtop/css/webtop7.css uses the 4.x BEM classes (.select2-search__field,
    .select2-container--default .select2-selection--multiple).

Loaded via:
  packages/lib/registerLibraries.cfc
    JS  id="typeahead"  (select2.full.min.js,typeahead.js)  bCombine="false"
    CSS id="typeahead"  (select2.min.css)                   bCombine="false"
  (bCombine="false" — FarCry's combine pipeline re-minifies and breaks
   already-minified bundles.)

To update:
  1. Pick the new 4.x version from https://github.com/select2/select2/releases
  2. Download https://registry.npmjs.org/select2/-/select2-<X.Y.Z>.tgz
  3. Extract package/dist/js/select2.full.min.js + package/dist/css/select2.min.css here
     (and package/LICENSE.md)
  4. Update the version above
  5. Skim the upstream changelog for breaking changes to the APIs typeahead.js uses
     (templateResult, ajax.processResults, .val(), data:, new Option())
