<cfsetting enablecfoutputonly="true">
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
<!--- @@displayname: Webtop Overview --->
<!--- @@description: The default webskin to use to render the object's summary in the webtop overview screen  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />


<!--- ENVIRONMENT VARIABLES --->
<cfset lCatProps = "" />
<cfset lCats = "" />

<cfloop list="#structKeyList(application.stcoapi[stobj.typename].stProps)#" index="iProp">
	<cfif application.fapi.getPropertyMetadata(stobj.typename, iProp, "ftType", "") EQ "category">
		<cfset lCatProps = listAppend(lCatProps, iProp) />
	</cfif>
</cfloop>


<!------------------ 
START WEBSKIN
 ------------------>
 
 
<!--- CATEGORISATION --->

<cfif listLen(lCatProps)>

	<ft:fieldset legend="Categorisation">
		<ft:field label="Categories" hint="Categories can allow users to more easily find your content.">
			<cfoutput>
			<cfloop list="#lCatProps#" index="iProp">
				<div>
					<strong>#application.fapi.getPropertyMetadata(stobj.typename, iProp, "ftLabel", iProp)#:</strong>
					<cfif listLen(stobj[iProp])>
						<cfloop list="#stobj[iProp]#" index="catid">		
							<cfset lCats = listAppend(lCats,application.factory.oCategory.getCategoryNameByID(catid)) />
						</cfloop>
					</cfif>
					#lCats#
				</div>
			</cfloop>
			</cfoutput>
		</ft:field>
	</ft:fieldset>
	
</cfif>

<!--- COMMENTS --->

<ft:fieldset legend="Comments">
	<ft:field label="Comments" bMultiField="true">
		
		<cfset events = structnew() />
		<cfset events.comment = "Comment" />
		<cfset events.toapproved = "Approved" />
		<cfset events.topending = "Requested approval" />
		<cfset events.todraft = "Sent to draft" />
	
		<cfset qComments = application.fapi.getContentType("farLog").filterLog(objectid=stobj.objectid,event='comment,topending,toapproved,todraft') />
		
		<cfif qComments.recordcount>
			<cfoutput>
				<cfloop query="qComments" startrow="1" endrow="5">
					<cfset stProfile = application.fapi.getContentType("dmProfile").getProfile(username=qComments.userid) />
					
					<div style="border:1px solid ##DFDFDF;padding:2px;margin-bottom:5px;">
						<div>
							<a title="#dateFormat(qComments.datetimecreated,'dd mmm yyyy')# #timeFormat(qComments.datetimecreated,'hh:mm tt')#">#application.fapi.prettyDate(qComments.datetimecreated)#</a>
							- #events[qComments.event]#
				
							<cfif structkeyexists(stProfile,"lastname") and len(stProfile.lastname)>
								(#stProfile.firstname# #stProfile.lastname#)
							<cfelse>
								(#listfirst(qComments.userid,'_')#)
							</cfif>
						</div>
						
						<cfif len(qComments.notes)>
							<div>#qComments.notes#</div>
						</cfif>
					</div>
				</cfloop>
			
				
			</cfoutput>
		</cfif>
		
		
	
		<ft:fieldHint>
			<cfoutput>
			The comment history will tell you the administration that has been performed on this content item. 
			You can <a onclick="$fc.openDialog('Comments', '#application.url.farcry#/navajo/commentOnContent.cfm?objectid=#stobj.objectid#&ajaxmode=1')">add comments</a> whenever you wish
			or see a <a onclick="$fc.openDialog('Comments', '#application.url.farcry#/navajo/commentOnContent.cfm?objectid=#stobj.objectid#&ajaxmode=1')">history</a> of comments. This item currently has #qComments.recordcount# comments.
			</cfoutput>
		</ft:fieldHint>
	</ft:field>
</ft:fieldset>

	
<ft:fieldset legend="System Information">
	<ft:fieldsetHelp>
		<cfoutput>
		<a onclick="$fc.openDialog('Property Dump', '#application.url.farcry#/object_dump.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#')">Open</a> a window containing all the raw data of this content item.
		</cfoutput>
	</ft:fieldsetHelp>
	<ft:field label="ObjectID" hint="This is the unique system wide identifier for this content item.">
		<cfoutput>#stobj.objectid#</cfoutput>
	</ft:field>
	<ft:field label="Created by" bMultiField="true" hint="This is the person who first created this content item.">
		<cfif len(stobj.createdby)>
			<cfset stLocal.profile = application.fapi.getContentType('dmProfile').getProfile(stobj.createdby) />
			<cfparam name="stLocal.profile.label" default="#stObj.createdby#" />
			<cfoutput>#stLocal.profile.Label#</cfoutput>
		<cfelse>
			<cfoutput>unknown.</cfoutput>
		</cfif>
		<cfoutput> #application.fapi.prettyDate(stobj.datetimecreated)#</cfoutput>
	</ft:field>
	<ft:field label="Last updated by" bMultiField="true">
		<cfif len(stobj.lastupdatedby)>
			<cfoutput>#application.fapi.getContentType('dmProfile').getProfile(stobj.lastupdatedby).Label#</cfoutput>
		<cfelse>
			<cfoutput>unknown.</cfoutput>
		</cfif>
		<cfoutput> #application.fapi.prettyDate(stobj.datetimelastupdated)#</cfoutput>
		<ft:fieldHint>
			<cfoutput>
			This is the person who last updated this content item.
			You can see the <a onclick="$fc.openDialogIFrame('Audit', '#application.url.farcry#/edittabAudit.cfm?objectid=#stobj.objectid#', 800, 700)">Audit Trail</a> or 
			<a onclick="$fc.openDialog('Archive', '#application.url.farcry#/archive.cfm?objectid=#stobj.objectid#')">Rollback</a> to a previous version of this content item.
			</cfoutput>
		</ft:fieldHint>
	</ft:field>
</ft:fieldset>


<cfsetting enablecfoutputonly="false">