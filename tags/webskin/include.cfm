<cfsetting enablecfoutputonly="true" />
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
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
		<cfset attributes.template = "/farcry/projects/#application.projectDirectoryName#/includedObj/#attributes.template#" />
	</cfif>
	
	<cfinclude template="#attributes.template#">
</cfif>


<cfsetting enablecfoutputonly="false" />