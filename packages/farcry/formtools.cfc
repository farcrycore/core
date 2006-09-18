<cfcomponent displayname="FormTools" hint="All the methods required to run Farcry Form Tools">


<cffunction name="getRecordset" access="public" output="No" returntype="struct">
	<cfargument name="typename" required="No" type="string" default="" />
	<cfargument name="identityColumn" required="No" type="string" default="ObjectID" />
	<cfargument name="sqlColumns" required="No" type="string" default="objectid" />
	<cfargument name="sqlWhere" required="No" type="string" default="" />
	<cfargument name="sqlOrderBy" required="No" type="string" default="label" />
	
	<cfargument name="CurrentPage" required="No" type="numeric" default="1" />
	<cfargument name="RecordsPerPage" required="No" type="numeric" default="5" />
	<cfargument name="PageLinksShown" required="No" type="numeric" default="10" />
	
	<cfset var stReturn = structNew() />
	<cfset var q = '' />
	<cfset var recordcount = '' />
	
	<cfif NOT len(arguments.sqlWhere)>
		<cfset arguments.sqlWhere = "0=0" />
	</cfif>

	<cftimer label="cfstoredproc">
	<!--- query --->
	<cfstoredproc procedure="sp_selectnextn" datasource="#application.dsn#">
	    <cfprocresult name="q" resultset="1">
	    <cfprocresult name="recordcount" resultset="2">
	     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="TableName"  value="#arguments.typename#">
	     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="Columns" value="#arguments.sqlColumns#">
	     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="IdentityColumn" value="#arguments.identityColumn#">
	     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="GroupNumber" value="#arguments.CurrentPage#">
	     <cfprocparam type="In"  cfsqltype="CF_SQL_VARCHAR" dbvarname="GroupSize" value="#arguments.recordsPerPage#">
	     <cfprocparam type="In" cfsqltype="CF_SQL_LONGVARCHAR" dbvarname="SqlWhere" value="#arguments.SqlWhere#">
	     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="SqlOrderBy" value="#arguments.sqlOrderBy#">
	</cfstoredproc>
	</cftimer>
	
	<!------------------------------
	DETERMINE THE TOTAL PAGES
	 ------------------------------>
	<cfif isNumeric(recordcount.countAll) AND recordcount.countAll GT 0>
		<cfset stReturn.TotalPages = ceiling(recordcount.countAll / arguments.RecordsPerPage)>
	<cfelse>
		<cfset stReturn.TotalPages = 0>
	</cfif>
		
	<!------------------------------
	IF THE CURRENT PAGE IS GREATER THAN THE TOTAL PAGES, REDO THE RECORDSET FOR PAGE 1
	 ------------------------------>		
	<cfif arguments.CurrentPage GT stReturn.TotalPages and arguments.CurrentPage GT 1>
		
		<cfset arguments.CurrentPage = 1 />
		
		<!--- query --->
		<cfstoredproc procedure="sp_selectnextn" datasource="#application.dsn#">
		    <cfprocresult name="q" resultset="1">
		    <cfprocresult name="recordcount" resultset="2">
		     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="TableName"  value="#arguments.typename#">
		     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="Columns" value="#arguments.sqlColumns#">
		     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="IdentityColumn" value="objectid">
		     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="GroupNumber" value="#arguments.CurrentPage#">
		     <cfprocparam type="In"  cfsqltype="CF_SQL_VARCHAR" dbvarname="GroupSize" value="#arguments.recordsPerPage#">
		     <cfprocparam type="In" cfsqltype="CF_SQL_LONGVARCHAR" dbvarname="SqlWhere" value="#arguments.SqlWhere#">
		     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="SqlOrderBy" value="#arguments.sqlOrderBy#">
		</cfstoredproc>
	</cfif>			
	
	<cfif isNumeric(recordcount.countAll) AND recordcount.countAll GT 0>
		<cfset stReturn.TotalPages = ceiling(recordcount.countAll / arguments.RecordsPerPage)>
	<cfelse>
		<cfset stReturn.TotalPages = 0>
	</cfif>
	
	
	<!--- NOW THAT WE HAVE OUR QUERY, POPULATE THE RETURN STRUCTURE --->
	<cfset stReturn.q = q />
	<cfset stReturn.countAll = recordcount.countAll />
	<cfset stReturn.CurrentPage = arguments.CurrentPage />
	
	
	<cfset stReturn.Startpage = 1>
	<cfset stReturn.PageLinksShown = min(arguments.PageLinksShown, stReturn.TotalPages)>
	
	<cfif stReturn.CurrentPage + int(stReturn.PageLinksShown / 2) - 1 GTE stReturn.TotalPages>
		<cfset stReturn.StartPage = stReturn.TotalPages - stReturn.PageLinksShown + 1>
	<cfelseif stReturn.CurrentPage + 1 GT stReturn.PageLinksShown>
		<cfset stReturn.StartPage = stReturn.CurrentPage - int(stReturn.PageLinksShown / 2)>
	</cfif>
	
	<cfset stReturn.Endpage = stReturn.StartPage + stReturn.PageLinksShown - 1>
		
	<cfset stReturn.RecordsPerPage = arguments.RecordsPerPage />
	<cfset stReturn.typename = arguments.typename />
     
	<cfreturn stReturn />
</cffunction>

<cffunction name="getRecordSetObject" access="public" output="false" returntype="Array" hint="This function accepts a recordset and will return a Faux Farcry Array of Object Structure that will enable it to run through ft:object without requiring a getData.">

	<cfargument name="recordset" type="query" required="true">
	<cfargument name="typename" type="string" required="false" default="">	

	<cfset var arResult = arrayNew(1) />
	
	<cfset var lArrayProps = "">
	<cfset var stPropsQueries = structNew()>
		
	<cfset stResult.typename = arguments.typename />
	
	<!--- check if any array property is required --->
	
	<cfloop list="#arguments.recordset.columnlist#" index="i">
		<cfif application.types[arguments.typename].stProps[i].metadata.type EQ "array">
			<cfset listAppend(lArrayProps,application.types[arguments.typename].stProps[i])>
		</cfif>
	</cfloop>
	
	
	
	<cfif lArrayProps neq "">
		<cfset lObjectIDs = valueList(arguments.recordset.objectId)>
	
		
		<cfloop list="#lArrayProps#" index="arPropName">
			<!--- get all relational items id of all instances and store in a struct with the property name as a the key  --->
			<cfquery datasource="#arguments.dsn#" name="qArrayData">
					select parentID, data from #arguments.typename#_#arPropName#
					where parentID in (#listQualify(lObjectIDs,"'")#)
					order by parentID, seq
			</cfquery>
			<cfoutput query="qArrayData" group="parentID">
				<cfif not structKeyExists(stPropsQueries,parentID)>
					<cfset stPropsQueries[parentID] = structNew>
				</cfif>				
				<cfset stPropsQueries[parentID][arPropName] = arrayNew(1)>
				<cfoutput>
					<cfset arrayAppend(stPropsQueries[parentID][arPropName],data)>
				</cfoutput>
			</cfoutput>
		</cfloop>
	
	</cfif>
	
	
	
	
	<cfloop query="arguments.recordset">
	
		<cfset tmpSt = structNew()>
		<cfset tmpSt.typeName = arguments.typename>
		<cfloop list="#arguments.recordset.columnlist#" index="i">	
			<cfif application.types[arguments.typename].stProps[i].metadata.type NEQ "array">
				<cfset tmpSt[i] = arguments.recordset[i][arguments.recordset.currentRow]>			
			</cfif>
		</cfloop>
		
		<cfif not structIsEmpty(stPropsQueries)>
			<cfloop collection="#stPropsQueries[recordset.objectID]#" item="arPropName">
				<cfset tmpSt[arPropName] = stPropsQueries[recordset.objectID][arPropName]>
			</cfloop>
		</cfif>
		
		<cfset arrayAppend(arResult,tmpSt) />
	</cfloop>
	<cfreturn arResult />
</cffunction>


</cfcomponent> 