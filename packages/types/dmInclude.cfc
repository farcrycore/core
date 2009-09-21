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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
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

<cfcomponent extends="types" displayname="Include" hint="Include files" bUseInTree="true" bObjectBroker="true" bFriendly="true">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty ftSeq="1" ftFieldset="Include Details" name="title" type="string" hint="Meaningful reference title for include file" required="no" default="" ftlabel="Title" ftvalidation="required" /> 
<cfproperty ftSeq="2" ftFieldset="Include Details" name="teaser" type="string" hint="A brief description of the nature of the include file" required="no" default="" ftType="longchar" ftlabel="Teaser" />  
<cfproperty ftSeq="3" ftFieldset="Include Details" name="teaserImage" type="uuid" hint="UUID of image to display in teaser" required="no" default="" fttype="uuid" ftjoin="dmImage" ftlabel="Teaser Image">
<cfproperty ftSeq="4" ftFieldset="Include Details" name="displayMethod" type="string" hint="" required="No" default="" ftType="webskin" ftPrefix="displayPage" ftlabel="Content Template" /> 
<cfproperty ftSeq="10" ftFieldset="Content" name="include" type="string" hint="The name of the include file" required="No" default="" ftType="list" ftListData="getIncludeList" ftLabel="Included CF Template" /> 
<cfproperty ftSeq="11" ftFieldset="Content" name="webskinTypename" type="string" hint="The content type to run the selected type view against" required="No" default="" ftLabel="Content Type" /> 
<cfproperty ftSeq="12" ftFieldset="Content" name="webskin" type="string" hint="The content view to be run on the selected typename" required="no" default=""  ftlabel="Content View" ftPrefix="displayType,editType" />
<cfproperty ftSeq="20" ftFieldset="Categorisation" name="catInclude" type="string" hint="category of the include" required="no" default="" ftType="category" ftlabel="Categorisation" />

<!--- system only properties --->
<cfproperty name="status" type="string" hint="Status of file - draft or approved" required="true" default="draft" />


<!--- Object Methods --->
<cffunction access="public" name="getIncludeList" returntype="string" hint="returns a list (column name 'include') of available includes.">
	
	<cfset var returnList = ":none selected" />
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

	
	<cffunction name="ftAjaxWebskin" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var qWebskins = querynew("methodName,displayName","varchar,varchar") />
		<cfset var qDisplayTypes = querynew("methodName,displayName") />
		<cfset var thisindex = "" />
		
		<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />
		
		<cfparam name="form.typename" default="" />
		<cfparam name="form.value" default="" />
		<cfparam name="arguments.stMetadata.ftPrefix" default="displayType,editType" /><!--- Webskin prefix --->

		<cfif len(form.typename)>
			<cfloop list="#arguments.stMetadata.ftPrefix#" index="thisprefix">
				<nj:listTemplates typename="#form.typename#" prefix="#thisprefix#" r_qMethods="qDisplayTypes">
				<cfquery dbtype="query" name="qWebskins">
					select	methodName,displayName
					from	qDisplayTypes
					
					UNION
					
					select	methodName,displayName
					from	qWebskins
					
					order by methodName
				</cfquery>
			</cfloop>
		
			<cfif qWebskins.recordCount>
				<cfsavecontent variable="html">
					<cfoutput>
						<select name="#arguments.fieldname#" id="#arguments.fieldname#">
					</cfoutput>
					
					<cfloop query="qWebskins">
						<cfoutput>
							<option value="#qWebskins.methodName#"<cfif qWebskins.methodName eq form.value> selected="selected"</cfif>>#qWebskins.displayName#</option>
						</cfoutput>
					</cfloop>
							
					<cfoutput>
						</select>
					</cfoutput>
				</cfsavecontent>
			<cfelse>
				<cfsavecontent variable="html">
					<cfoutput>
						<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="" />
						<div>No Webskins Available</div>
					</cfoutput>
				</cfsavecontent>
			</cfif>
		<cfelse>
			<cfsavecontent variable="html">
				<cfoutput>
					<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="" />
					<div>No type selected</div>
				</cfoutput>
			</cfsavecontent>
		</cfif>
		
		<cfreturn html>
	</cffunction>	
		
</cfcomponent>