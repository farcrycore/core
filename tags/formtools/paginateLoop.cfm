<cfsetting enablecfoutputonly="yes">

<!--- 
|| LEGAL ||
$Copyright: Daemon Internet 2002-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header:  $
$Author: $
$Date:  $
$Name:  $
$Revision: $

|| DESCRIPTION || 
$Description:  -- $


|| DEVELOPER ||
$Developer: Matthew Bryant (mat@daemon.com.au)$

|| ATTRIBUTES ||
$in: objectid -- $
--->


<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >


<cfif thistag.executionMode eq "Start">

	
	<!--- Get the BaseTagData  --->
	<cfset PaginateData = getBaseTagData("cf_pagination")>
	<cfset structAppend(attributes, PaginateData.attributes,false) />

	<cfparam name="attributes.r_stObject" default="stObject">
	<cfparam name="attributes.editWebskin" default="edit">
	<cfparam name="attributes.CustomList" default="#caller.attributes.typename#">
	
	<cfparam name="variables.currentRow" default="1" />
	
	<cfset o = createObject("component", application.types[caller.attributes.typename].typepath) />

	<cfif len(attributes.r_stobject) and variables.currentRow LTE attributes.totalRecords AND attributes.totalRecords>

		<cfset caller[attributes.r_stobject] = structNew() />
		<cfset caller[attributes.r_stobject].stFields = getRecordsetObject(recordset=caller.stRecordset.q, row=variables.currentRow, typename=caller.attributes.typename) />
		<!---<cfset caller[attributes.r_stobject] = o.getdata(bUseInstanceCache=false, objectid=attributes.stParams.q.objectid[variables.currentrow], typename=attributes.stParams.typename, recordset=attributes.stParams.q, row=variables.currentRow) /> --->
		
		<cfset caller[attributes.r_stobject].select = "<input type='checkbox' name='objectid' value='#caller.stRecordset.q.objectid[variables.currentRow]#' onclick='setRowBackground(this);' style='width:10px;' />" />
		<cfset caller[attributes.r_stobject].currentRow = (attributes.CurrentPage - 1) * attributes.RecordsPerPage + variables.currentRow />

		<cfif caller.stRecordset.q.locked[variables.currentRow] AND caller.stRecordset.q.lockedby[variables.currentRow] eq '#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#'>
			<cfset caller[attributes.r_stObject].editLink = "<span style='color:red'>Locked</span>" />		
		<cfelse>
			<cfset caller[attributes.r_stObject].editLink = "<a href='#application.url.farcry#/conjuror/invocation.cfm?objectid=#caller.stRecordset.q.objectid[variables.currentrow]#&typename=#caller.attributes.typename#&method=#attributes.editWebskin#&ref=typeadmin&module=customlists/#attributes.customList#.cfm'><img src='#application.url.farcry#/images/treeImages/edit.gif' alt='Edit' title='Edit' /></a>" />
		</cfif>
		
		<cfset caller[attributes.r_stObject].viewLink = "<a href='#application.url.webroot#/index.cfm?objectID=#caller.stRecordset.q.objectid[variables.currentrow]#&flushcache=1' target='_blank'><img src='#application.url.farcry#/images/treeImages/preview.gif' alt='View' title='View' /></a>" />
		<cfset caller[attributes.r_stObject].flowLink = "<a href='#application.farcrylib.flow.url#/?startid=#caller.stRecordset.q.objectid[variables.currentrow]#&flushcache=1' target='_blank'><img src='#application.url.farcry#/images/treeImages/preview.gif' alt='flow' title='flow' /></a>" />
		<cfset variables.currentRow = variables.CurrentRow + 1 />
	<cfelse>
		<cfexit method="exittag" />
	</cfif>
	
	
</cfif>

<cfif thistag.executionMode eq "End">


	<cfif len(attributes.r_stobject) and variables.currentRow LTE caller.stRecordset.q.RecordCount>
		
		<cfset caller[attributes.r_stobject] = structNew() />
		<cfset caller[attributes.r_stobject].stFields = getRecordsetObject(recordset=caller.stRecordset.q, row=variables.currentRow, typename=caller.attributes.typename) />
		<!---<cfset caller[attributes.r_stobject] = o.getdata(bUseInstanceCache=false, objectid=caller.stRecordset.q.objectid[variables.currentrow], typename=caller.attributes.typename, recordset=caller.stRecordset.q, row=variables.currentRow) /> --->
		
		<cfset caller[attributes.r_stobject].select = "<input type='checkbox' name='objectid' value='#caller.stRecordset.q.objectid[variables.currentRow]#' onclick='setRowBackground(this);' style='width:10px;' />" />
		<cfset caller[attributes.r_stobject].currentRow = (attributes.CurrentPage - 1) * attributes.RecordsPerPage + variables.currentRow />		
		<cfif caller.stRecordset.q.locked[variables.currentRow] AND caller.stRecordset.q.lockedby[variables.currentRow] eq '#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#'>
			<cfset caller[attributes.r_stObject].editLink = "<span style='color:red'>Locked</span>" />		
		<cfelse>
			<cfset caller[attributes.r_stObject].editLink = "<a href='#application.url.farcry#/conjuror/invocation.cfm?objectid=#caller.stRecordset.q.objectid[variables.currentrow]#&typename=#caller.attributes.typename#&method=#attributes.editWebskin#&ref=typeadmin&module=customlists/#attributes.customList#.cfm'><img src='#application.url.farcry#/images/treeImages/edit.gif' alt='Edit' title='Edit' /></a>" />
		</cfif>
		<cfset caller[attributes.r_stObject].viewLink = "<a href='#application.url.webroot#/index.cfm?objectID=#caller.stRecordset.q.objectid[variables.currentrow]#&flushcache=1' target='_blank'><img src='#application.url.farcry#/images/treeImages/preview.gif' alt='View' title='View' /></a>" />
		<cfset caller[attributes.r_stObject].flowLink = "<a href='#application.farcrylib.flow.url#/?startid=#caller.stRecordset.q.objectid[variables.currentrow]#&flushcache=1' target='_blank'><img src='#application.url.farcry#/images/treeImages/preview.gif' alt='flow' title='flow' /></a>" />
				
		<cfset variables.currentRow = variables.CurrentRow + 1 />
		<cfexit method="loop" />
	</cfif>

</cfif>

<cfsetting enablecfoutputonly="no">


<cffunction name="getRecordsetObject" access="private" output="false" returntype="struct" hint="This function accepts a recordset and will return a Faux Farcry Object Structure that will enable it to run through ft:object without requiring a getData.">

	<cfargument name="recordset" type="query" required="false">
	<cfargument name="row" type="numeric" required="false">		
	<cfargument name="typename" type="string" required="false" default="">	
	
	<cfset var i = "" />
	<cfset var j = "" />
	<cfset var key = "" />
	<cfset var aTmp = arrayNew(1) />
	<cfset var stTmp = structNew() />
	<cfset var st = structNew() />
	
	<cfset stTmp.typename = arguments.typename />
	
	<cfloop list="#arguments.recordset.columnlist#" index="i">
		<cfif application.types[arguments.typename].stProps[i].metadata.type NEQ "array">
			<cfset stTmp[i] = recordset[i][row] />
		<cfelse>
			<cfset stTmp[i] = arrayNew(1) />
			
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
				<cfset stTmp[key] = aTmp>
															
			</cfif>
		</cfif>
	</cfloop>

	<ft:object stobject="#stTmp#" typename="#arguments.typename#" lFields="#arguments.recordset.columnlist#" lExcludeFields="" bIncludeSystemProperties="true" format="display" includeFieldSet="false" r_stFields="stFields" />

	<cfreturn stFields />
</cffunction>

