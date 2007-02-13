<!--- Get the root directory for the fourq system
This assumes that you have a mapping called 'fourq' 
that points to the directory containing fourq.cfc
 --->


<cfparam name="url.subdir" default="">

<!--- Get a listing of the relevant directory --->
<cfdirectory action="LIST" directory="#fsroot##url.subdir#" name="qFiles">

<cfoutput>
<!--- Create the link to go up to the parent directory --->
<div style="border-bottom: 1px solid black;">
	<cfif len(url.subdir)>
		<cfset prevdir = listDeleteAt(url.subdir,listlen(url.subdir,'\'),'\')>
		<a href="index.cfm?subdir=#prevdir#">Up</a><br>
	<cfelse>
		<span style="color:gray">Up</span>
	</cfif>
</div>

<!--- display the files and directories in the current directory --->
<table>
<cfloop query="qFiles">
	<tr>
	<cfif qFiles.type NEQ 'dir'>
		<cfset filepath = url.subdir & '\' & qFiles.name>
		<td>
		<a href="viewfile.cfm?filepath=#filepath#&highlight=#keyword#">#qFiles.name#</a>
		</td>
		<td><a href="xmlgenerator.cfm?filepath=#url.subdir#\#qFiles.name#">autodoc</a></td>
		<td>[FILE]</td>
	<cfelse>
		<td>
		<a href="index.cfm?subdir=#url.subdir#\#qFiles.name#">#qFiles.name#</a>
		</td>
		<td><a href="xmlgenerator.cfm?directory=#url.subdir#\#qFiles.name#">autodoc</a></td>
		<td>[DIR]</td>
	</cfif>
	</tr>
</cfloop>
</table>
</cfoutput>