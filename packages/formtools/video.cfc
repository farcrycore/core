

<cfcomponent name="Video" displayname="Video" Extends="field" hint="Field component to liase with all Video types"> 


	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.video" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfparam name="arguments.stMetadata.ftstyle" default="">
		<cfparam name="arguments.stMetadata.ftDestination" default="/videos">
		
		<cfset Request.inHead.Scriptaculous = 1>
		
		<cfsavecontent variable="html">
			<cfoutput>
				<table>
				<tr>
					<td valign="top">
						<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" />
						<input type="file" name="#arguments.fieldname#NEW" id="#arguments.fieldname#NEW" value="" style="#arguments.stMetadata.ftstyle#" />
					</td>
					
					<cfif len(#arguments.stMetadata.value#)>
						<td valign="top">
							<div id="#arguments.fieldname#previewfile">
								#arguments.stMetadata.value#
								<ft:farcryButton type="button" value="Delete Video" onclick="if(confirm('Are you sure you want to remove this file?')) {} else {return false};$('#arguments.fieldname#').value='';Effect.Fade('#arguments.fieldname#previewfile');" />
							</div>
						</td>
					</cfif>				
					
				</tr>
				</table>
			</cfoutput>					
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfparam name="arguments.stMetadata.ftDestination" default="/files">
	

		<cfsavecontent variable="html">
			<cfoutput><a target="_blank" href="#arguments.stMetadata.value#"><cfif len(stobject.Title)>#stObject.Title#<cfelse>#arguments.stMetadata.value#</cfif></a></cfoutput>			
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type. Includes Value and stSupporting">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = stFieldPost.value>
		<cfset stResult.stError = StructNew()>
		
		<cfparam name="arguments.stMetadata.ftDestination" default="/files">

		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		
		<cfif NOT DirectoryExists("#application.path.project#/www#arguments.stMetadata.ftDestination#")>
			<cfdirectory action="create" directory="#application.path.project#/www#arguments.stMetadata.ftDestination#">
		</cfif>		
		
		
		<cfif len(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#New"])>
	
			<cffile action="UPLOAD"
		        filefield="#stMetadata.FormFieldPrefix##stMetadata.Name#New" 
		        destination="#application.path.project#/www#arguments.stMetadata.ftDestination#"
				nameconflict="MAKEUNIQUE">					
									
			<!--- </cfif> --->
			<cfset stResult.value = "#arguments.stMetadata.ftDestination#/#File.ServerFile#">
			
			
		</cfif>
		

	
<!--- 		 --->
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

</cfcomponent> 
