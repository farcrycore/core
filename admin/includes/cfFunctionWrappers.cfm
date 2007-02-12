<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/farcry_core/fourq/tags/" prefix="q4">


<cffunction name="contentobjectget" hint="wrapper to the fourq tag - contentobjectget">
	<cfargument name="objectID" required="true" type="uuid">
	<cfargument name="typename" required="false">
	<cfset var stObj = structNew()>
	<q4:contentobjectget objectId="#arguments.ObjectId#" bActiveOnly="0" r_stObject="stObj">
	<cfreturn stObj>
</cffunction>

<cffunction name="contentobjectdata">
	<cfargument name="objectid" required="true">
	<cfargument name="typename" required="true">
	<cfargument name="stProperties" required="true">
	
	<q4:contentobjectdata objectid="#arguments.objectID#" typename="arguments.typename" stProperties="#arguments.stProperties#">
</cffunction>


<cffunction name="throwerror" hint="a wrapper for cfthrowerror">
	<cfargument name="detail" required="true" hint="Error detail">
	<cfargument name="errorcode" required="false">

	<cfthrow detail="#arguments.detail#"  errorcode="#arguments.errorcode#">
</cffunction>

<cffunction name="query" hint="a wrapper for cfquery tag for use in cfscript">
	<cfargument name="sql" type="string" required="true">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfset var q = ''>
		
	<cfquery name="q" datasource="#arguments.dsn#">
		#preserveSingleQuotes(arguments.sql)#
	</cfquery>
	
	<!--- This is so we always return a query object - ie update statements may not return a result --->
	<cftry>
		<cfif q.recordcount>
			<!--- blah --->
		</cfif>	
		<cfcatch>
			<cfset q = queryNew('acoloumn')>
		</cfcatch>

	</cftry>
	
	<cfreturn q>
</cffunction>


<cffunction name="queryofquery" hint="a wrapper for cfquery of queries for use in cfscript">
	<cfargument name="sql" type="string" required="true">
	<cfargument name="maxrows" type="string" required="false">
	<cfset var q = ''>
	
	 <cfif isDefined("arguments.maxrows")>
	 	<cfquery name="q" dbtype="query" maxrows="#arguments.maxrows#">
			#preserveSingleQuotes(arguments.sql)#
		</cfquery>
	<cfelse>		
		<cfquery name="q" dbtype="query" >
			#preserveSingleQuotes(arguments.sql)#
		</cfquery>
	</cfif>	
	<cfreturn q>
</cffunction>

<cffunction name="queryofquery2" hint="a wrapper for cfquery of queries for use in cfscript - cmfx 7 compatible">
	<cfargument name="selectclause" type="string" required="true">
	<cfargument name="tablename"  type="query" required="true">
	<cfargument name="whereclause" type="string" required="false">
	<cfargument name="orderbyclause" type="string" required="false">	
	<cfargument name="maxrows" type="string" required="false">
	
	<cfset var q = ''>
	<cfset var sql = "">
	<cfsavecontent variable="sql">
		<cfoutput>
		#arguments.selectclause#
		FROM arguments.tablename
		<cfif isDefined("arguments.whereclause")>
			#arguments.whereclause#
		</cfif>
		<cfif isDefined("arguments.orderbyclause")>
			#arguments.orderbyclause#
		</cfif>
		</cfoutput>
	</cfsavecontent>
		
	
	<cftry>
		<cfif isDefined("arguments.maxrows")>
		 	<cfquery name="q" dbtype="query" maxrows="#arguments.maxrows#">
			#preserveSingleQuotes(sql)#
			</cfquery>
		<cfelse>		
			<cfquery name="q" dbtype="query" >
			#preserveSingleQuotes(sql)#
			</cfquery>
		</cfif>
		<cfcatch>
			<cfdump var="#cfcatch#">
		</cfcatch>
	</cftry>
		
	<cfreturn q>
</cffunction>




<cffunction name="dump" hint="wrapper for cfdump">
	<cfargument name="object" required="true">
	<cfargument name="label" required="false" default="">
	<!--- reset dump variable in request scope to try cf into thinking it hasn't already dumped on the page --->
	<cfset request.cfdumpinited = false>
	<cfdump var="#arguments.object#" label="#arguments.label#">
</cffunction>

<cffunction name="abort" hint="wrapper for cfdump">
	<cfabort>
</cffunction>


<cffunction name="flush" hint="wrapper for cfflush">
	<cfflush>
</cffunction>

<cffunction name="location" hint="wrapper for cflocation">
	<cfargument name="url" required="true">
	<cfargument name="addtoken" required="false" default="no">
	
	<cflocation url="#arguments.url#" addtoken="#arguments.addtoken#">

</cffunction>

<cffunction name="updateTree">
	<cfargument name="objectid" required="true">
	<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
	<nj:updateTree objectId="#arguments.objectid#">
</cffunction>

<cffunction name="trace">
	<cfargument name="var">
	
	<cftrace inline="no" var="#arguments.var#">
</cffunction>



