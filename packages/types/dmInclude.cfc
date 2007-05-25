<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/dmInclude.cfc,v 1.13 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.13 $

|| DESCRIPTION || 
$Description: dmInclude type $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
--->

<cfcomponent extends="types" displayname="Include" hint="Include files" bSchedule="true" bUseInTree="true" bObjectBroker="true">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty name="title" type="nstring" hint="Meaningful reference title for include file" required="no" default="" ftlabel="Title" ftvalidation="required" /> 
<cfproperty name="teaser" type="nstring" hint="A brief description of the nature of the include file" required="no" default="" ftType="longchar" ftlabel="Teaser" />  
<cfproperty name="displayMethod" type="string" hint="" required="No" default="" ftType="webskin" ftPrefix="displayPage" ftlabel="Content Template" /> 
<cfproperty name="include" type="string" hint="The name of the include file" required="No" default="" ftType="list" ftListData="getIncludeList" ftLabel="Included CF Template" /> 
<cfproperty name="teaserImage" type="uuid" hint="UUID of image to display in teaser" required="no" default="" fttype="uuid" ftjoin="dmimage" ftlabel="Teaser Image">
<cfproperty name="catInclude" type="string" hint="category of the include" required="no" default="" ftType="category" ftlabel="Categorisation" />

<!--- system only properties --->
<cfproperty name="status" type="string" hint="Status of file - draft or approved" required="No" default="draft">

<!--- deprecated legacy properties --->
<cfproperty name="commentlog" type="longchar" hint="Workflow comment log." required="no" default=""> 


<!--- Object Methods --->

<cffunction name="edit" access="public">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfinclude template="_dmInclude/edit.cfm">
</cffunction>

<cffunction access="public" name="getIncludes" returntype="query" hint="returns a single column query (column name 'include') of available includes.">
	<!--- TODO : can't hardcode path --->
	<cfset includePath = application.path.project & "/includedObj">
	<cfif NOT directoryExists(includePath)>
		<cfdirectory action="create" directory="#includePath#"> 
	</cfif>
	<cfdirectory directory="#includePath#" name="qDir" filter="*.cfm" sort="name">
	<cfset qIncludes = queryNew("include,includeAlias")>
	<cfset thisRow = 1>
	<cfloop query="qDir">
		<cfif qDir.name neq "_donotdelete.cfm">
			<cfset newRow  = queryAddRow(qIncludes, 1)>
			<cfset includeAlias = left(qDir.name, len(qDir.name)-4)>
			<cfset newCell = querySetCell(qIncludes,"include","#qDir.name#",thisRow)>
			<cfset newCell = querySetCell(qIncludes,"includeAlias","#includeAlias#",thisRow)>
			<cfset thisRow = thisRow + 1>
		</cfif>
	</cfloop>
	
	<cfreturn qIncludes>	
</cffunction>
	
	

<cffunction access="public" name="getIncludeList" returntype="string" hint="returns a list (column name 'include') of available includes.">
	
	<cfset var returnList = "" />
	<cfset var includePath = application.path.project & "/includedObj">
	<cfset var qDir = queryNew("blah") />
	<cfset var includeAlias = "" />
	
	<cfset var qIncludes = application.coapi.coapiadmin.getIncludes() />
	
	<cfloop query="qIncludes">	
		<cfset includeAlias = left(qIncludes.name, len(qIncludes.name)-4)>			
		<cfset returnList = listAppend(returnList, "#qIncludes.PATH#:#qIncludes.displayName#") />
	</cfloop>

	<cfreturn returnList>	
</cffunction>
	
		
</cfcomponent>