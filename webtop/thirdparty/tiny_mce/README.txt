TinyMCE 8.6.0 — community / self-hosted (GPL), pre-built distribution
=====================================================================

Source: https://registry.npmjs.org/tinymce/-/tinymce-8.6.0.tgz
        (extract package/ : tinymce.min.js, themes/silver, models/dom,
         icons/default, skins/, plugins/)
Downloaded: 2026-06-08
Licence: GNU General Public License v2 or later (the community / self-hosted
         build). FarCry opts into the GPL terms via the init config
         license_key: "gpl" — without a license key, TinyMCE 8 starts in
         read-only mode. The bundle's license.md also documents the
         commercial Tiny Cloud option, which is not used here.
Project: https://www.tiny.cloud / https://github.com/tinymce/tinymce

Previously shipped: TinyMCE 4.9.11 (2020-07-13).

Upgraded from 4.9.11 to close known vulnerabilities in the older line and to
land on the current major. Skipped TinyMCE 7 deliberately: 7's community
security support ended 2025-11-11; 8 is the current line and the 4->7 vs 4->8
migration cost is the same.

Also retired the bundled CodeMirror 4.8 by deleting the old plugins/codemirror/
wrapper. Source view now uses TinyMCE 8's built-in `code` plugin (plain editable
HTML, no syntax highlighting). There is no CodeMirror anywhere in the tree any
more.

Bundles DOMPurify 3.4.5 (SAFE_FOR_XML default). This strips/normalises some
legacy content patterns on round-trip (IE conditional comments, Word-paste
<o:p>/<xml> residue, embedded MathML/RDF/custom-namespace SVG, etc.). See ADR
core/docs/0006-tinymce-8-upgrade.md "Release notes / downstream impact".

  Version provenance: tinymce.min.js opens with an upstream banner claiming
  "DOMPurify 3.3.2" and linking the 3.2.6 licence. That header is stale in the
  8.6.0 build. The code actually inlined further down carries its own
  "DOMPurify 3.4.5" licence banner and sets version="3.4.5" at runtime, and
  tinymce.js (unminified) carries only the 3.4.5 banner. 3.4.5 is the shipped
  version; the vendor file is left byte-for-byte as upstream published it
  rather than edited to correct its own comment. Re-check this on each upgrade
  by reading the version= assignment, not the file header.

FarCry-custom content in this distribution (DO NOT overwrite on update):
  - plugins/farcrycontenttemplates/  — FarCry "content templates" + upload
    button, ported to the TinyMCE 8 plugin API (editor.ui.registry.*, v8
    dialog). plugin.js and plugin.min.js are kept in sync (both unminified).
The old FarCry forks plugins/image_farcry, plugins/link_farcry and
plugins/codemirror were REMOVED — image/link now use TinyMCE 8's maintained
CORE `image`/`link` plugins (the FarCry library lists are fed via small
image_list/link_list adapter functions in richtext.cfc edit()), and `code`
is the built-in source view.

Editor configuration lives in the richtext formtool, not here:
  packages/formtools/richtext.cfc
    - getConfigJSON()  — base options (plugins, toolbar, etc.) as a struct
    - edit()           — assembles tinymce.init, injects license_key (from the
                         configTinyMCE "licenseKey" config, default "gpl") and
                         cache_suffix
  packages/forms/configTinyMCE.cfc — site config: licenseKey, tinyMCE8Config
                         (override), tinyMCE4_config (deprecated/unread)

cache_suffix: richtext.cfc sets cache_suffix: "?v=8.6.0" so TinyMCE's runtime
sub-asset loads (theme/model/icons/skin/plugins) cache-bust on upgrade. BUMP
this string whenever you change the bundled version (browsers otherwise serve
stale assets — non-combined registered JS gets no FarCry cache-buster).

Loaded via:
  packages/lib/registerLibraries.cfc — id="tinymce" (bCombine="false";
  TinyMCE auto-detects its baseURL from the loaded tinymce.min.js).

To update:
  1. Pick the new version from https://github.com/tinymce/tinymce/releases
  2. Download https://registry.npmjs.org/tinymce/-/tinymce-<X.Y.Z>.tgz
  3. Extract and replace this directory's contents with package/* (keep
     plugins/farcrycontenttemplates/), preserving the no-vendor-metadata
     convention (omit package.json/bower.json/composer.json/README.md/
     CHANGELOG.md/notices.txt/tinymce.d.ts).
  4. Bump cache_suffix: "?v=<X.Y.Z>" in richtext.cfc and the version above.
  5. Skim https://www.tiny.cloud/docs/tinymce/latest/migration-from-7x/ (and
     the 4->7 guide) for breaking changes; re-run the editor smoke tests from
     the pending-tests log.
  6. Re-read the DOMPurify version from the bundle (see the provenance note
     above) and update it here and in core/docs/0006-tinymce-8-upgrade.md.
