

<cfcomponent name="File" displayname="File" Extends="field" hint="Field component to liase with all File types"> 


	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
	<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" >
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.file" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfparam name="arguments.stMetadata.ftstyle" default="">
		
		<cfset Request.inHead.Scriptaculous = 1>
		
		<skin:htmlHead id="ftCheckFileName">
		<cfoutput>
		<script type="text/javascript">
			function ftCheckFileName(id){
				var currentText = $(id).value;	
				var aCurrentExt = currentText.split(".");	
					
				var newText = $(id + 'NEW').value;	
				var aNewExt = newText.split(".");	
				
				if (currentText.length > 0 && newText.length > 0) {
					if (aCurrentExt.length > 1 && aNewExt.length > 1){						
						if (aCurrentExt[aCurrentExt.length - 1] != aNewExt[aNewExt.length - 1]){
							$(id + 'NEW').value = '';
							alert('You must either delete the old file or upload a new one with the same extension (' + aCurrentExt[aCurrentExt.length - 1] + ')');
						}
					}
				}
			}
		</script>
		</cfoutput>
		</skin:htmlHead>
		
		<cfsavecontent variable="html">
			<cfoutput>
				<table border="1">
				<tr>
					<td valign="top">
						<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" />
						<input type="hidden" name="#arguments.fieldname#DELETE" id="#arguments.fieldname#DELETE" value="" />
						<input type="file" name="#arguments.fieldname#NEW" id="#arguments.fieldname#NEW" value="" style="#arguments.stMetadata.ftstyle#" onchange="ftCheckFileName('#arguments.fieldname#');" />
					</td>
					
					<cfif len(#arguments.stMetadata.value#)>
						<td valign="top">
							<div id="#arguments.fieldname#previewfile">
								<cfif structKeyExists(arguments.stMetadata, "ftSecure") and arguments.stMetadata.ftSecure>
									<img src="#application.url.farcry#/images/crystal/22x22/actions/lock.png" />
								</cfif>
								#arguments.stMetadata.value#
								<ft:farcryButton type="button" value="Delete File" onclick="if(confirm('Are you sure you want to remove this file?')) {} else {return false};$('#arguments.fieldname#DELETE').value=$('#arguments.fieldname#').value;$('#arguments.fieldname#').value='';Effect.Fade('#arguments.fieldname#previewfile');" />
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
			<cfoutput><a target="_blank" href="#application.url.webroot#/download.cfm?downloadfile=#arguments.stobject.objectid#&typename=#arguments.typename#&field=#arguments.stmetadata.name#">#arguments.stMetadata.value#</a></cfoutput>			
			
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type. Includes Value and stSupporting">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var filePath = "" />
		<cfset var stResult = structNew()>	
		<cfset var uploadFileName = "" />
			
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = stFieldPost.value>
		<cfset stResult.stError = StructNew()>
		
		<cfparam name="arguments.stMetadata.ftSecure" default="false">
		<cfparam name="arguments.stMetadata.ftDestination" default="">
		
		<cfif len(arguments.stMetadata.ftDestination) and right(arguments.stMetadata.ftDestination,1) EQ "/">
			<cfset arguments.stMetadata.ftDestination = left(arguments.stMetadata.ftDestination, (len(arguments.stMetadata.ftDestination) - 1)) />
		</cfif>

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
		
		<cfif len(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#Delete"]) AND fileExists("#filePath##FORM['#stMetadata.FormFieldPrefix##stMetadata.Name#Delete']#")>
			
			<!--- create media archive directory as required --->
			<cfif NOT DirectoryExists("#application.path.mediaArchive#")>
				<cfdirectory action="create" directory="#application.path.mediaArchive#">
			</cfif>
			
			<!--- create typename/property directory archive as required --->
			<cfif NOT DirectoryExists("#application.path.mediaArchive##arguments.stMetadata.ftDestination#")>
				<cfdirectory action="create" directory="#application.path.mediaArchive##arguments.stMetadata.ftDestination#">
			</cfif>
			
			<!--- generate media archive entry --->
		 	<cffile 
			   action = "move"
			   source = "#filePath##FORM['#stMetadata.FormFieldPrefix##stMetadata.Name#Delete']#"
			   destination = "#application.path.mediaArchive##arguments.stMetadata.ftDestination#/#arguments.objectid#-#DateDiff('s', 'January 1 1970 00:00', now())#-#listLast(FORM['#stMetadata.FormFieldPrefix##stMetadata.Name#Delete'], '/')#">

		</cfif>
			
		
		<cfif len(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#New"])>
	
	
			<cfif structKeyExists(form, "#stMetadata.FormFieldPrefix##stMetadata.Name#") AND  len(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#"])>
				<!--- This means there is currently a file associated with this object. We need to override this file --->
				
				<cfset uploadFileName = listLast(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#"], "/") />
				
				<cffile action="UPLOAD"
					filefield="#stMetadata.FormFieldPrefix##stMetadata.Name#New" 
					destination="#filePath##arguments.stMetadata.ftDestination#/#uploadFileName#"		        	
					nameconflict="Overwrite" />
				
			<cfelse>
				<!--- There is no image currently so we simply upload the image and make it unique  --->
				<cffile action="UPLOAD"
					filefield="#stMetadata.FormFieldPrefix##stMetadata.Name#New" 
					destination="#filePath##arguments.stMetadata.ftDestination#"		        	
					nameconflict="MakeUnique">
			</cfif>

	
			
			<!--- Replace all none alphanumeric characters --->
			<cfset cleanFileName = reReplaceNoCase(File.ServerFile, "[^a-z0-9.]", "", "all") />
			
			<!--- If the filename has changed, rename the file
			Note: doing a quick check to make sure the cleanfilename doesnt exist. If it does, prepend the count+1 to the end.
			 --->
			<cfif cleanFileName NEQ File.ServerFile>
				<cfif fileExists("#filePath##arguments.stMetadata.ftDestination#/#cleanFileName#")>
					<cfdirectory action="list" directory="#filePath##arguments.stMetadata.ftDestination#" filter="#listFirst(cleanFileName, '.')#*" name="qDuplicates" />
					<cfif qDuplicates.RecordCount>
						<cfset cleanFileName = "#listFirst(cleanFileName, '.')##qDuplicates.recordCount+1#.#listLast(cleanFileName,'.')#">
					</cfif>
					 
				</cfif>
				
				<cffile action="rename" source="#filePath##arguments.stMetadata.ftDestination#/#File.ServerFile#" destination="#cleanFileName#" / >
			</cfif>			
									
			<!--- </cfif> --->
			<cfset stResult.value = "#arguments.stMetadata.ftDestination#/#cleanFileName#">

			
		</cfif>
		

	
<!--- 		 --->
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>


</cfcomponent> 
