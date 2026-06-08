/**
 * FarCry Content Templates plugin for TinyMCE 8.
 *
 * Adds a "FarCry content templates" menu button (one entry per related type) that opens a
 * dialog for choosing an item + webskin, previews the rendered output in an iframe, and
 * inserts it; plus an "Upload images" button that triggers the field's bulk-upload control.
 *
 * Ported from the TinyMCE 4 plugin: editor.settings -> editor.options; addButton/addMenuItem
 * -> editor.ui.registry.*; the v4 window/listbox dialog -> the v5+ dialog (panel/selectbox/iframe).
 */
(function () {
	tinymce.PluginManager.add('farcrycontenttemplates', function (editor, url) {

		// The richtext formtool passes these as top-level init options; register them so editor.options.get() can read them.
		function registerOption(name, spec) {
			if (!editor.options.isRegistered(name)) {
				editor.options.register(name, spec);
			}
		}
		registerOption('farcryrelatedtypes', { processor: 'array', default: [] });
		registerOption('optionsURL', { processor: 'string', default: '' });
		registerOption('previewURL', { processor: 'string', default: '' });
		registerOption('imageUploadField', { processor: 'string', default: '' });
		registerOption('imageUploadType', { processor: 'string', default: '' });

		var farcryRelatedTypes = editor.options.get('farcryrelatedtypes') || [];
		var optionsURL = editor.options.get('optionsURL');
		var previewURL = editor.options.get('previewURL');

		// Collect related object IDs from the surrounding FarCry edit form.
		function getRelatedIDs() {
			var aRelatedIDs = $j('.array input[type=hidden],.uuid input[type=hidden]').map(function () {
				return this.value.search(/^(,?\w{8}-\w{4}-\w{4}-\w{16}),?$/) === -1 ? null : this.value;
			}).get();
			$j('li[id^="join-item-aObjectIDs"]').each(function () {
				aRelatedIDs.push($j(this).attr('serialize'));
			});
			return aRelatedIDs.join(',');
		}

		// Build the preview/insert URL for the current selection, or "" when the selection is incomplete.
		function buildContentURL(typename, data) {
			if (typename === 'richtextSnippet' && data.webskin) {
				return previewURL + '&relatedtypename=' + typename + '&relatedwebskin=' + data.webskin;
			}
			if (data.item && data.webskin) {
				return previewURL + '&relatedobjectid=' + data.item + '&relatedtypename=' + typename + '&relatedwebskin=' + data.webskin;
			}
			return '';
		}

		// Refresh the preview iframe and enable/disable the OK button for the current selection.
		function refreshPreview(api, typename) {
			var src = buildContentURL(typename, api.getData());
			if (src.length) {
				api.setEnabled('ok', true);
				$j.ajax({ type: 'GET', url: src, cache: false, timeout: 10000, success: function (html) {
					api.setData({ preview: html });
				} });
			} else {
				api.setEnabled('ok', false);
				api.setData({ preview: '' });
			}
		}

		// Open the insert-template dialog for a given related type.
		function openTemplateDialog(stType) {
			var lRelatedIDs = getRelatedIDs();

			$j.getJSON(optionsURL, { relatedtypename: stType.id, relatedids: lRelatedIDs }, function (data) {
				if (typeof data === 'string') {
					data = JSON.parse(data);
				}

				var bodyItems = [];
				var initialData = { webskin: '', preview: '' };

				if (data.showitems) {
					data.items.unshift({ text: 'None', value: '' });
					bodyItems.push({ type: 'selectbox', name: 'item', label: 'Item', items: data.items });
					initialData.item = '';
				}

				data.webskins.unshift({ text: 'None', value: '' });
				bodyItems.push({ type: 'selectbox', name: 'webskin', label: 'Template', items: data.webskins });
				bodyItems.push({ type: 'iframe', name: 'preview', label: 'Preview', sandboxed: false, transparent: false });

				editor.windowManager.open({
					title: 'Insert Template: ' + stType.label,
					size: 'large',
					body: { type: 'panel', items: bodyItems },
					initialData: initialData,
					buttons: [
						{ type: 'cancel', text: 'Cancel' },
						{ type: 'submit', name: 'ok', text: 'Ok', buttonType: 'primary', enabled: false }
					],
					onChange: function (api, details) {
						if (details.name === 'item' || details.name === 'webskin') {
							refreshPreview(api, stType.id);
						}
					},
					onSubmit: function (api) {
						var data = api.getData();
						$j.ajax({
							type: 'POST',
							url: previewURL + '&relatedobjectid=' + data.item + '&relatedtypename=' + stType.id + '&relatedwebskin=' + data.webskin,
							cache: false,
							timeout: 10000,
							success: function (msg) {
								editor.insertContent(msg.replace(/^\s*|\s*$/g, ''));
								api.close();
							}
						});
					}
				});
			});
		}

		// Toolbar: "FarCry content templates" menu button (one entry per related type).
		editor.ui.registry.addMenuButton('farcrycontenttemplates', {
			icon: 'template',
			tooltip: 'FarCry content templates',
			fetch: function (callback) {
				callback(farcryRelatedTypes.map(function (stType) {
					return { type: 'menuitem', text: stType.label, onAction: function () { openTemplateDialog(stType); } };
				}));
			}
		});

		// Toolbar: "Upload images" button. No-op when no bulk-upload field is configured for this field.
		editor.ui.registry.addButton('farcryuploadcontent', {
			icon: 'upload',
			tooltip: 'Upload images',
			onAction: function () {
				var imageUploadField = editor.options.get('imageUploadField');
				if (!imageUploadField || !imageUploadField.length || !$j('#' + imageUploadField).length) {
					return;
				}
				var field = $j('#' + imageUploadField + '-bulkupload-type');
				field.val(editor.options.get('imageUploadType'));
				if (field.is('select')) {
					field.trigger('change');
				} else {
					$j('#' + imageUploadField + '-bulkupload-btn').trigger('click');
				}
			}
		});

	});
})();
