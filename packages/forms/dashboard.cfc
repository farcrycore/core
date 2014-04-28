<!--- @@Copyright: Copyright (c) 2010 Daemon Pty Limited. All rights reserved. --->
<!--- @@displayname: dashboard --->
<!--- @@description: dashboard --->
<cfcomponent displayname="dashboard" output="false" extends="forms"
  hint="Miscellaneous, cross type content for webtop dashboards."
  bObjectBroker="true">

<!--- 
 // type properties 
--------------------------------------------------------------------------------------------------->
<!--- none i think --->

<!--- 
 // type methods
--------------------------------------------------------------------------------------------------->
<cffunction name="getDraftContent" returntype="query" access="public" output="false" hint="Return a query of draft content for the nominated user.">
  <cfargument name="ownedby" type="uuid" required="false" hint="The UUID for the profile that owns the draft content." />
  <cfargument name="lastupdatedby" type="string" required="false" hint="The user name of the last person that updated the record" />
  <cfargument name="lTypes" type="string" required="false" hint="A list of type names to check against" default="dmNews,dmHTML,dmEvent" />
  <cfargument name="dsn" type="string" required="false" default="#application.dsn#" />
  <cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#" />

  <cfset var qDraft = queryNew("objectid, label, typename, datetimelastupdated", "VARCHAR, VARCHAR, VARCHAR, DATE") />
  <cfset var qResult = queryNew("objectid, label, typename, datetimelastupdated", "VARCHAR, VARCHAR, VARCHAR, DATE") />
  <cfset var stTypeMetadata = structNew() />
  <cfset var i = "" />

  <cfloop list="#arguments.lTypes#" index="i">
    <cftry>
      <!--- Get type metadata so that we can check below if it exists before getting a DB error --->
      <cfset stTypeMetadata = application.fapi.getContentTypeMetadata(typename=i) />
      <!--- Only return items: that have a status field --->
      <cfif structKeyExists(stTypeMetadata.stProps, "status")>
        <cfquery name="qDraft" datasource="#arguments.dsn#">
          SELECT objectid, label, '#i#' AS typename, datetimelastupdated
          FROM #arguments.dbowner##i#
          WHERE
            status = <cfqueryparam cfsqltype="cf_sql_varchar" value="draft" />
            <cfif structKeyExists(arguments, "ownedby") AND arguments.ownedby neq "" AND structKeyExists(stTypeMetadata.stProps, "ownedby")>
              AND ownedby = <cfqueryparam cfsqltype="cf_sql_varchar" maxLength="35" value="#arguments.ownedby#" /></cfif>
            <cfif structKeyExists(arguments, "lastupdatedby") AND arguments.lastupdatedby neq "" AND structKeyExists(stTypeMetadata.stProps, "lastupdatedby")>
              AND lastupdatedby = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.lastupdatedby)#" /></cfif>
        </cfquery>
      </cfif>

      <cfquery name="qResult" dbtype="query">
        SELECT objectid, label, typename, datetimelastupdated FROM qDraft
        <cfif qResult.recordcount>
        UNION
        SELECT objectid, label, typename, datetimelastupdated FROM qResult
        ORDER BY datetimelastupdated DESC
        </cfif>
      </cfquery>
    <cfcatch></cfcatch>
    </cftry>
  </cfloop>
  
  <cfreturn qResult />

</cffunction>

<cffunction name="getContentForReview" returntype="query" access="public" output="false" hint="Return a query of content past its review date for the nominated user.">
  <cfargument name="ownedby" type="uuid" required="true" hint="The UUID for the profile that owns the draft content." />
  <cfargument name="lTypes" type="string" required="false" hint="A list of type names to check against" default="dmNews,dmHTML,dmEvent" />
  <cfargument name="dsn" type="string" required="false" default="#application.dsn#" />
  <cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#" />

  <cfset var qReview = queryNew("objectid, label, typename, datetimelastupdated, reviewdate", "VARCHAR, VARCHAR, VARCHAR, DATE, DATE") />
  <cfset var qResult = queryNew("objectid, label, typename, datetimelastupdated, reviewdate", "VARCHAR, VARCHAR, VARCHAR, DATE, DATE") />
  <cfset var stTypeMetadata = structNew() />
  <cfset var i = "" />

  <cfloop list="#arguments.lTypes#" index="i">
    <cftry>
      <!--- Get type metadata so that we can check below if it exists before getting a DB error --->
      <cfset stTypeMetadata = application.fapi.getContentTypeMetadata(typename=i) />
      <!--- Only return items: the user owns, that have review dates --->
      <cfif arguments.ownedby neq "" AND structKeyExists(stTypeMetadata.stProps, "ownedby") AND structKeyExists(stTypeMetadata.stProps, "reviewdate")>
        <cfquery name="qReview" datasource="#arguments.dsn#">
          SELECT objectid, label, '#i#' AS typename, datetimelastupdated, reviewdate
          FROM #arguments.dbowner##i#
          WHERE
            ownedby = <cfqueryparam cfsqltype="cf_sql_varchar" maxLength="35" value="#arguments.ownedby#" />
            AND reviewdate < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#" />
            <cfif structKeyExists(stTypeMetadata.stProps, "status")>
              AND status = <cfqueryparam cfsqltype="cf_sql_varchar" value="approved" /></cfif>
          ORDER BY reviewdate DESC
        </cfquery>
      </cfif>

      <cfquery name="qResult" dbtype="query">
        SELECT objectid, label, typename, datetimelastupdated, reviewdate FROM qReview
        <cfif qResult.recordcount>
        UNION
        SELECT objectid, label, typename, datetimelastupdated, reviewdate FROM qResult
        ORDER BY reviewdate DESC
        </cfif>
      </cfquery>
    <cfcatch></cfcatch>
    </cftry>
  </cfloop>

  <cfreturn qResult />
  
</cffunction>

<cffunction name="getPendingContent" returntype="query" access="public" output="false" hint="Return a query of draft content for the nominated user.">
  <cfargument name="ownedby" type="uuid" required="false" hint="The UUID for the profile that owns the draft content." />
  <cfargument name="lTypes" type="string" required="false" hint="A list of type names to check against" default="dmNews,dmHTML,dmEvent" />
  <cfargument name="dsn" type="string" required="false" default="#application.dsn#" />
  <cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#" />

  <cfset var qPending = queryNew("objectid, label, typename, datetimelastupdated", "VARCHAR, VARCHAR, VARCHAR, DATE") />
  <cfset var qResult = queryNew("objectid, label, typename, datetimelastupdated", "VARCHAR, VARCHAR, VARCHAR, DATE") />
  <cfset var stTypeMetadata = structNew() />
  <cfset var i = "" />

  <cfloop list="#arguments.ltypes#" index="i">
    <cftry>
      <!--- Get type metadata so that we can check below if it exists before getting a DB error --->
      <cfset stTypeMetadata = application.fapi.getContentTypeMetadata(typename=i) />
      <!--- Only return items: that have a status field --->
      <cfif structKeyExists(stTypeMetadata.stProps, "status")>
        <cfquery name="qPending" datasource="#arguments.dsn#">
          SELECT objectid, label, '#i#' AS typename, datetimelastupdated
          FROM #arguments.dbowner##i#
          WHERE 
            status = <cfqueryparam cfsqltype="cf_sql_varchar" value="pending" />
            <cfif structKeyExists(arguments, "ownedby") AND arguments.ownedby neq "" AND structKeyExists(stTypeMetadata.stProps, "ownedby")>
              AND ownedby = <cfqueryparam cfsqltype="cf_sql_varchar" maxLength="35" value="#arguments.ownedby#" /></cfif>
        </cfquery>

        <cfquery name="qResult" dbtype="query">
          SELECT objectid, label, typename, datetimelastupdated FROM qPending
          <cfif qResult.recordcount>
          UNION
          SELECT objectid, label, typename, datetimelastupdated FROM qResult
          </cfif>
        </cfquery>
      </cfif>
    <cfcatch></cfcatch>
    </cftry>
  </cfloop>

  <cfreturn qResult />
  
</cffunction>

<cffunction name="getRecentActivity" returntype="query" access="public" output="false" hint="Return a query of recent activity from comments.">
  <cfargument name="maxrows" type="numeric" required="false" default="10" hint="Maxrows to return. Set -1 for all" />
  <cfargument name="dsn" type="string" required="false" default="#application.dsn#" />
  <cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#" />

  <cfset var qResult = queryNew("objectid") />

  <cfquery name="qResult" datasource="#arguments.dsn#" maxrows="#arguments.maxrows#">
    SELECT object, notes, event, datetimelastupdated, userid
    FROM #arguments.dbowner#farLog
    WHERE
      event = <cfqueryparam cfsqltype="cf_sql_varchar" value="comment" />
      OR event LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="to%" />
    ORDER BY datetimecreated DESC
  </cfquery>

  <cfreturn qResult />

</cffunction>

</cfcomponent>