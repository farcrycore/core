Uppy v5.2.4 — pre-built UMD bundle
====================================

Source: https://releases.transloadit.com/uppy/v5.2.4/uppy.min.js
Downloaded: 2026-05-29
Licence: MIT (Transloadit)
Project: https://uppy.io

This is the full Uppy CDN bundle. It exposes a single global, window.Uppy,
which is a namespace containing every plugin Transloadit publishes:

    new window.Uppy.Uppy({ ... })          // core constructor (was Core in v4)
    uppy.use(window.Uppy.XHRUpload, { ... })
    uppy.use(window.Uppy.AwsS3Multipart, { ... })   // available for Phase 2
    // ... Dashboard, DragDrop, StatusBar, etc. also present but not used

FarCry only uses Uppy.Uppy and Uppy.XHRUpload via the wrapper at
  webtop/js/uploader/fc-uploader.js

The UI plugins ship inside this bundle (we accept ~80 KB gzipped overhead
to avoid a build step). A future optimisation could build a slim
Core+XHRUpload bundle with esbuild.

To update:
  1. Pick the new version from https://github.com/transloadit/uppy/releases
  2. Download https://releases.transloadit.com/uppy/v<X.Y.Z>/uppy.min.js
  3. Replace this directory's uppy.min.js
  4. Update the version above
  5. Skim the upstream changelog for breaking changes that affect
     window.Uppy.Uppy or window.Uppy.XHRUpload
