

<cfcomponent name="File" displayname="File" Extends="field" hint="Field component to liase with all File types"> 


	<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >
	
	<cffunction name="init" access="public" returntype="farcry.farcry_core.packages.formtools.file" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfparam name="arguments.stMetadata.ftstyle" default="">
		<cfparam name="arguments.stMetadata.ftDestination" default="/files">
		
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
								<ft:farcrybutton type="button" value="Delete File" onclick="if(confirm('Are you sure you want to remove this file?')) {} else {return false};$('#arguments.fieldname#').value='';Effect.Fade('#arguments.fieldname#previewfile');" />
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

<!--- 		<cfset var filePath = "" />
		
		<cfparam name="arguments.stMetadata.ftSecure" default="false">
		<cfparam name="arguments.stMetadata.ftDestination" default="/files">
	
		<cfif arguments.stMetadata.ftSecure>
			<cfset filePath = application.path.defaultFilePath />
		<cfelse>
			<cfset filePath = application.path.secureFilePath />
		</cfif> --->

		<cfsavecontent variable="html">
			<cfoutput><a target="_blank" href="#application.url.webroot#/download.cfm?downloadfile=#arguments.stobject.objectid#&field=#arguments.stmetadata.name#">#arguments.stMetadata.value#</a></cfoutput>			
			
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type. Includes Value and stSupporting">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var filePath = "" />
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = stFieldPost.value>
		<cfset stResult.stError = StructNew()>
		
		<cfparam name="arguments.stMetadata.ftSecure" default="false">
		<cfparam name="arguments.stMetadata.ftDestination" default="">

		<cfif arguments.stMetadata.ftSecure>
			<cfset filePath = application.path.secureFilePath />
		<cfelse>
			<cfset filePath = application.path.defaultFilePath />
		</cfif>
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<cfif NOT DirectoryExists("#filePath##arguments.stMetadata.ftDestination#")>
			<cfdirectory action="create" directory="#filePath##arguments.stMetadata.ftDestination#">
		</cfif>		
		
		
		<cfif len(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#New"])>
	
			<cffile action="UPLOAD"
		        filefield="#stMetadata.FormFieldPrefix##stMetadata.Name#New" 
		        destination="#filePath##arguments.stMetadata.ftDestination#"
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
