
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/dmProfile.cfc,v 1.20.2.1 2006/01/09 09:34:59 geoff Exp $
$Author: geoff $
$Date: 2006/01/09 09:34:59 $
$Name: milestone_3-0-1 $
$Revision: 1.20.2.1 $

|| DESCRIPTION || 
$Description: Webskin Ancestors $

|| DEVELOPER ||
$Developer: Matthew Bryant (mbryant@daemon.com.au) $
--->
<cfcomponent extends="types" displayName="Webskin Ancestors" hint="Holds all the ancestor webskins of each webskin."
	bAudit="false">

    <!--- required properties --->	
    <cfproperty name="webskinObjectID" type="uuid" hint="The objectid of the webskin id we are defining the ancestor of" required="yes">
    <cfproperty name="ancestorTypename" type="string" hint="The typename of the ancestor webskin object" required="yes">
    <cfproperty name="ancestorID" type="uuid" hint="The objectid of the ancestor webskin object" required="yes">
    <cfproperty name="ancestorTemplate" type="string" hint="The webskin template name of the ancestor webskin" required="yes">


	<cffunction name="init" access="public" output="false" returntype="dmWebskinAncestor" hint="initialises the ancestor records currently assigned to the object that is passed in.">
		<cfargument name="webskinObjectID" type="UUID" required="true" hint="the objectid that you wish to retrieve the ancestors of." />
				
		<cfif not structKeyExists(variables, "webskinObjectID") OR variables.webskinObjectID NEQ arguments.webskinObjectID>
			
			<cfset variables.webskinObjectID = arguments.webskinObjectID />
			
			<cfquery datasource="#application.dsn#" name="variables.qCurrentAncestors">
			SELECT objectid,webskinObjectID,ancestorTypename,ancestorID,ancestorTemplate 
			FROM dmWebskinAncestor
			WHERE webskinObjectID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.webskinObjectID#">
			</cfquery>			
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	
	<cffunction name="getAncestorWebskins" access="public" output="true" returntype="query" hint="Returns query containing all ancestor templates currently exists in the webskinAncestor table for the current webskinID">
		<cfargument name="webskinObjectID" type="UUID" required="true" hint="the objectid of the webskin" />

		<cfset init(webskinObjectID=arguments.webskinObjectID) />
		
		<cfreturn variables.qCurrentAncestors />
	</cffunction>
		
	
	<cffunction name="checkAncestorExists" access="public" output="true" returntype="boolean" hint="Returns boolean as to whether the ancestor template currently exists in the webskinAncestor table.">
		<cfargument name="webskinObjectID" type="UUID" required="true" hint="the objectid of the webskin" />
		<cfargument name="ancestorID" type="UUID" required="true" hint="the objectid of the ancestor." />
		<cfargument name="ancestorTemplate" type="string" required="true" hint="The ancestor webskin template name." />
		
		<cfset var qExists = queryNew("blah") />
		<cfset var bExists = false />		
		
		<cfset init(webskinObjectID=arguments.webskinObjectID) />

		<cfquery dbtype="query" name="qExists">
		SELECT objectid 
		FROM variables.qCurrentAncestors
		WHERE ancestorID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ancestorID#">
		AND ancestorTemplate = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ancestorTemplate#">
		</cfquery>
		
		<cfif qExists.recordCount>
			<cfset bExists = true />
		</cfif>
		
		<cfreturn bExists />
	</cffunction>
	
		
</cfcomponent>