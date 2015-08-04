(function() {
	// Load plugin specific language pack
	tinymce.PluginManager.requireLangPack('farcrycontenttemplates');
	
	tinymce.PluginManager.add('farcrycontenttemplates', function init(editor, url) {
		var params = editor.settings, stType = {}, menuItems = [], okbtn = undefined;
		
		// Register farcrycontenttemplates button
		if (params.farcryrelatedtypes && params.farcryrelatedtypes.length){
			for (var i=0; i<params.farcryrelatedtypes.length; i++){
				stType = params.farcryrelatedtypes[i];

				// Register the command so that it can be invoked by using tinyMCE.activeEditor.execCommand('mcefarcrycontenttemplates');
				(function(stType){
					editor.addMenuItem('farcryinserttemplatebutton'+stType.id, {
						text: stType.label,
						context: 'farcrycontenttemplates',
						onclick: function(){
							updatePreview("typename", stType.id);
							updatePreview("item",null);
							updatePreview("webskin",null);

							$j.getJSON(params.optionsURL,{
								relatedtypename : stType.id,
								relatedids : $j(".array input[type=hidden],.uuid input[type=hidden]").map(function(){ 
									return this.value.search(/^(,?\w{8}-\w{4}-\w{4}-\w{16}),?$/) === -1 ? null : this.value; 
								}).get().join(",")
							},function(data){
								if (typeof(data)==="string")
									data = $j.parseJSON(data);

								var items = [];
								if (data.showitems) {
									items.push({
										type: 'listbox',
										name: 'item',
										label: 'Item',
										text: 'None',
										maxWidth: null,
										values: data.items,
										onSelect: function(ev){
											updatePreview("item",ev.control.value());
										}
									});
								}
								items.push({
									type: 'listbox',
									name: 'webskin',
									label: 'Template',
									text: 'None',
									maxWidth: null,
									values: data.webskins,
									onSelect: function(ev){
										updatePreview("webskin",ev.control.value());
									}
								},{
									type: 'container',
									minHeight: 290,
									html: '<iframe id="farcry-template-preview" src=""></iframe>'
								});

								
								editor.windowManager.open({
									width : 700 + parseInt(editor.getLang('farcrycontenttemplates.delta_width', 0)),
									height : 400 + parseInt(editor.getLang('farcrycontenttemplates.delta_height', 0)),
									title : "Insert Template: "+stType.label,
									items: {
										type: 'form',
										columns: 2,
										defaults: {
											type: 'textbox'
										},
										items: items
									},
									buttons: [{ 
										name : "farcrytemplateok",
										text : "Ok", 
										subtype : "primary", 
										type : "button",
										onclick : function(){
											$j.ajax({
												type: "POST",
												url: params.previewURL + '&relatedobjectid=' + selection.item + '&relatedtypename=' + selection.typename + '&relatedwebskin=' + selection.webskin,
												cache: false,
												timeout: 2000,
												success: function(msg){
													editor.execCommand('mceInsertContent',false, msg.replace(/^\s*|\s*$/g,""));	//make sure to trim the return value
													editor.windowManager.close();
												}
											});
										},
										onPostRender : function(){
											okbtn = this;
										},
										disabled : true
									},{
										text : "Cancel",
										type : "button",
										onclick : function(){
											editor.windowManager.close();
										}
									}]
								},{
									plugin_url : url
								});

								updatePreview("typename",stType.id);
							});
						}
					});

					menuItems.push(editor.menuItems["farcryinserttemplatebutton"+stType.id]);
				})(stType);
			}
			
			editor.addButton("farcrycontenttemplates", {
				type: "menubutton",
				title : 'FarCry content templates',
				icon : "template",
				menu: menuItems
			});


			if (editor.settings.imageUploadField && editor.settings.imageUploadField.length && $j("#"+editor.settings.imageUploadField).size()){
				editor.addButton("farcryuploadcontent", {
					type: "button",
					title: 'Upload images',
					image: url + '/img/upload-alt.png',
					onclick : function(){
						var field = $j("#"+editor.settings.imageUploadField+"-bulkupload-type");

						field.val(editor.settings.imageUploadType);

						if (field.is("select"))
							field.trigger("change");
						else 
							$j("#"+editor.settings.imageUploadField+"-bulkupload-btn").trigger("click");
					}
				});
			}
		}

		var selection = {};
		function updatePreview(key,value){
			selection[key] = value;

			if (selection.typename == "richtextSnippet" && selection.webskin && selection.webskin.length) {
				$j('#farcry-template-preview').attr('src', params.previewURL + '&relatedtypename=' + selection.typename + '&relatedwebskin=' + selection.webskin);
				okbtn.disabled(false);
			}
			else if (selection.item && selection.item.length && selection.webskin && selection.webskin.length){
				$j('#farcry-template-preview').attr('src', params.previewURL + '&relatedobjectid=' + selection.item + '&relatedtypename=' + selection.typename + '&relatedwebskin=' + selection.webskin);
				okbtn.disabled(false);
			}
			else {
				$j("#farcry-template-preview").attr('src', '');
				if (okbtn) okbtn.disabled(true);
			}
		}

	});
})();