<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2004, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/rules/rules.cfc,v 1.8 2004/01/15 00:42:54 tom Exp $
$Author: tom $
$Date: 2004/01/15 00:42:54 $
$Name: milestone_2-1-2 $
$Revision: 1.8 $

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
	
	<cffunction access="public" name="update" output="true">
		<cfargument name="label" required="no" type="string" default="">
		<cfoutput><p>#arguments[1]# : No Parameters required</cfoutput>
	</cffunction> 
	
	<cffunction access="public" name="execute" output="true">
		<cfargument name="label" required="no" type="string" default="">
		<cfoutput><p>#arguments[1]# : No execute method specified</cfoutput>
	</cffunction>  
	
	<cffunction access="public" name="getRules" returntype="query" hint="returns a single column query (column name 'rulename') of available rules. Assumes that rule names are rule*.cfc">
		<!--- get all core rules --->
		<cfdirectory directory="#GetDirectoryFromPath(GetCurrentTemplatePath())#" name="qDir" filter="rule*.cfc" sort="name">
		<cfset qRules = queryNew("rulename,bCustom")>
		<cfset thisRow = 1>
		<cfloop query="qDir">
			<cfif NOT name IS "rules.cfc"> <!--- Rules.cfc is the abstract class --->
				<cfset newRow  = queryAddRow(qRules, 1)>
				<Cfset rulename = left(qDir.name, len(qDir.name)-4)>
				<cfset newCell = querySetCell(qRules,"rulename","#rulename#",thisRow)>
				<cfset newCell = querySetCell(qRules,"bCustom","0",thisRow)>
				<cfset thisRow = thisRow + 1>
			</cfif>
		</cfloop>
		
		<!--- get all custom rules from project rules directory --->
		<cfdirectory directory="#application.path.project#/packages/rules" name="qDir" filter="rule*.cfc" sort="name">
			<cfloop query="qDir">
				<cfset newRow  = queryAddRow(qRules, 1)>
				<Cfset rulename = left(qDir.name, len(qDir.name)-4)>
				<cfset newCell = querySetCell(qRules,"rulename","#rulename#",thisRow)>
				<cfset newCell = querySetCell(qRules,"bCustom","1",thisRow)>
				<cfset thisRow = thisRow + 1>
			</cfloop>
						
		<cfreturn qRules>	
	</cffunction>
	
</cfcomponent>