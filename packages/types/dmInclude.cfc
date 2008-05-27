<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
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