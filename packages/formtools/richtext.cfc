<!--- @@description:
	<p>Displays wyswyg editor with farcry plugins to add images, files, videos etc</p> --->

<!--- @@examples:
	<p>Example from dmHTML in farcry core</p>
	<code>
	<cfproperty 
		name="Body" type="longchar" hint="Main body of content." required="no" default="" 
		ftSeq="12" ftwizardStep="Body" ftFieldset="Body" ftLabel="Body" 
		ftType="richtext" 
		ftImageArrayField="aObjectIDs" ftImageTypename="dmImage" ftImageField="StandardImage"
		ftTemplateTypeList="dmImage,dmFile,dmFlash,dmNavigation,dmHTML" ftTemplateWebskinPrefixList="insertHTML"
		ftLinkListFilterRelatedTypenames="dmFile,dmNavigation,dmHTML"
		ftTemplateSnippetWebskinPrefix="insertSnippet">
	</code>
--->
<cfcomponent extends="field" name="richtext" displayname="Rich Text Editor" hint="Used to liase with longchar type fields"> 
	
	<cfproperty name="ftLabelAlignment" required="false" default="inline" options="inline,block" hint="Used by FarCry Form Layouts for positioning of labels. inline or block." />
	<cfproperty name="ftWidth" required="false" default="100%" hint="Width required for the rich text editor." />
	<cfproperty name="ftHeight" required="false" default="280px" hint="Height required for the rich text editor." />
	<cfproperty name="ftContentCSS" required="false" default="" hint="This option enables you to specify a custom CSS file that extends the theme content CSS. This CSS file is the one used within the editor (the editable area). This option can also be a comma separated list of URLs." />
	<cfproperty name="ftRichtextConfig" required="false" default="" hint="A custom method to use to load the richtext config." />
	
	<cfproperty name="ftImageListFilterTypename" required="false" default="dmImage" hint="The related image typename to show in the image list from the advimage plugin." />
	<cfproperty name="ftImageListFilterProperty" required="false" default="standardImage" hint="The related image typename property that contains the image we want to insert from the advimage plugin" />
	<cfproperty name="ftLinkListFilterTypenames" required="false" default="" hint="The list of related typenames to filter the link list on in the advlink plugin." />

	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.richtext" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
				
		<cfset var html = "" />	
		<cfset var configJS = "" />
		<cfset var external_image_list_url = "#application.url.webtop#/facade/TinyMCEImageList.cfm?relatedObjectid=#arguments.stObject.ObjectID#&relatedTypename=#arguments.typename#&ftImageListFilterTypename=#arguments.stMetadata.ftImageListFilterTypename#&ftImageListFilterProperty=#arguments.stMetadata.ftImageListFilterProperty#&ajaxMode=1" />
		<cfset var external_link_list_url = "#application.url.webtop#/facade/TinyMCELinkList.cfm?relatedObjectid=#arguments.stObject.ObjectID#&relatedTypename=#arguments.typename#&ftLinkListFilterTypenames=#arguments.stMetadata.ftLinkListFilterTypenames#&ajaxMode=1" />
		<cfset var oType = application.fapi.getContentType(arguments.typename) />
		
		<!--- IMPORT TAG LIBRARIES --->
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
				

		<cfif structKeyExists(arguments.stMetadata,'ftRichtextConfig') and len(trim(arguments.stMetadata.ftRichtextConfig)) and structKeyExists(oType,arguments.stMetadata.ftRichtextConfig)>
			<cfinvoke component="#oType#" method="#arguments.stMetadata.ftRichtextConfig#" returnvariable="configJS" />
		<cfelseif isdefined("application.config.tinyMCE.tinyMCE_config") AND isdefined("application.config.tinyMCE.bUseConfig") and application.config.tinyMCE.bUseConfig and len(trim(application.config.tinyMCE.tinyMCE_config))>
			<cfset configJS = application.config.tinyMCE.tinyMCE_config />
		<cfelse>
			<cfset configJS = getConfig(stMetadata="#arguments.stMetadata#") />
		</cfif>	
		
			
		<skin:loadJS id="jquery" />
		<skin:loadJS id="tinymce" />
		
		<cfsavecontent variable="html">
			
			<cfoutput>
				<script language="javascript" type="text/javascript">
				$j(function() {
					$j('###arguments.fieldname#').tinymce({

					script_url : '/webtop/thirdparty/tiny_mce/tiny_mce.js',

					farcryobjectid: "#arguments.stObject.ObjectID#",
					farcrytypename: "#arguments.stobject.Typename#",
					farcryrichtextfield: "#arguments.stMetadata.name#",
					<cfif len(configJS)>
						#configJS#,
					</cfif>
					external_image_list_url : "#external_image_list_url#",
					external_link_list_url : "#external_link_list_url#"
					<cfif len(arguments.stMetadata.ftWidth)>
						,width : "#arguments.stMetadata.ftWidth#"
					</cfif>
					<cfif len(arguments.stMetadata.ftHeight)>
						,height : "#arguments.stMetadata.ftHeight#"
					</cfif>	
					<cfif len(arguments.stMetadata.ftContentCSS)>
						,content_css : "#arguments.stMetadata.ftContentCSS#"
					</cfif>			
					
					});
				});
				</script>
				
				<style type="text/css">
				.richtext .formHint {float:left;}
				</style>

				<br style="clear:both;" #application.fapi.getDocType().tagEnding#>
				<textarea  name="#arguments.fieldname#" id="#arguments.fieldname#" class="textareaInput #arguments.stMetadata.ftClass#" style="width: 100%; #arguments.stMetadata.ftStyle#">#arguments.stMetadata.value#</textarea>
				<br style="clear:both;" #application.fapi.getDocType().tagEnding#>
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

	<cffunction name="getConfig" access="public" output="false" returntype="string" hint="This will return the configuration that will be used by the richtext field">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var configJS = "" />
		
		<cfsavecontent variable="configJS">
			<cfoutput>			
				theme : "advanced",
				plugins : "safari,farcrycontenttemplates,spellchecker,pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,inlinepopups,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template",
				theme_advanced_buttons2_add : "separator,spellchecker,farcrycontenttemplates",
				theme_advanced_buttons3_add_before : "tablecontrols,separator",			
				theme_advanced_buttons3_add : "separator,fullscreen,pasteword,pastetext",				
				theme_advanced_toolbar_location : "top",
				theme_advanced_toolbar_align : "left",
				theme_advanced_path_location : "bottom",
				theme_advanced_resize_horizontal : true,
				theme_advanced_resizing : true,
				theme_advanced_resizing_use_cookie : false,
				extended_valid_elements: "code,colgroup,col,thead,tfoot,tbody,abbr,blockquote,cite,button,textarea[name|class|cols|rows],script[type],img[style|class|src|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name]",
				remove_linebreaks : false,
				forced_root_block : 'p',
				relative_urls : false
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn configJS />
	</cffunction>

</cfcomponent>