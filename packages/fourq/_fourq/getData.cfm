<!------------------------------------------------------------------------
getData() (fourQ COAPI)
 - included method
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/_fourq/getData.cfm,v 1.23 2005/06/08 01:53:38 guy Exp $
$Author: guy $
$Date: 2005/06/08 01:53:38 $
$Name:  $
$Revision: 1.23 $

Released Under the "Common Public License 1.0"
http://www.opensource.org/licenses/cpl.php

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
Get method to retrieve a record instance from the COAPI
------------------------------------------------------------------------->

<!--- 
$ TODO: GB
 - got to move metadata into a more persistent scope
 - some vars in here need to be var'd
$
 --->
<cfprocessingdirective pageencoding="utf-8">


<!--- IMPORT TAG LIBRARIES --->
<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />

<cfscript>
// get table name for db schema
	tablename = getTablename();
// get extended properties for this instance
	stTableDef = variables.tableMetadata.getTableDefinition();
// sql select statement list
	sqlSelect="";
</cfscript>




<cfloop list="#structKeyList(stTableDef)#" index="i">
	<cfif stTableDef[i].type neq "array">
		<cfif arguments.bShallow AND stTableDef[i].type eq "longchar">
			<!--- do nothing --->
		<cfelse>
			<!--- add property to select list --->
			<cfset sqlSelect = listAppend(sqlSelect, stTableDef[i].name)>
		</cfif>
	</cfif>
</cfloop>




<cftry>
	<cfquery datasource="#arguments.dsn#" name="qgetData">
		SELECT #sqlSelect# 
		FROM #arguments.dbowner##tablename#
		WHERE ObjectID = '#arguments.objectID#'
	</cfquery>
	
 	<cfcatch type="database">
		<!--- Looks like a property has not yet been deployed. If so, simply try a select * --->
		<farcry:logevent object="#arguments.objectID#" type="#arguments.dbowner##tablename#" event="getData" notes="Error running getdata(). #cfcatch.detail#"  />
		<cfquery datasource="#arguments.dsn#" name="qgetData">
			SELECT *
			FROM #arguments.dbowner##tablename#
			WHERE ObjectID = '#arguments.objectID#'
		</cfquery>
	</cfcatch>
</cftry>

<cfif qGetData.recordCount>
	<!--- convert query to structure --->
	<cfloop list="#qGetData.columnlist#" index="key">
		<!--- <cfset stObj[key]=qGetData[key]> bugged out with duplicate() 20050527GB --->
		<cfset stObj[key]=qGetData[key][1]>
	</cfloop>
	
	<!--- append typename to stObj --->
	<!--- 
	$ TODO: GB
	"typename" must be documented as a reserved property name 
	$
	--->
	<cfset stObj.typename = tablename>

	<!--- begin: process array data --->
	<!--- determine array properties --->
	<cfloop list="#structKeyList(stTableDef)#" index="i">
		<cfif stTableDef[i].type eq "array">
			<cfset key = stTableDef[i].name>
	
			<!--- getdata for array properties --->
			<cfquery datasource="#arguments.dsn#" name="qArrayData">
  			select * from #arguments.dbowner##tablename#_#key#
			where parentID = '#arguments.objectID#'
			order by seq
			</cfquery>
		
			<cfset SetVariable("#key#", ArrayNew(1))>
			<cfset aTmp = arrayNew(1) />

			<cfloop from="1" to="#qArrayData.recordcount#" index="j">
				<cfif (arguments.bFullArrayProps AND listlen(qArrayData.columnlist) GT 4) OR arguments.bArraysAsStructs>
			  		<!--- get extended array properties --->
			    	<cfset stArrayProp = structNew() />
			    	<cfloop list="#qArrayData.columnlist#" index="col">
			    		<cfset stArrayProp[col] = qArrayData[col][j] />
			    	</cfloop>
			    	<cfset arrayAppend(aTmp,stArrayProp) />
			  	<cfelse>
					<cfset ArrayAppend(aTmp, qArrayData.data[j])>
				</cfif>
			</cfloop>
			<cfset stObj[UCASE(key)] = aTmp>
		</cfif>
	</cfloop>
	
	
<cfelse>
	<!--- return an empty structure - indicating that record does not actually exist --->
	<cfset stObj = structNew()>

</cfif>
<!--- end: process array data --->


