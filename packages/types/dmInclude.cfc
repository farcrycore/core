<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmInclude.cfc,v 1.13 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.13 $

|| DESCRIPTION || 
$Description: dmInclude type $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
--->

<cfcomponent extends="types" displayname="Include" hint="Include files" bSchedule="true" bUseInTree="1">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty name="title" type="nstring" hint="Meaningful reference title for include file" required="no" default=""> 
<cfproperty name="teaser" type="nstring" hint="A brief description of the nature of the include file" required="no" default="">  
<cfproperty name="displayMethod" type="string" hint="" required="No" default=""> 
<cfproperty name="include" type="string" hint="The name of the include file" required="No" default=""> 
<cfproperty name="status" type="string" hint="Status of file - draft or approved" required="No" default="draft"> 
<cfproperty name="commentlog" type="longchar" hint="Workflow comment log." required="no" default=""> 
<cfproperty name="teaserImage" type="string" hint="UUID of image to display in teaser" required="no" default="">

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
	
</cfcomponent>