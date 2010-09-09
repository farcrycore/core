<cfsetting enablecfoutputonly="true" />
<cfsilent>
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
<!--- @@displayname: Related Content Tag --->
<!--- @@Description: Display related content. --->
<!--- @@Developer: Geoff Bowers (modius@daemon.com.au) --->

<!--- 
SAMPLE USAGE:
<skin:relatedcontent 
	objectid="#stobj.objectid#" 
	arrayProperty="aRelatedPosts" 
	typename="farBlogPost"
	filter="farBlogPost"
	webskin="displayTeaserStandard" 
	rendertype="unordered" />
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- only run tag once --->
<cfif thistag.executionMode eq "end">
	<cfsetting enablecfoutputonly="false" />
	<cfexit method="exittag" />
</cfif>

<!--- required attributes --->
<cfparam name="attributes.objectid" type="uuid" /><!--- The object for which related objects are to be found --->
<cfparam name="attributes.webskin" type="string" /><!--- webskin to render related content view --->

<!--- optional attributes --->
<cfparam name="attributes.typename" type="string" default="" /><!--- content typename of parent; providing improves performance --->
<cfparam name="attributes.arrayType" type="string" default="" /><!--- The typename containing the array property that defines the relationship we are looking for --->
<cfparam name="attributes.arrayProperty" type="string" default="" /><!--- propertyname of the array to render --->
<cfparam name="attributes.filter" type="string" default="" /><!--- The typename of related objects to find. Empty for ALL typenames. --->

<cfparam name="attributes.rendertype" default="none" type="string" /><!--- render options: unordered, ordered, none --->
<cfparam name="attributes.alternateHTML" default="#attributes.webskin# template unavailable." type="string" /><!--- alternative HTML if webskin is missing --->
<cfparam name="attributes.r_html" type="string"  default=""/><!--- Empty will render the html inline --->

<cfparam name="attributes.lValidStatus" default="#request.mode.lValidStatus#" /><!--- Filter displayed items by their status --->

<!--- GET THE RELATED CONTENT --->
<cfset qRelatedContent = application.fapi.getRelatedContent(objectid="#attributes.objectid#", typename="#attributes.typename#", filter="#attributes.filter#", arrayType="#attributes.arrayType#", arrayProperty="#attributes.arrayProperty#")>


<!--- generate output by rendertype --->
<cfset html="" />


<cfif qRelatedContent.recordCount>
	<cfswitch expression="#attributes.rendertype#">
	
		<cfcase value="unordered">
			<cfset html = html & "<ul>" />
			<cfloop query="qRelatedContent">
				<cfif not structkeyexists(application.stCOAPI[qRelatedContent.typename].stProps,"status")>
					<cfset bShowThis = true />
				<cfelse>
					<cfset stThis = application.fapi.getContentObject(typename=qRelatedContent.typename,objectid=qRelatedContent.objectid) />
					<cfset bShowThis = listcontainsnocase(attributes.lValidStatus,stThis.status) />
				</cfif>
				<cfif bShowThis>
				<skin:view objectid="#qRelatedContent.objectid#" typename="#qRelatedContent.typename#" webskin="#attributes.webskin#" alternateHTML="#attributes.alternateHTML#" r_html="htmlRelatedContent" />
				<cfset html = html & "<li>#htmlRelatedContent#</li>" />
				</cfif>
			</cfloop>
			<cfset html = html & "</ul>" />
		</cfcase>
	
		<cfcase value="ordered">
			<cfset html = html & "<ol>" />
			<cfloop query="qRelatedContent">
				<cfif not structkeyexists(application.stCOAPI[qRelatedContent.typename].stProps,"status")>
					<cfset bShowThis = true />
				<cfelse>
					<cfset stThis = application.fapi.getContentObject(typename=qRelatedContent.typename,objectid=qRelatedContent.objectid) />
					<cfset bShowThis = listcontainsnocase(attributes.lValidStatus,stThis.status) />
				</cfif>
				<cfif bShowThis>
				<skin:view objectid="#qRelatedContent.objectid#" typename="#qRelatedContent.typename#" webskin="#attributes.webskin#" alternateHTML="#attributes.alternateHTML#" r_html="htmlRelatedContent" />
				<cfset html = html & "<li>#htmlRelatedContent#</li>" />
				</cfif>
			</cfloop>
			<cfset html = html & "</ol>" />
		</cfcase>
		
		<cfdefaultcase>
			<cfloop query="qRelatedContent">
				<cfif not structkeyexists(application.stCOAPI[qRelatedContent.typename].stProps,"status")>
					<cfset bShowThis = true />
				<cfelse>
					<cfset stThis = application.fapi.getContentObject(typename=qRelatedContent.typename,objectid=qRelatedContent.objectid) />
					<cfset bShowThis = listcontainsnocase(attributes.lValidStatus,stThis.status) />
				</cfif>
				<cfif bShowThis>
				<skin:view objectid="#qRelatedContent.objectid#" typename="#qRelatedContent.typename#" webskin="#attributes.webskin#" alternateHTML="#attributes.alternateHTML#" r_html="htmlRelatedContent" />
				<cfset html = html & " #htmlRelatedContent# " />
				</cfif>
			</cfloop>
		</cfdefaultcase>
	
	</cfswitch>
</cfif>
</cfsilent>

<!--- TRIM THE HTML RESULT --->
<cfset html = trim(html) />

<!--- return to caller scope or output inline --->
<cfif len(attributes.r_html)>
	<cfset caller[attributes.r_html] = html />
<cfelse>
	<cfoutput>#html#</cfoutput>	
</cfif>

<cfsetting enablecfoutputonly="false" />