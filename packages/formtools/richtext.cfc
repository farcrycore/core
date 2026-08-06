<!--- @@description:
	<p>Displays tinyMCE 4.x WYSIWYG editor with farcry plugins to add images, files, videos etc</p> --->

<!--- @@examples:
	<p>Example from dmHTML in farcry core</p>
	<code>
	<cfproperty 
		name="Body" type="longchar" hint="Main body of content." required="no" default="" 
		ftSeq="12" ftwizardStep="Body" ftFieldset="Body" ftLabel="Body" 
		ftType="richtext" 
		ftImageArrayField="aObjectIDs" ftImageTypename="dmImage" ftImageField="StandardImage"
		ftTemplateTypeList="dmImage,dmFile,dmNavigation,dmHTML" ftTemplateWebskinPrefixList="insertHTML"
		ftLinkListFilterTypenames="dmFile,dmNavigation,dmHTML"
		ftTemplateSnippetWebskinPrefix="insertSnippet">
	</code>
--->
<cfcomponent extends="field" name="richtext" displayname="Rich Text Editor" hint="Used to liase with longchar type fields"> 
	
	<cfproperty name="ftLabelAlignment" required="false" default="block" options="inline,block" hint="Used by FarCry Form Layouts for positioning of labels. inline or block." />
	<cfproperty name="ftWidth" required="false" default="100%" hint="Width required for the rich text editor." />
	<cfproperty name="ftHeight" required="false" default="420px" hint="Height required for the rich text editor." />
	<cfproperty name="ftContentCSS" required="false" default="" hint="This option enables you to specify a custom CSS file that extends the theme content CSS. This CSS file is the one used within the editor (the editable area). This option can also be a comma separated list of URLs." />
	<cfproperty name="ftRichtextConfig" required="false" default="" hint="A custom method to use to return the richtext config, or the richtext config as a string (useful when overriding property metadata)" />
	
	<cfproperty name="ftImageListFilterTypename" required="false" default="dmImage" hint="The related image typename to show in the image list from the advimage plugin." />
	<cfproperty name="ftImageListFilterProperty" required="false" default="standardImage" hint="The related image typename property that contains the image we want to insert from the advimage plugin" />
	<cfproperty name="ftLinkListFilterTypenames" required="false" default="" hint="The list of related typenames to filter the link list on in the advlink plugin." />

	<cfproperty name="ftTemplateTypeList" required="false" default="" hint="The list of related typenames to show content templates for." />
	<cfproperty name="ftTemplateSnippetWebskinPrefix" required="false" default="insertSnippet" hint="The webskin prefix used to insert content template snippets." />
	<cfproperty name="ftTemplateWebskinPrefixList" required="false" default="insertHTML" hint="The webskin prefix used to insert content." />


	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.richtext" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="inputClass" required="false" type="string" default="" hint="This is the class value that will be applied to the input field.">

		<cfset var html = "" />	
		<cfset var configJS = "" />
		<cfset var external_image_list_url = "#application.url.webtop#/facade/TinyMCEImageList.cfm?relatedObjectid=#arguments.stObject.ObjectID#&relatedTypename=#arguments.typename#&ftImageListFilterTypename=#arguments.stMetadata.ftImageListFilterTypename#&ftImageListFilterProperty=#arguments.stMetadata.ftImageListFilterProperty#&ajaxMode=1" />
		<cfset var external_link_list_url = "#application.url.webtop#/facade/TinyMCELinkList.cfm?relatedObjectid=#arguments.stObject.ObjectID#&relatedTypename=#arguments.typename#&ftLinkListFilterTypenames=#arguments.stMetadata.ftLinkListFilterTypenames#&ajaxMode=1" />
		<cfset var oType = application.fapi.getContentType(arguments.typename) />
		<cfset var aRelatedTypes = arraynew(1) />
		<cfset var stType = structnew() />
		<cfset var thistype = "" />
		<cfset var imageUploadField = "" />
		<cfset var thisfield = "" />
		<cfset var stProp = structnew() />
		
		<!--- IMPORT TAG LIBRARIES --->
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
				

		<cfif structKeyExists(arguments.stMetadata,'ftRichtextConfig') and len(trim(arguments.stMetadata.ftRichtextConfig))>
			<cfif isValid("variableName", arguments.stMetadata.ftRichtextConfig) AND structKeyExists(oType,arguments.stMetadata.ftRichtextConfig)>
				<cfinvoke component="#oType#" method="#arguments.stMetadata.ftRichtextConfig#" returnvariable="configJS" />
			<cfelse>
				<cfset configJS = arguments.stMetadata.ftRichtextConfig>
			</cfif>
		<cfelseif application.fapi.getConfig("tinyMCE","bUseConfig",false) and len(application.fapi.getConfig("tinyMCE","tinyMCE8Config",""))>
			<cfset configJS = application.fapi.getConfig("tinyMCE","tinyMCE8Config") />
		<cfelse>
			<cfset configJS = trim(serializeJSON(getConfigJSON())) />
			<cfset configJS = mid(configJS, 2, len(configJS) - 2) />
		</cfif>	
		
		<cfif not len(arguments.stMetadata.ftContentCSS)>
			<cfset arguments.stMetadata.ftContentCSS = "#application.url.webtop#/thirdparty/bootstrap/bootstrap-tinymce.css" />
		</cfif>

		<skin:loadJS id="fc-jquery" />
		<skin:loadJS id="tinymce" />
		
		<cfif len(arguments.stMetadata.ftTemplateTypeList)>
			<cfloop list="#arguments.stMetadata.ftTemplateTypeList#" index="thistype">
				<cfset stType = structnew() />
				<cfset stType["id"] = thistype />
				<cfset stType["label"] = thistype />

				<cfif structKeyExists(application.stCOAPI, thistype) AND structKeyExists(application.stCOAPI[thistype], "displayname")>
					<cfset stType["label"] = application.stCOAPI[thistype].displayname />
				</cfif>

				<cfset arrayappend(aRelatedTypes,stType) />
			</cfloop>
		</cfif>

		<cfif listlen(arguments.stMetadata.ftImageListFilterTypename) eq 1 and application.stCOAPI[arguments.stMetadata.ftImageListFilterTypename].bBulkUpload>
			<cfloop collection="#application.stCOAPI[arguments.typename].stProps#" item="thisfield">
				<cfset stProp = application.stCOAPI[arguments.typename].stProps[thisfield].metadata />
				<cfif stProp.type eq "array" and structkeyexists(stProp,"ftJoin") and listfindnocase(stProp.ftJoin,arguments.stMetadata.ftImageListFilterTypename) and stProp.ftAllowBulkUpload>
					<cfset imageUploadField = rereplacenocase(arguments.fieldname,"#arguments.stMetadata.name#$",stProp.name) />
				</cfif>
			</cfloop>
		</cfif>

		<cfsavecontent variable="html">
			
			<cfoutput>
				<script type="text/javascript">
				$j(function() {
					tinymce.init({
					selector: '###arguments.fieldname#',

					script_url : '#application.url.webtop#/thirdparty/tiny_mce/tinymce.min.js',
					license_key : "#application.fapi.getConfig("tinyMCE","licenseKey","gpl")#",
					cache_suffix : "?v=8.6.0",

					farcryrelatedtypes: #serializeJSON(aRelatedTypes)#,
					optionsURL: "#getAjaxURL(typename=arguments.typename,stObject=arguments.stObject,stMetadata=arguments.stMetadata,fieldname=arguments.fieldname,combined=false)#&action=templateoptions",
					previewURL: "#getAjaxURL(typename=arguments.typename,stObject=arguments.stObject,stMetadata=arguments.stMetadata,fieldname=arguments.fieldname,combined=false)#&action=templatehtml",
					<cfif len(configJS)>
						#configJS#,
					</cfif>
					image_list : function (success) {
						$j.ajax({
							url : "#getAjaxURL(typename=arguments.typename,stObject=arguments.stObject,stMetadata=arguments.stMetadata,fieldname=arguments.fieldname,combined=false)#&action=imageoptions&relatedTypename=#arguments.stMetadata.ftImageListFilterTypename#&relatedProperty=#arguments.stMetadata.ftImageListFilterProperty#",
							cache : false,
							success : function (data) {
								if (typeof data === "string") { data = JSON.parse(data); }
								var items = ((data || {}).images) || [];
								success(items.map(function (it) {
									return { title : it.title || it.text, value : it.value || it.url };
								}));
							},
							error : function () { success([]); }
						});
					}
					<cfif len(arguments.stMetadata.ftLinkListFilterTypenames)>
						, link_list : function (success) {
							$j.ajax({
								url : "#getAjaxURL(typename=arguments.typename,stObject=arguments.stObject,stMetadata=arguments.stMetadata,fieldname=arguments.fieldname,combined=false)#&action=linkoptions&relatedTypename=#arguments.stMetadata.ftLinkListFilterTypenames#",
								cache : false,
								success : function (data) {
									if (typeof data === "string") { data = JSON.parse(data); }
									var mapItem = function (it) {
										return it.menu ? { title : it.title || it.text, menu : it.menu.map(mapItem) } : { title : it.title || it.text, value : it.value || it.url };
									};
									var items = ((data || {}).links) || [];
									success(items.map(mapItem));
								},
								error : function () { success([]); }
							});
						}
					</cfif>
					<cfif len(imageUploadField)>
						, imageUploadField : #serializeJSON(imageUploadField)#
						, imageUploadType : #serializeJSON(arguments.stMetadata.ftImageListFilterTypename)#
					</cfif>
					<cfif len(arguments.stMetadata.ftWidth)>
						,width : "#arguments.stMetadata.ftWidth#"
					</cfif>
					<cfif len(arguments.stMetadata.ftHeight)>
						,height : "#arguments.stMetadata.ftHeight#"
					</cfif>	
					<cfif len(arguments.stMetadata.ftContentCSS)>
						,content_css : "#arguments.stMetadata.ftContentCSS#"
					</cfif>			
					
					})
					.then(function(editors) {
						// Heads-up if an overridden config (ftRichtextConfig / tinyMCE8Config) still lists plugins removed in v8.
						var aRemovedPlugins = ["hr","textcolor","paste","contextmenu","noneditable","colorpicker","imagetools","spellchecker","textpattern","toc","print","bbcode","fullpage","legacyoutput","tabfocus","codemirror"];
						(editors || []).forEach(function(editor) {
							try {
								var sPlugins = editor.options.get("plugins");
								sPlugins = (Array.isArray(sPlugins) ? sPlugins.join(" ") : (sPlugins || "")) + "";
								var aStale = aRemovedPlugins.filter(function(name) {
									return new RegExp("(^|[ ,])" + name + "([ ,]|$)").test(sPlugins);
								});
								if (aStale.length) {
									editor.notificationManager.open({
										type: "warning",
										text: "This rich text editor is using an outdated TinyMCE configuration (removed plugins: " + aStale.join(", ") + "). It was likely set up for an older TinyMCE version - please update your TinyMCE config.",
										timeout: 0
									});
								}
							} catch (e) {}
						});
					})
					.catch(function() {});
				});
				</script>
				
				<style type="text/css">
				.richtext .formHint {float:left;}
				div.webtop-modal.mce-fullscreen { padding-top: 0; }
				div.mce-container.mce-window.mce-fullscreen { top: 0 !important; }
				</style>

				<textarea  name="#arguments.fieldname#" id="#arguments.fieldname#" class="textareaInput #arguments.inputClass# #arguments.stMetadata.ftClass#" style="width: 100%; #arguments.stMetadata.ftStyle#">#arguments.stMetadata.value#</textarea>

			</cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		
		<cfsavecontent variable="html">
			<cfoutput>#replaceNoCase(application.fc.lib.esapi.encodeForHTML(arguments.stMetadata.value), chr(10), "<br>" , "all")#</cfoutput>
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

		<cfset stResult = super.validate(argumentCollection=arguments)>
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>


	<cffunction name="ajax" output="false" returntype="string" hint="Response to ajax requests for this formtool">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var stLocals = structnew() />
		<cfset var stResult = structnew() />
		<cfset var stObj = getLatestObject(arguments.stObject) />

		<cfif url.action eq "templateoptions">
			<cfparam name="url.relatedtypename" />

			<cfreturn serializeJSON(getTemplateOptions(
				stObject=stObj,
				stMetadata=arguments.stMetadata,
				relatedtypename=url.relatedtypename,
				relatedids=url.relatedids
			)) />
		</cfif>

		<cfif url.action eq "templatehtml">
			<cfif url.relatedtypename eq "richtextSnippet">
				<cfparam name="url.relatedtypename" />
				<cfparam name="url.relatedwebskin" />

				<cfreturn application.fapi.getContentType(url.relatedtypename).getView(
					typename=url.relatedtypename,
					template=url.relatedwebskin
				) />	
			<cfelse>
				<cfparam name="url.relatedtypename" />
				<cfparam name="url.relatedobjectid" />
				<cfparam name="url.relatedwebskin" />

				<cfreturn application.fapi.getContentType(url.relatedtypename).getView(
					typename=url.relatedtypename,
					objectid=url.relatedobjectid, 
					template=url.relatedwebskin
				) />	
			</cfif>
		</cfif>

		<cfif url.action eq "imageoptions">
			<cfparam name="url.relatedtypename" />
			<cfparam name="url.relatedproperty" />

			<cfreturn serializeJSON(getImageOptions(
				stObject=stObj,
				stMetadata=arguments.stMetadata,
				relatedtypename=url.relatedtypename,
				relatedproperty=url.relatedproperty
			)) />
		</cfif>

		<cfif url.action eq "linkoptions">
			<cfparam name="url.relatedtypename" />

			<cfreturn serializeJSON(getLinkOptions(
				stObject=stObj,
				stMetadata=arguments.stMetadata,
				relatedtypename=url.relatedtypename
			)) />
		</cfif>
	</cffunction>

	<cffunction name="getLatestObject" access="public" output="false" returntype="struct">
		<cfargument name="stObject" type="struct" required="true" />

		<cfset var stNew = duplicate(arguments.stObject) />
		<cfset var stWizard = structnew() />
		<cfset var fcFormFieldName = "" />
		<cfset var fieldname = "" />
		<cfset var stProps = application.stCOAPI[stNew.typename].stProps />

		<cfset structappend(stNew,application.fapi.getContentObject(typename=stNew.typename,objectid=stNew.objectid),false) />

		<!--- Get wizard data if exists --->
		<cfif structKeyExists(form,"wizardid") and len(form.wizardid)>
			<cfset form.wizardid = listFirst(form.wizardid)> <!--- got the wizard id twice sometimes --->
			<cfset stWizard = application.fapi.getContentType("dmWizard").Read(wizardID=form.wizardid)>
			<cfset structappend(stNew,stWizard.Data[arguments.stObject.objectid],true) />
		</cfif>

		<!--- Overwrite data if user currently changing some relations - Hidden fields passed in via ajax --->
		<cfloop list="#structKeyList(stProps)#" index="fieldname">
			<cfset fcFormFieldName = "fc#replace(stNew.objectid,"-","","all")##fieldname#">
			<cfif structKeyExists(form,fcFormFieldName)>
				<cfif stProps[fieldname].metadata.type EQ "array">
					<cfset stNew[fieldname] = listToArray(form[fcFormFieldName])>
				<cfelse>
					<!--- don't replace objectid --->
					<cfif fieldname NEQ 'ObjectID'>
						<cfset stNew[fieldname] = form[fcFormFieldName]>
					</cfif>
				</cfif>
			</cfif>
		</cfloop> 

		<cfreturn stNew />
	</cffunction>

	<cffunction name="getTemplateOptions" access="public" output="false" returntype="struct">
		<cfargument name="stObject" type="struct" required="true" />
		<cfargument name="stMetadata" type="struct" required="true" />
		<cfargument name="relatedtypename" type="string" required="true" />
		<cfargument name="relatedids" type="string" required="false" default="" />

		<cfset var stProps = application.stcoapi[arguments.stObject.typename].stprops />
		<cfset var lRelated = arguments.relatedids />
		<cfset var fieldname = "" />
		<cfset var templateWebskinPrefix = "" />
		<cfset var templateSnippetWebskinPrefix = "" />
		<cfset var stResult = structnew() />
		<cfset var qRelated = "" />
		<cfset var qWebskins = "" />
		<cfset var stItem = structnew() />
		<cfset var qLibrary = "" />
		<cfset var qTemp = "" />
		<cfset var stRelatedMetadata = "" />
		<cfset var item = "" />
		<cfset var lAdded = "" />
		<cfset var thisfield = "" />
		
		<!--- items --->
		<cfset stResult["items"] = arraynew(1) />
		<cfset stResult["showitems"] = true>

		<cfloop collection="#stProps#" item="fieldname">
			<cfif (stProps[fieldname].metadata.type EQ "array" OR stProps[fieldname].metadata.type EQ "UUID" AND structKeyExists(stProps[fieldname].metadata, "ftJoin"))
				AND listContainsNoCase(stProps[fieldname].metadata.ftJoin,arguments.relatedtypename)>

				<cfif stProps[fieldname].metadata.type EQ "array" and arraylen(arguments.stObject[fieldname])>
					<cfloop array="#arguments.stObject[fieldname]#" index="thisfield">
						<cfif isStruct(thisfield)>
							<cfset lRelated = listAppend(lRelated, thisfield.data) />
						<cfelse>
							<cfset lRelated = listAppend(lRelated, thisfield) />
						</cfif>
					</cfloop>
				<cfelseif stProps[fieldname].metadata.type EQ "UUID" and len(arguments.stObject[fieldname])>
					<cfset lRelated = listAppend(lRelated, arguments.stObject[fieldname]) />
				</cfif>

				<cfif len(lRelated)>
					<cfset stRelatedMetadata = application.fapi.getPropertyMetadata(typename=arguments.stObject.typename, property=fieldname) />
					<cfset stRelatedMetadata = application.fapi.getFormtool(stRelatedMetadata.type).prepMetadata(stObject=arguments.stObject, stMetadata=stRelatedMetadata) />
					<cfif not structkeyexists(stRelatedMetadata,"ftLibraryDataTypename") or not len(stRelatedMetadata.ftLibraryDataTypename)>
						<cfset stRelatedMetadata.ftLibraryDataTypename = arguments.relatedtypename />
					</cfif>
					<cfset qLibrary = application.fapi.getContentType(stRelatedMetadata.ftLibraryDataTypename).getLibraryRecordset(primaryID=arguments.stObject.objectid, primaryTypename=arguments.stObject.typename, stMetadata=stRelatedMetadata, filterType=arguments.relatedtypename, filter="") />

					<cfloop list="#lRelated#" index="item">
						<cfif not listfindnocase(lAdded, item)>
							<cfquery dbtype="query" name="qTemp">
								select 	* 
								from 	qLibrary 
								where 	objectid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#item#">
							</cfquery>

							<cfif qTemp.recordcount>
								<cfset stItem = structnew() />
								<cfset stItem["value"] = item />
								<cfset stItem["text"] = qTemp.label[1] />
								<cfset arrayappend(stResult["items"],stItem) />
								<cfset lAdded = listappend(lAdded, item) />
							</cfif>
						</cfif>
					</cfloop>
				</cfif>
			</cfif>
		</cfloop>

		<cfif arguments.relatedtypename eq "richtextSnippet">
			<cfset stResult["showitems"] = false>
		</cfif>

		<!--- webskins --->
		<cfset stResult["webskins"] = arraynew(1) />
		<cfif arguments.relatedtypename eq "richtextSnippet">
			<cfset templateSnippetWebskinPrefix = arguments.stMetadata.ftTemplateSnippetWebskinPrefix>

			<cfset qWebskins = application.fapi.getContentType(arguments.relatedtypename).getWebskins(
				typename=arguments.relatedtypename, 
				prefix=templateSnippetWebskinPrefix
			) />
		<cfelse>
			<cfif listfind(stProps[arguments.stMetadata.name].metadata.ftTemplateTypeList,url.relatedtypename) LTE listLen(arguments.stMetadata.ftTemplateWebskinPrefixList)>
				<cfset templateWebskinPrefix = listgetat(arguments.stMetadata.ftTemplateWebskinPrefixList,listfind(arguments.stMetadata.ftTemplateTypeList,arguments.relatedtypename)) />
			<cfelse>
				<cfset templateWebskinPrefix = listLast(arguments.stMetadata.ftTemplateWebskinPrefixList) />
			</cfif>

			<cfset qWebskins = application.fapi.getContentType(arguments.relatedtypename).getWebskins(
				typename=arguments.relatedtypename, 
				prefix=templateWebskinPrefix
			) />
		</cfif>

		<cfloop query="qWebskins">
			<cfset stItem = structnew() />
			<cfset stItem["value"] = listfirst(qWebskins.name,".") />
			<cfset stItem["text"] = qWebskins.displayname />
			<cfset arrayappend(stResult["webskins"],stItem) />
		</cfloop>


		<cfreturn stResult />
	</cffunction>

	<cffunction name="getImageOptions" access="public" output="false" returntype="struct">
		<cfargument name="stObject" typename="struct" required="true" />
		<cfargument name="stMetadata" typename="struct" required="true" />
		<cfargument name="relatedTypename" typename="string" required="true" />
		<cfargument name="relatedProperty" typename="string" required="true" />

		<cfset var stResult = structnew() />
		<cfset var qImages = querynew("") />
		<cfset var stProps = application.stCOAPI[arguments.stObject.typename].stProps />
		<cfset var lRelated = "" />
		<cfset var fieldname = "" />
		<cfset var stImage = structnew() />

		<cfsetting showdebugoutput="false" />

		<cfset stResult["images"] = arraynew(1) />

		<cfloop collection="#stProps#" item="fieldname">
			<cfif (
					stProps[fieldname].metadata.type EQ "array" 
					OR stProps[fieldname].metadata.type EQ "UUID" 
				)
				AND structKeyExists(stProps[fieldname].metadata, "ftJoin")
				AND listfindnocase(stProps[fieldname].metadata.ftJoin,arguments.relatedTypename)>
				
				<cfif stProps[fieldname].metadata.type EQ "array" AND arraylen(arguments.stObject[fieldname])>

					<cfset lRelated = listAppend(lRelated, arrayToList(arguments.stObject[fieldname])) />
					
				<cfelseif stProps[fieldname].metadata.type EQ "UUID" AND len(arguments.stObject[fieldname])>
					
					<cfset lRelated = listAppend(lRelated, arguments.stObject[fieldname]) />
					
				</cfif>
			</cfif>
		</cfloop>

		<cfif len(lRelated)>
			<cfset qImages = application.fapi.getContentObjects(
				typename=arguments.relatedTypename,
				status="draft,pending,approved",
				lProperties="objectid,label,#arguments.relatedProperty# as image",
				objectid_in=lRelated
			) />
		</cfif>

		<cfloop query="qImages">
			<cfset stImage = structnew() />
			<cfset stImage["title"] = qImages.label />
			<cfset stImage["url"] = application.fc.lib.cdn.ioGetFileLocation(
				location="images",
				file=qImages.image,
				admin=true,
				bRetrieve=true
			).path />
			<cfset arrayappend(stResult["images"],stImage) />
		</cfloop>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="getLinkOptions" access="public" output="false" returntype="struct">
		<cfargument name="stObject" typename="struct" required="true" />
		<cfargument name="stMetadata" typename="struct" required="true" />
		<cfargument name="relatedTypename" typename="string" required="true" />
		
		<cfset var stResult = structnew() />
		<cfset var qRelated = queryNew("") />
		<cfset var stProps = application.stCOAPI[arguments.stObject.typename].stProps />
		<cfset var qSiteMap = createObject("component","#application.packagepath#.farcry.tree").getDescendants(
			objectid=application.fapi.getNavID('home'), 
			bIncludeSelf=1
		) />
		<cfset var stLinks = structnew() />
		<cfset var stLink = structnew() />
		<cfset var lRelated = "" />
		<cfset var fieldname = "" />
		<cfset var thistype = "" />
		<cfset var qRelated = "" />
		
		<cfsetting showdebugoutput="false" />

		<cfset stResult["links"] = arraynew(1) />

		<cfif qSiteMap.recordCount>
			<cfset stLinks = structnew() />
			<cfset stLinks["text"] = "Site Tree" />
			<cfset stLinks["value"] = " " />
			<cfset stLinks["menu"] = arraynew(1) />

			<cfloop query="qSiteMap">
				<cfset stLink = structnew() />
				<cfset stLink["text"] = RepeatString('-', qSiteMap.nLevel) & " " & qSiteMap.objectname />
				<cfset stLink["value"] = application.fapi.getLink(objectid=qSiteMap.objectid) />
				<cfset arrayappend(stLinks["menu"],stLink) />
			</cfloop>

			<cfset arrayappend(stResult["links"],stLinks) />
		</cfif>

		<!--- related content --->
		<cfset lRelated = "" />
		<cfloop list="#structKeyList(stProps)#" index="fieldname">
			<cfif (
					stProps[fieldname].metadata.type EQ "array" 
					OR stProps[fieldname].metadata.type EQ "UUID" 
				)
				AND structKeyExists(stProps[fieldname].metadata, "ftJoin")>
				
				<cfif stProps[fieldname].metadata.type EQ "array" AND arraylen(stObject[fieldname])>

					<cfset lRelated = listAppend(lRelated, arrayToList(stObject[fieldname])) />
					
				<cfelseif stProps[fieldname].metadata.type EQ "UUID" AND len(stObject[fieldname])>
					
					<cfset lRelated = listAppend(lRelated, stObject[fieldname]) />
					
				</cfif>
			</cfif>
		</cfloop>

		<cfif len(lRelated)>
			<cfloop list="#arguments.relatedTypename#" index="thistype">
				<cfset qRelated = application.fapi.getContentObjects(
					typename=thistype,
					status="draft,pending,approved",
					lProperties="objectid,label",
					objectid_in=lRelated
				) />
				
				<cfif qRelated.recordcount>
					<cfset stLinks = structnew() />
					<cfset stLinks["text"] = application.stCOAPI[thistype].displayname />
					<cfset stLinks["value"] = " " />
					<cfset stLinks["menu"] = arraynew(1) />

					<cfloop query="qRelated">
						<cfset stLink = structnew() />
						<cfset stLink["text"] = qRelated.label />
						<cfset stLink["value"] = application.fapi.getLink(objectid=qRelated.objectid) />
						<cfset arrayappend(stLinks["menu"],stLink) />
					</cfloop>

					<cfset arrayappend(stResult["links"],stLinks) />
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="getConfigJSON" access="public" output="false" returntype="struct" hint="Returns the base TinyMCE config as a struct so projects can override individual options without string manipulation. Keys are set with bracket notation so serializeJSON preserves their case.">
		<cfargument name="stConfig" required="false" type="struct" default="#structNew()#" hint="An optional config struct to populate and return; defaults to a new struct.">

		<cfset arguments.stConfig["plugins"] = "farcrycontenttemplates,image,link,insertdatetime,media,searchreplace,directionality,fullscreen,visualchars,nonbreaking,anchor,charmap,lists,table,code" />
		<!--- empty on purpose: tinymce's default html5 schema already allows everything this toolbar
			  produces. keep the key even while it is empty, because projects append to it from a
			  getConfigJSON() override and removing it breaks them. if you do add entries, naming an
			  element replaces its allowed attributes rather than adding to them: "img" on its own
			  would strip every image attribute. --->
		<cfset arguments.stConfig["extended_valid_elements"] = "" />

		<!--- body fields hold prose. forms and embedded documents belong in a dedicated field on the content
			  type, or in a postprocessor that expands a url at render time. removing a tag keeps the text
			  inside it, so a pasted form leaves its wording behind; an iframe has no text and just goes. --->
		<cfset arguments.stConfig["invalid_elements"] = "form,input,select,option,optgroup,textarea,button,fieldset,legend,label,iframe" />
		<cfset arguments.stConfig["menubar"] = false />
		<cfset arguments.stConfig["toolbar"] = "undo redo | cut copy paste pastetext | styles | bold italic underline | bullist numlist link image table | farcrycontenttemplates farcryuploadcontent | code | fullscreen" />
		<cfset arguments.stConfig["toolbar_mode"] = "wrap" />
		<cfset arguments.stConfig["remove_linebreaks"] = false />
		<cfset arguments.stConfig["forced_root_block"] = "p" />
		<cfset arguments.stConfig["relative_urls"] = false />
		<cfset arguments.stConfig["entity_encoding"] = "raw" />

		<cfreturn arguments.stConfig />
	</cffunction>

	<cffunction name="getConfig" access="public" output="false" returntype="string" hint="DEPRECATED: override getConfigJSON() instead. Returns the base config as a brace-less JS object fragment derived from getConfigJSON(), for backwards compatibility with callers expecting a string.">
		<cfargument name="stMetadata" required="false" type="struct" default="#structNew()#" hint="Unused; retained for signature compatibility.">

		<cfset var json = trim(serializeJSON(getConfigJSON())) />
		<cfreturn mid(json, 2, len(json) - 2) />
	</cffunction>

</cfcomponent>
