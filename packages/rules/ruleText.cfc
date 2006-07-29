<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: $
$Author: $
$Date: $
$Name: $
$Revision: $

|| DESCRIPTION || 
$Description: 

$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfcomponent displayname="Text Rule" extends="rules" 
	hint="Publishing rule for rendering a block of user definable text/markup in the container.">

<!--- rule object properties --->
<cfproperty name="title" type="string" hint="Title for text rule; not displayed in the container." required="no" default="">
<cfproperty name="text" type="longchar" hint="Text to display.  Can be any combination of content and HTML markup." required="yes" default="">

<!--- import tag library --->
<cfimport prefix="q4" taglib="/farcry/fourq/tags">

<cffunction name="update" output="true">
	<cfargument name="objectID" required="Yes" type="uuid" default="">
	<cfargument name="label" required="no" type="string" default="">

	<cfset var stObj = getData(arguments.objectid) />
	
	<cfparam name="form.title" default="">
	<cfparam name="form.text" default="">
	
	<!--- save submitted data --->
	<cfif isDefined("form.submit")>
	
		<cfscript>
			stObj.title = form.title;
			stObj.text = form.text;
		</cfscript>
		<q4:contentobjectdata typename="#application.rules.ruleText.rulePath#" stProperties="#stObj#" objectID="#stObj.objectID#">
		<!--- Now assign the metadata --->
		<cfset message = "#application.adminBundle[session.dmProfile.locale].updateSuccessful#">
	</cfif>
	<cfif isDefined("message")>
		<div align="center"><strong>#message#</strong></div>
	</cfif>
				
	<!--- form --->
	<form action="" method="POST">
	<table width="100%" align="center" border="0">
		<input type="hidden" name="ruleID" value="#stObj.objectID#">
		<tr>
			<td align="right"><b>Title</b></td>
			<td> <input type="text" name="title" value="#stObj.title#"></td>
		</tr>
    	</table>
    	<textarea name="text" cols="50" rows="15">#stObj.text#</textarea>
		<div align="center"><input class="normalbttnstyle" type="submit" value="#application.adminBundle[session.dmProfile.locale].go#" name="submit"></div>
	</form>
</cffunction>
	
<cffunction name="execute" hint="Displays the text rule on the page." output="false" returntype="void" access="public">
	<cfargument name="objectID" required="Yes" type="uuid" default="">
	<cfargument name="dsn" required="false" type="string" default="#application.dsn#">
	
	<cfset var stObj = getData(arguments.objectid) /> 
	<cfset var blurb = stObj.text />

	<cfif len(trim(blurb))>
		<cfset arrayAppend(request.aInvocations,blurb) />
	</cfif>
</cffunction>
</cfcomponent>

