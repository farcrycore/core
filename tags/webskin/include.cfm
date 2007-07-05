<cfsetting enablecfoutputonly="true" />
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| DESCRIPTION || 
$Description: This tag is use to include a page from the includedObj directory of a project or any plugin the project uses.$

|| DEVELOPER ||
$Developer: Matthew Bryant (mbryant@daemon.com.au)$

|| ATTRIBUTES ||
$in: template -- the template to be included. Noramlly this would be the complete path from the /farcry mapping but for legacy code, it may just be the filename$
--->


<cfif thistag.executionMode eq "Start">

	<cfif structKeyExists(caller, "stobj")>
		<cfset variables.stobj = caller.stobj />
	</cfif>

	<cfif not structKeyExists(attributes, "template")>
		<cfabort showerror="skin:include must be passed the template to be included" />
	</cfif>
	
	<!--- If the template passed in is simply a filename (ie. no path) then we assume the path is the projects includedObj directory --->
	<cfif NOT findNoCase("/", attributes.template)>
		<cfset attributes.template = "/farcry/projects/#application.applicationname#/includedObj/#attributes.template#" />
	</cfif>
	
	<cfinclude template="#attributes.template#">
</cfif>


<cfsetting enablecfoutputonly="false" />