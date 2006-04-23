<!--- cf_CopyDirectory 				--->
<!--- Version 1.00 					--->
<!--- July 29, 2000 				--->

<!--- Digital Flair, Inc. 			--->
<!--- (805) 968-6700				--->
<!--- http://www.digitalflair.com	--->

<!--- 
Syntax is 

<cf_CopyDirectory source="" destination="" nameconflict="">

Arguements are

source - 					full drive path to source directory you want to copy
destination - 				full drive path to destination directory to put directory into
nameconflict (optional) - 
							error (default) - return error if file exists
							skip			- skip copy if file exists
							overwrite		- overwrite destination file
							makeunique		- make destination file unique (rename if file name is already present)
copyrootdir (optional) -
							yes (default)	- copy root directory
							no				- do not copy root directory (copy contents)
--->

<!--- Check for Errors --->
<cfset error = 0>
<cfset error_messages = "">
<cfif parameterexists(attributes.source) is 0>
	<cfset error = 1>
	<cfset error_messages = error_messages & "<li>Error Occurred. Source was not specified.">
<cfelse>
	<cfset source = attributes.source>
	<!--- <cfset source = Replace(attributes.source, "/","\","ALL")>
	<cfset source = Replace(source, "\\","\","ALL")>
	<cfset source = REReplace(source, "\\+$", "")> --->
</cfif>
<cfif parameterexists(attributes.destination) is 0>
	<cfset error = 1>
	<cfset error_messages = error_messages & "<li>Error Occurred. Destination was not specified.">
<cfelse>
	<cfset destination = attributes.destination>
	<!--- <cfset destination = Replace(attributes.destination, "/","\","ALL")>
	<cfset destination = Replace(destination, "\\","\","ALL")>
	<cfset destination = REReplace(destination, "\\+$", "")> --->
</cfif>
<cfif Find(source, destination) GT 0><cfset error = 1><cfset error_messages = error_messages & "<li>Error Occurred.  Source cannot be inside of Destination."></cfif>


<!--- Check Optional Attributes --->
<cfif parameterexists(attributes.nameconflict)>
	<cfif LCase(attributes.nameconflict) is "error" OR Lcase(attributes.nameconflict) is "skip" OR LCase(attributes.nameconflict) is "overwrite" OR LCase(attributes.nameconflict) is "makeunique">
		<cfset nameconflict = attributes.nameconflict>
	<cfelse>
		<cfset error = 1>
		<cfset error_messages = error_messages & "<li>Error Occurred.  Nameconflict did not contain a valid value.">
	</cfif>
<cfelse>
	<cfset nameconflict = "error">
</cfif>
<cfif parameterexists(attributes.copyrootdir)>
	<cfif LCase(attributes.copyrootdir) is "yes" OR Lcase(attributes.copyrootdir) is "no">
		<cfset copyrootdir = attributes.copyrootdir>
	<cfelse>
		<cfset error = 1>
		<cfset error_messages = error_messages & "<li>Error Occurred.  CopyRootDir did not contain a valid value.">
	</cfif>
<cfelse>
	<cfset copyrootdir = "yes">
</cfif>


<!--- Set Up Temporary Array --->
<cfset temp_source_array = ArrayNew(1)>
<cfset temp_source_array[1] = source>

<cfif error IS 0>


	<!--- Create Destination Directory --->
	<cfif LCase(copyrootdir) is "yes">
		<cfdirectory action="LIST" directory="#destination#" name="temp_list">
		<cfif temp_list.RecordCount IS 0>
			<cfdirectory action="CREATE" directory="#destination#">
		</cfif>
	</cfif>

	<!--- Loop Through All Directories Found --->
	<cfloop condition="ArrayLen(temp_source_array) GT 0">
		<cfif error GT 0><cfbreak></cfif>
		<cfset add_path = "">
		<cfif Val(Len(temp_source_array[1])-Len(source)) GT 0>
			<cfset add_path = Right(temp_source_array[1], Val(Len(temp_source_array[1])-Len(source)-1))>
		</cfif>
			<!--- Parse Directory Contents --->
			<cfdirectory action="LIST" directory="#temp_source_array[1]#" name="directory_list">
			
			<cfloop query="directory_list">
				<cfif error GT 0><cfbreak></cfif>
				<cfif directory_list.type is "Dir" AND directory_list.name is not "." AND directory_list.name is not "..">
					<cfdirectory action="LIST" directory="#destination#/#add_path#/" name="temp_list" filter="#directory_list.name#">

					<cfif temp_list.RecordCount IS 0>
						<cfif Len(add_path) IS 0>
							<cfdirectory action="CREATE" directory="#destination#/#directory_list.name#">
						<cfelse>
							<cfdirectory action="CREATE" directory="#destination#/#add_path#/#directory_list.name#">
						</cfif>
					</cfif>

					<cfset error = Abs(Val(ArrayAppend(temp_source_array, "#temp_source_array[1]#/#directory_list.name#")-1))>
				<cfelseif directory_list.type IS "File">
					<cfif Len(add_path) GT 0>
						<cfdirectory action="LIST" directory="#destination#/#add_path#" name="temp_list" filter="#directory_list.name#">
						<cfif temp_list.RecordCount GT 0 and LCase(nameconflict) is "error">
							<cfset error_messages = error_messages & "Error Occured. Destination file exists.">
							<cfset error = 1><cfbreak>
						<cfelseif temp_list.RecordCount GT 0 and LCase(nameconflict) is "overwrite">
							<cffile action="COPY" source="#temp_source_array[1]#/#directory_list.name#" destination="#destination#/#add_path#/#directory_list.name#">
						<cfelseif temp_list.RecordCount GT 0 and LCase(nameconflict) is "makeunique">
							<cfset unique_file_check_flag = 1>
							<cfset counter = 2>
							<cfloop condition="unique_file_check_flag GT 0">
								<cfset temp_file_name = Left(directory_list.name, REFind(".\..+$", directory_list.name)) & counter & Right(directory_list.name, Len(directory_list.name)-REFind(".\..+$", directory_list.name))>
								<cfdirectory action="LIST" directory="#destination#" name="unique_file_check" filter="#temp_file_name#">
								<cfset unique_file_check_flag = unique_file_check.RecordCount>
								<cfset counter = counter + 1>
							</cfloop>
							<cffile action="COPY" source="#temp_source_array[1]#/#directory_list.name#" destination="#destination#/#add_path#/#temp_file_name#">
						<cfelseif temp_list.RecordCount IS 0>
							<cffile action="COPY" source="#temp_source_array[1]#/#directory_list.name#" destination="#destination#/#add_path#/#directory_list.name#">
						</cfif>
					<cfelse>
						<cfdirectory action="LIST" directory="#destination#" name="temp_list" filter="#directory_list.name#">
						<cfif temp_list.RecordCount GT 0 and LCase(nameconflict) is "error">
							<cfset error_messages = error_messages & "Error Occured. Destination file exists.">
							<cfset error = 1><cfbreak>
						<cfelseif temp_list.RecordCount GT 0 and LCase(nameconflict) is "overwrite">
							<cffile action="COPY" source="#temp_source_array[1]#/#directory_list.name#" destination="#destination#/#directory_list.name#">
						<cfelseif temp_list.RecordCount GT 0 and LCase(nameconflict) is "makeunique">
							<cfset unique_file_check_flag = 1>
							<cfset counter = 2>
							<cfloop condition="unique_file_check_flag GT 0">
								<cfset temp_file_name = Left(directory_list.name, REFind(".\..+$", directory_list.name)) & counter & Right(directory_list.name, Len(directory_list.name)-REFind(".\..+$", directory_list.name))>
								<cfdirectory action="LIST" directory="#destination#" name="unique_file_check" filter="#temp_file_name#">
								<cfset unique_file_check_flag = unique_file_check.RecordCount>
								<cfset counter = counter + 1>
							</cfloop>
							<cffile action="COPY" source="#temp_source_array[1]#/#directory_list.name#" destination="#destination#/#temp_file_name#">
						<cfelseif temp_list.RecordCount IS 0>
							<cffile action="COPY" source="#temp_source_array[1]#/#directory_list.name#" destination="#destination#/#directory_list.name#">
						</cfif>
					</cfif>
				</cfif>
			</cfloop>
		<cfset error = Abs(Val(ArrayDeleteAt(temp_source_array, 1)-1))>
	</cfloop>

<cfelse>
	<cfoutput>#error_messages#</cfoutput>
	<cfabort>
</cfif>


<cfset Caller.CopyDirectoryStatus = Abs(Val(error-1))>
<cfset Caller.CopyDirectoryErrors = error_messages>
