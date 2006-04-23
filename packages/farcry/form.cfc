<cfcomponent displayname="Form" hint="Manages common form functions">
	
	<cffunction name="uploadFile" hint="Uploads a file">
		<cfargument name="formField" hint="The name of the field that contains the file to be uploaded" required="true"   type="string">
		<cfargument name="destination" hint="Directory file is to be uploaded to - must pass in absolute path" type="string" default="#application.defaultImagePath#"> 
		<cfargument name="nameconflict" hint="File write behavior" type="string" default="MAKEUNIQUE"> 
		<cfargument name="accept" hint="File types to accept" type="string" default=""> 
		
		<cfset stReturn = structNew()>
		<cfset stReturn.bSuccess = false>
		
		<cfif len(arguments.formField)>
			
			<cftry>
				<!--- create the dir if it doesn't exist --->
				<cfif NOT directoryExists(arguments.destination)>
						<cfdirectory action="create" directory="#arguments.destination#"> 
				</cfif>
				
				<!--- upload file --->	
				<cffile action="UPLOAD" filefield="#arguments.formField#" destination="#arguments.destination#" nameconflict="#arguments.nameconflict#" accept="#arguments.accept#">
				
				<!--- check if filename has bad characters --->
				<cfif refindnocase("[\$\^\s\%\*''""<>]",file.serverfile) gt 0>
					<cfset validName = rereplace(file.serverfile,"[\$\^\s\%\*''""<>]","_","ALL")>
					<!--- rename file --->
					<cffile action="rename" source="#file.ServerDirectory#/#file.serverfile#" destination="#file.ServerDirectory#/#validName#">
				<cfelse>
					<!--- keep existing filename --->
					<cfset validName = file.serverfile>
				</cfif>
								
				<cfscript>
					stReturn.bSuccess = true;
					stReturn.message = "File upload Successful";
					stReturn.filename = validName;
					stReturn.fileDirectory = file.ServerDirectory;
					stReturn.fileSize = file.fileSize;
					stReturn.contentType =  file.ContentType;
					stReturn.clientFileName = file.clientFileName;
					stReturn.contentSubType = file.contentSubType;
					stReturn.serverFile = validName;
					stReturn.serverDirectory = file.ServerDirectory;
				</cfscript>
			
				<cfcatch>
					<cfset stReturn.message = cfcatch.message>
				</cfcatch>
			</cftry>
		<cfelse>	
			<cfset stReturn.message = "No file uploaded.">	
		</cfif>
		<cfreturn stReturn>
	</cffunction>	
</cfcomponent>