<cfparam name="url.typename" type="string" />
<cfparam name="url.property" type="string" />
<cfparam name="url.fieldname" type="string" />
<cfparam name="url.current" type="string" />

<cfset stMetadata = application.stCOAPI[url.typename].stProps[url.property].metadata />

<cfparam name="stMetadata.ftSecure" default="false" />
<cfparam name="stMetadata.ftDestination" default="" />
<cfparam name="stMetadata.ftRenderType" default="flash" />

<cfif stMetadata.ftSecure>
	<cfset filePath = application.path.secureFilePath />
<cfelse>
	<cfset filePath = application.path.defaultFilePath />
</cfif>

<!--- Replace all none alphanumeric characters --->
<cfset cleanFileName = reReplaceNoCase(form.filename, "[^a-z0-9.]", "", "all") />

<cfif not directoryexists("#filePath##stMetadata.ftDestination#/")>
	<cfdirectory action="create" directory="#filePath##stMetadata.ftDestination#/" />
</cfif>

<cfif structKeyExists(url,"current") AND len(url.current)>
	<!--- This means there is currently a file associated with this object. We need to override this file --->
	
	<cfset lFormField = replace(url.current, '\', '/')>			
	<cfset uploadFileName = listLast(lFormField, "/") />
	
	<cffile action="UPLOAD"
		filefield="filedata" 
		destination="#filePath##stMetadata.ftDestination#/"		        	
		nameconflict="MakeUnique" mode="664" />
	<cffile action="rename" source="#filePath##stMetadata.ftDestination#/#File.ServerFile#" destination="#uploadFileName#" />
	<cfset cleanFileName = uploadFileName />
	<cfset newFileName = uploadFileName />
<cfelse>
	<!--- There is no image currently so we simply upload the image and make it unique  --->
	<cffile action="UPLOAD"
		filefield="filedata" 
		destination="#filePath##stMetadata.ftDestination#/"		        	
		nameconflict="MakeUnique" mode="664">
	<cfset newFileName = cffile.ServerFile>
</cfif>

<!--- If the filename has changed, rename the file
Note: doing a quick check to make sure the cleanfilename doesnt exist. If it does, prepend the count+1 to the end.
 --->
<cfif cleanFileName NEQ newFileName>
	<cfif fileExists("#filePath##stMetadata.ftDestination#/#cleanFileName#")>
		<cfdirectory action="list" directory="#filePath##stMetadata.ftDestination#" filter="#listFirst(cleanFileName, '.')#*" name="qDuplicates" />
		<cfif qDuplicates.RecordCount>
			<cfset cleanFileName = "#listFirst(cleanFileName, '.')##qDuplicates.recordCount+1#.#listLast(cleanFileName,'.')#">
		</cfif>
		 
	</cfif>
	
	<cffile action="rename" source="#filePath##stMetadata.ftDestination#/#newFileName#" destination="#cleanFileName#" />
</cfif>			

<cfset session[url.fieldname] = "#stMetadata.ftDestination#/#cleanFileName#" /><cfoutput>#session[url.fieldname]#</cfoutput>