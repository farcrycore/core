<cfcomponent extends="field" name="richtext" displayname="Rich Text Editor" hint="Used to liase with longchar type fields"> 
	
	<cffunction name="init" access="public" returntype="farcry.farcry_core.packages.formtools.richtext" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfparam name="arguments.stMetadata.ftImageListField" default="">
		<cfparam name="arguments.stMetadata.ftConfig" default=""><!--- tinyMCE.tinyMCE_config --->
	
		<cfset Request.InHead.TinyMCE = 1>
	
		<cfsavecontent variable="html">
			
			<cfoutput><script language="javascript" type="text/javascript">	</cfoutput>

				<cfoutput>
					tinyMCE.init({
						mode : "exact",
						<cfif len(arguments.stMetadata.ftConfig) and isdefined("application.config.#arguments.stMetadata.ftConfig#")>
							#Evaluate("application.config.#arguments.stMetadata.ftConfig#")#,
						<cfelse>
							theme : "advanced",
							plugins : "table,advhr,advlink,preview,zoom,searchreplace,print,contextmenu,paste,directionality,fullscreen",		
							theme_advanced_buttons3_add : "separator,fullscreen,pasteword",
							
							theme_advanced_toolbar_location : "top",
							theme_advanced_toolbar_align : "left",
							theme_advanced_path_location : "bottom",
							theme_advanced_resize_horizontal : true,
							theme_advanced_resizing : true,
						</cfif>						
						elements : "#arguments.fieldname#",
						<!---<cfif NOT ListFindNoCase("none,default", application.config.tinyMCE.insertimage_callback) AND application.config.tinyMCE.insertimage_callback NEQ "">
							insertimage_callback : "#application.config.tinyMCE.insertimage_callback#",
						</cfif> --->
						<!--- <cfif NOT ListFindNoCase("none,default", application.config.tinyMCE.file_browser_callback) AND application.config.tinyMCE.file_browser_callback NEQ "">
							file_browser_callback : "#application.config.tinyMCE.file_browser_callback#",
						</cfif> --->
						file_browser_callback : "fileBrowserCallBack",
						<cfif len(arguments.stMetadata.ftImageListField)>
							external_image_list_url : "#application.url.farcry#/facade/tinyMCEImageList.cfm?objectID=#arguments.stObject.ObjectID#&Typename=#arguments.stobject.Typename#&FieldName=#arguments.stMetadata.ftImageListField#",
						</cfif>			
						external_link_list_url : "#application.url.farcry#/facade/tinyMCELinkList.cfm",		

						
					});
				</cfoutput>
			
				<cfif not isDefined("Request.TinyMCEBrowserCallbackJS")>
					
					<cfset Request.TinyMCEBrowserCallbackJS = 1><!--- Make sure this is only placced once per request. --->
					
					<cfoutput>
						function fileBrowserCallBack(field_name, url, type, win) {
						// This is where you insert your custom filebrowser logic
						//alert("Example of filebrowser callback: field_name: " + field_name + ", url: " + url + ", type: " + type);
						this.field = field_name;
						this.callerWindow = win;
						this.inTinyMCE = true;
							
						urlLocation = '/scratch/tinymce/examples/libraryPopup.cfm?objectid=x-y-z&field_name=' + field_name + '&url=' + url + '&type=' + type;
						librarywin=window.open(urlLocation, '_blank', ''); 
						librarywin.focus();
						//return false;
						// Insert new URL, this would normaly be done in a popup
						win.document.forms[0].elements[field_name].value = url;
					}
				
					function insertIt(url) {
				
						// Handle old and new style
				<!--- 		if (typeof(TinyMCE_convertURL) != "undefined")
							url = TinyMCE_convertURL(url, null, true);
						else
							url = tinyMCE.convertURL(url, null, true);
				 --->
						// Set URL
						this.callerWindow.document.forms[0].elements[this.field].value = url;
				
						// Try to fire the onchange event
						try {
							this.callerWindow.document.forms[0].elements[this.field].onchange();
						} catch (e) {
							// Skip it
						}
					}
					</cfoutput>
					
					
				</cfif>
				
			<cfoutput></script></cfoutput>
			



			<cfoutput>
				<textarea  name="#arguments.fieldname#" id="#arguments.fieldname#">#arguments.stMetadata.value#</textarea>
				<!--- <div><textarea name="#arguments.fieldname#" id="#arguments.fieldname#" style="#arguments.stMetadata.ftstyle#;width:100%;" >#arguments.stMetadata.value#</textarea></div> --->
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		
		<cfsavecontent variable="html">
			<!--- Place custom code here! --->
			<cfoutput>#ReplaceNoCase(arguments.stMetadata.value, chr(10), "<br>" , "All")#</cfoutput>
			
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.It consists of value and stSupporting">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = stFieldPost.Value>
		<cfset stResult.stError = StructNew()>
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->

		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>


</cfcomponent> 