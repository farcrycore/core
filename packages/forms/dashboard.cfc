<!--- @@Copyright: Copyright (c) 2010 Daemon Pty Limited. All rights reserved. --->
<!--- @@displayname: dashboard --->
<!--- @@description: dashboard --->
<cfcomponent displayname="dashboard" output="false" extends="forms"
	hint="Overview dashboard for the webtop."
	bObjectBroker="true">

<!--- 
 // type properties 
--------------------------------------------------------------------------------------------------->
<!--- none i think --->

<!--- 
 // type methods
--------------------------------------------------------------------------------------------------->
<cffunction name="getDraftContent" returntype="query" access="public" output="true" hint="Return a query of draft content for the nominated user.">
	<cfargument name="ownedby" type="uuid" required="true" hint="The UUID for the profile that owns the draft content." />
	
	<cfset var qDraft = queryNew("objectid, label, typename, datetimelastupdated", "VARCHAR, VARCHAR, VARCHAR, DATE") />
	<cfset var qResult = queryNew("objectid, label, typename, datetimelastupdated", "VARCHAR, VARCHAR, VARCHAR, DATE") />
	<cfset var lTypes = "dmNews,dmHTML,dmEvent" />
	
	<cfloop list="#ltypes#" index="i">
	<cfquery name="qDraft" datasource="#application.dsn#">
	SELECT 
		objectid, label, '#i#' AS typename, datetimelastupdated
	FROM
		#i#
	WHERE 
		ownedby = '#arguments.ownedby#'
		AND status = 'draft'
	</cfquery>
	
	<cfquery name="qResult" dbtype="query">
		SELECT objectid, label, typename, datetimelastupdated FROM qDraft
		<cfif qResult.recordcount>
		UNION
		SELECT objectid, label, typename, datetimelastupdated FROM qResult
		ORDER BY datetimelastupdated DESC
		</cfif>
	</cfquery>
	</cfloop>
	
	<cfreturn qResult />
	
</cffunction>

<cffunction name="getContentForReview" returntype="query" access="public" output="true" hint="Return a query of content past its review date for the nominated user.">
	<cfargument name="ownedby" type="uuid" required="true" hint="The UUID for the profile that owns the draft content." />
	
	<cfset var qReview = queryNew("objectid, label, typename, datetimelastupdated, reviewdate", "VARCHAR, VARCHAR, VARCHAR, DATE, DATE") />
	<cfset var qResult = queryNew("objectid, label, typename, datetimelastupdated, reviewdate", "VARCHAR, VARCHAR, VARCHAR, DATE, DATE") />
	<cfset var lTypes = "dmHTML" />
	
	<cfloop list="#ltypes#" index="i">
	<cfquery name="qReview" datasource="#application.dsn#">
	SELECT 
		objectid, label, '#i#' AS typename, datetimelastupdated, reviewdate
	FROM
		#i#
	WHERE 
		ownedby = '#arguments.ownedby#'
		AND status = 'approved'
		AND reviewdate < #now()#
	ORDER BY reviewdate DESC
	</cfquery>
	
	<cfquery name="qResult" dbtype="query">
		SELECT objectid, label, typename, datetimelastupdated, reviewdate FROM qReview
		<cfif qResult.recordcount>
		UNION
		SELECT objectid, label, typename, datetimelastupdated, reviewdate FROM qResult
		ORDER BY reviewdate DESC
		</cfif>
	</cfquery>
	</cfloop>
	
	<cfreturn qResult />
	
</cffunction>

<cffunction name="getPendingContent" returntype="query" access="public" output="true" hint="Return a query of draft content for the nominated user.">
	<cfargument name="ownedby" type="uuid" required="true" hint="The UUID for the profile that owns the draft content." />
	
	<cfset var qDraft = queryNew("objectid, label, typename, datetimelastupdated", "VARCHAR, VARCHAR, VARCHAR, DATE") />
	<cfset var qResult = queryNew("objectid, label, typename, datetimelastupdated", "VARCHAR, VARCHAR, VARCHAR, DATE") />
	<cfset var lTypes = "dmNews,dmHTML,dmEvent" />
	
	<cfloop list="#ltypes#" index="i">
	<cfquery name="qPending" datasource="#application.dsn#">
	SELECT 
		objectid, label, '#i#' AS typename, datetimelastupdated
	FROM
		#i#
	WHERE 
		status = 'pending'
	</cfquery>
	
	<cfquery name="qResult" dbtype="query">
		SELECT objectid, label, typename, datetimelastupdated FROM qPending
		<cfif qResult.recordcount>
		UNION
		SELECT objectid, label, typename, datetimelastupdated FROM qResult
		</cfif>
	</cfquery>
	</cfloop>
	
	<cfreturn qResult />
	
</cffunction>

<cffunction name="getRecentActivity" returntype="query" access="public" output="true" hint="Return a query of recent activity from comments.">
	
	<cfset var qResult = queryNew("objectid") />
	
	<cfquery name="qResult" datasource="#application.dsn#" maxrows="10">
		SELECT object, notes, event, datetimelastupdated FROM farLog
		WHERE 
			event = 'comment'
			OR event LIKE 'to%'
		ORDER BY datetimecreated DESC
	</cfquery>
	
	<cfreturn qResult />
	
</cffunction>

</cfcomponent>