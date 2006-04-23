<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2004, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/rules/rules.cfc,v 1.11.2.1 2004/12/15 21:32:41 nmische Exp $
$Author: nmische $
$Date: 2004/12/15 21:32:41 $
$Name: milestone_2-2-1 $
$Revision: 1.11.2.1 $

|| DESCRIPTION || 
$Description: Abstract Rules Class $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayname="Rules Object" bAbstract="true" extends="farcry.fourq.fourq" hint="Rules is an abstract class that contains">
	<cfproperty name="objectID" type="uuid">
	<cfproperty name="label" type="nstring" default="">
	
	<cffunction name="createData" access="public" returntype="any" output="false" hint="Creates an instance of an object">
		<cfargument name="stProperties" type="struct" required="true" hint="Structure of properties for the new object instance">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#session.dmSec.authentication.userlogin#">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Created">
		<cfscript>
			var stNewObject = "";
			if(NOT structKeyExists(arguments.stProperties,"objectid"))
				arguments.stProperties.objectid = createUUID();
			stNewObject = super.createData(arguments.stProperties);
			application.factory.oAudit.logActivity(auditType="Create", username=arguments.user, location=cgi.remote_host, note=arguments.auditNote,objectid=stNewObject.objectid);
		</cfscript>
		<cfreturn stNewObject>
	</cffunction>
	
		
	<cffunction name="delete" access="public" hint="Basic delete method for all objects.">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#session.dmSec.authentication.userlogin#">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Deleted">
		<cfargument name="dsn" required="No" default="#application.dsn#"> 
		
		<cfscript>
			 super.deleteData(arguments.objectid,arguments.dsn);
			 application.factory.oAudit.logActivity(auditType="Delete", username=arguments.user, location=cgi.remote_host, note=arguments.auditNote,objectid=arguments.objectid);
		</cfscript>

	</cffunction>	
	
	<cffunction access="public" name="update" output="true">
		<cfargument name="label" required="no" type="string" default="">
		<cfoutput><p>#arguments[1]# : No Parameters required</cfoutput>
	</cffunction> 
	
	<cffunction access="public" name="execute" output="true">
		<cfargument name="label" required="no" type="string" default="">
		<cfoutput><p>#arguments[1]# : No execute method specified</cfoutput>
	</cffunction>  
	
	<cffunction access="public" name="getRules" returntype="query" hint="returns a single column query (column name 'rulename') of available rules. Assumes that rule names are rule*.cfc">
		
		<cfset var qRules = queryNew("rulename,bCustom")>
		<cfset var thisRow = 1>
		<cfset var qDir = ''>
		
		<!--- get all core rules --->
		<cfdirectory directory="#GetDirectoryFromPath(GetCurrentTemplatePath())#" name="qDir" filter="rule*.cfc" sort="name">
		<cfloop query="qDir">
			<cfif NOT name IS "rules.cfc"> <!--- Rules.cfc is the abstract class --->
				<cfset queryAddRow(qRules, 1)>
				<Cfset rulename = left(qDir.name, len(qDir.name)-4)>
				<cfset querySetCell(qRules,"rulename","#rulename#",thisRow)>
				<cfset querySetCell(qRules,"bCustom","0",thisRow)>
				<cfset thisRow = thisRow + 1>
			</cfif>
		</cfloop>
		
		<!--- get all custom rules from project rules directory --->
		<cfdirectory directory="#application.path.project#/packages/rules" name="qDir" filter="rule*.cfc" sort="name">
		<cfloop query="qDir">
			<cfset queryAddRow(qRules, 1)>
			<Cfset rulename = left(qDir.name, len(qDir.name)-4)>
			<cfset querySetCell(qRules,"rulename","#rulename#",thisRow)>
			<cfset querySetCell(qRules,"bCustom","1",thisRow)>
			<cfset thisRow = thisRow + 1>
		</cfloop>
						
		<cfreturn qRules>	
	</cffunction>
	
	
	
	<cffunction name="setData" access="public" output="false" hint="Update the record for an objectID including array properties.  Pass in a structure of property values; arrays should be passed as an array.">
		<cfargument name="stProperties" required="true">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#session.dmSec.authentication.userlogin#">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Updated">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
		<cfargument name="dsn" required="No" default="#application.dsn#"> 
				
		<cfset super.setData(arguments.stProperties,arguments.dsn)>
		<!--- log update --->
		<cfif arguments.bAudit>
			<cfset application.factory.oAudit.logActivity(auditType="Update", username=arguments.user, location=cgi.remote_host, note=arguments.auditNote,objectid=arguments.stProperties.objectid,dsn=arguments.dsn)>	
		</cfif>
	</cffunction>
	
	
	
</cfcomponent>