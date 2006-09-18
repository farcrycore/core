<cfcomponent displayname="FormTools" hint="All the methods required to run Farcry Form Tools">


<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >


<cffunction name="getRecordsetObject" access="public" output="false" returntype="struct" hint="This function accepts a recordset and will return a Faux Farcry Object Structure that will enable it to run through ft:object without requiring a getData.">

	<cfargument name="recordset" type="query" required="false">
	<cfargument name="row" type="numeric" required="false">		
	<cfargument name="typename" type="string" required="false" default="">	
	
	<cfset var i = "" />
	<cfset var j = "" />
	<cfset var key = "" />
	<cfset var aTmp = arrayNew(1) />
	<cfset var stResult = structNew() />
	<cfset var st = structNew() />
	
	<cfset stResult.typename = arguments.typename />
	
	<cfloop list="#arguments.recordset.columnlist#" index="i">
		<cfif application.types[arguments.typename].stProps[i].metadata.type NEQ "array">
			<cfset stResult[i] = recordset[i][row] />
		<cfelse>
			<cfset stResult[i] = arrayNew(1) />
			
			<cfif listContains(arrayprops, i)>								
				<cfset key = i>
					
				<!--- getdata for array properties --->
				<cfquery datasource="#arguments.dsn#" name="qArrayData">
	  			select * from #arguments.dbowner##tablename#_#key#
				where parentID = '#recordset.objectID[arguments.row]#'
				order by seq
				</cfquery>
				<!--- 	<cfset qArrayData = queryNew("parentID,Data,seq,typename")> --->
				<cfset SetVariable("#key#", ArrayNew(1))>
				<cfset aTmp = arrayNew(1) />
	
				<cfloop from="1" to="#qArrayData.recordcount#" index="j">
					<cfset ArrayAppend(aTmp, qArrayData.data[j])>
				</cfloop>
				<cfset stResult[key] = aTmp>
															
			</cfif>
		</cfif>
	</cfloop>

	<cfreturn stResult />
</cffunction>


</cfcomponent> 