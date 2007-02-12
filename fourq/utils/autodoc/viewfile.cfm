<cfsetting enablecfoutputonly="Yes">

<cfparam name="url.filepath" type="string" default="">
<cfparam name="url.highlight" type="string" default="">


<cfset thefile = getFileFromPath(url.filepath)>
<cfset subdir = replace(url.filepath,'\#thefile#','')>

<cfoutput><a href="index.cfm?subdir=#variables.subdir#">Back to file browser</a><br><br></cfoutput>
<cfif not fileExists(fsroot & url.filepath)>
	<cfoutput>The file you are trying to view could not be found.<br></cfoutput>
	<cfabort>
</cfif>
<cfoutput>
<form action="#cgi.script_name#" style="border-bottom: 1px solid black; padding-bottom: 15px;">
CVS keyword to highlight: <input type="Text" name="highlight" value="#url.highlight#">
<input type="Hidden" name="filepath" value="#url.filepath#">
<input type="Submit" value="Go!">
<br><br>

<strong><em>&lt;fourq root&gt;#url.filepath#</em></strong>
<br>
</form>
</cfoutput>
<cfsavecontent variable="filedata">
	<cf_coloredcode file="#fsroot##url.filepath#" highlight="#url.highlight#">
</cfsavecontent>
<cfif len(url.highlight)>
	<cfsavecontent variable="prefix">
	<cfoutput><span style="color:red;font-weight:bold;font-family: sans-serif;"></cfoutput>
	</cfsavecontent>
	<cfsavecontent variable="suffix">
	<cfoutput></span></cfoutput>
	</cfsavecontent>
	<cfset filedata = reReplaceNoCase(filedata,'(\$#url.highlight#[^\$]+\$)','#prefix#\1#suffix#','all')>
</cfif>
<cfoutput>#filedata#</cfoutput>