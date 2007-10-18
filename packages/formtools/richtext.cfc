<cfcomponent extends="field" name="richtext" displayname="Rich Text Editor" hint="Used to liase with longchar type fields"> 
	
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
		
		<cfparam name="arguments.stMetadata.ftImageArrayField" default="">
		<cfparam name="arguments.stMetadata.ftImageTypename" default="">
		<cfparam name="arguments.stMetadata.ftImageField" default="">
		<cfparam name="arguments.stMetadata.ftLinkListRelatedTypenames" default="">
		
		
		<cfparam name="arguments.stMetadata.ftConfig" default=""><!--- tinyMCE.tinyMCE_config --->
	
		<cfif len(arguments.stMetadata.ftConfig) and isdefined("application.config.#arguments.stMetadata.ftConfig#")>
			<cfset configJS =  Evaluate("application.config.#arguments.stMetadata.ftConfig#") />
		<cfelse>
			<cfset configJS = getConfig() />
		</cfif>	
	
		<cfset Request.InHead.TinyMCE = 1 />
		
		<cfsavecontent variable="html">
			<cfoutput>
			<script language="javascript" type="text/javascript">	</cfoutput>

				<cfoutput>
					tinyMCE.init({
						mode : "exact",
						farcryobjectid: "#arguments.stObject.ObjectID#",
						farcrytypename: "#arguments.stobject.Typename#",
						farcryrichtextfield: "#arguments.stMetadata.name#",
						elements : "#arguments.fieldname#",
						#configJS#,
						<cfif len(arguments.stMetadata.ftImageArrayField) and len(arguments.stMetadata.ftImageTypename) and len(arguments.stMetadata.ftImageField)>
							external_image_list_url : "#application.url.farcry#/facade/tinyMCEImageList.cfm?objectID=#arguments.stObject.ObjectID#&typename=#arguments.typename#&ImageArrayField=#arguments.stMetadata.ftImageArrayField#&ImageTypename=#arguments.stMetadata.ftImageTypename#&ImageField=#arguments.stMetadata.ftImageField#",
						</cfif>									
						external_link_list_url : "#application.url.farcry#/facade/tinyMCELinkList.cfm?objectID=#arguments.stObject.ObjectID#&typename=#arguments.typename#&relatedTypenames=#arguments.stMetadata.ftLinkListRelatedTypenames#"						
					});
				</cfoutput>
				
			<cfoutput></script></cfoutput>
			



			<cfoutput>
				<textarea  name="#arguments.fieldname#" id="#arguments.fieldname#" style="width: 600px;" class="richtext tinymce">#arguments.stMetadata.value#</textarea>
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
	
		<cfset var configJS = "" />
		
		<cfsavecontent variable="configJS">
			<cfoutput>			
				theme : "advanced",
				plugins : "table,advhr,farcrycontenttemplates,advimage,advlink,preview,zoom,searchreplace,print,contextmenu,paste,directionality,fullscreen",		<!--- farcryimage --->
				theme_advanced_buttons2_add : "separator,farcrycontenttemplates",
				theme_advanced_buttons3_add_before : "tablecontrols,separator",			
				theme_advanced_buttons3_add : "separator,fullscreen,pasteword,pastetext",				
				theme_advanced_toolbar_location : "top",
				theme_advanced_toolbar_align : "left",
				theme_advanced_path_location : "bottom",
				theme_advanced_resize_horizontal : true,
				theme_advanced_resizing : true,
				extended_valid_elements: "code,colgroup,col,thead,tfoot,tbody,abbr,blockquote,cite,button,textarea[name|class|cols|rows],script[type],img[style|class|src|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name]",
				remove_linebreaks : false,
				relative_urls : false
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn configJS />
	</cffunction>

</cfcomponent>