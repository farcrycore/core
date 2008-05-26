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

<cfcomponent extends="types" displayname="Include" hint="Include files" bSchedule="true" bUseInTree="true" bObjectBroker="true" bFriendly="true">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty ftSeq="1" ftFieldset="Include Details" name="title" type="string" hint="Meaningful reference title for include file" required="no" default="" ftlabel="Title" ftvalidation="required" /> 
<cfproperty ftSeq="2" ftFieldset="Include Details" name="teaser" type="string" hint="A brief description of the nature of the include file" required="no" default="" ftType="longchar" ftlabel="Teaser" />  
<cfproperty ftSeq="3" ftFieldset="Include Details" name="teaserImage" type="uuid" hint="UUID of image to display in teaser" required="no" default="" fttype="uuid" ftjoin="dmimage" ftlabel="Teaser Image">
<cfproperty ftSeq="4" ftFieldset="Include Details" name="displayMethod" type="string" hint="" required="No" default="" ftType="webskin" ftPrefix="displayPage" ftlabel="Content Template" /> 
<cfproperty ftSeq="5" ftFieldset="Include Details" name="include" type="string" hint="The name of the include file" required="No" default="" ftType="list" ftListData="getIncludeList" ftLabel="Included CF Template" /> 
<cfproperty ftSeq="6" ftFieldset="Include Details" name="catInclude" type="string" hint="category of the include" required="no" default="" ftType="category" ftlabel="Categorisation" />

<!--- system only properties --->
<cfproperty name="status" type="string" hint="Status of file - draft or approved" required="true" default="draft" />


<!--- Object Methods --->
<cffunction access="public" name="getIncludeList" returntype="string" hint="returns a list (column name 'include') of available includes.">
	
	<cfset var returnList = "" />
	<cfset var includePath = application.path.project & "/includedObj">
	<cfset var qDir = queryNew("blah") />
	<cfset var includeAlias = "" />
	
	<cfset var qIncludes = application.coapi.coapiadmin.getIncludes() />
	
	<cfloop query="qIncludes">
		<cfif left(qIncludes.name,1) EQ "_" AND right(qIncludes.Directory, 11) EQ "includedObj">
			<cfset returnList = listAppend(returnList, "#qIncludes.path#:#qIncludes.displayName#") />
		</cfif>	
	</cfloop>
	
	<cfreturn returnList>	
</cffunction>
	
</cfcomponent>