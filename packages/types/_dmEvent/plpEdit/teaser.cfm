<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmEvent/plpEdit/teaser.cfm,v 1.5 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: teaser step for dmEvent plp. $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->
<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">

<cfoutput>
	<link type="text/css" rel="stylesheet" href="#application.url.farcry#/css/admin.css"> 
</cfoutput>

<!--- copy related items to a list for looping --->
<cfset relatedItems = arraytolist(output.aObjectIds)>

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<tags:plpNavigationMove>

<cfif NOT thisstep.isComplete>
	<cfoutput>
	<form action="#cgi.script_name#?#cgi.query_string#" name="editform" method="post">
	
		<div class="FormSubTitle">#output.label#</div>
		<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].teaser#</div>
		<div class="FormTable">
		<table class="BorderTable" width="400" align="center">
		<tr>
			<td width="100"><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].teaserImage#</span></td>
			<td width="300">
				<select name="teaserImage">
					<option value="">#application.adminBundle[session.dmProfile.locale].none#</option></cfoutput>
					<cfloop list="#relatedItems#" index="id">
						<q4:contentobjectget objectid="#id#" r_stobject="stImages">
						 <cfif stImages.typeName eq "dmImage">	
							<cfif stImages.thumbnail neq "">
								<cfoutput><option value="#stImages.objectID#" <cfif output.teaserImage EQ id>selected</cfif>>#stImages.title#</option></cfoutput>
							</cfif>
						</cfif>
					</cfloop>
				<cfoutput>
				</select>
			</td>
		</tr>
		<tr>
			<td colspan="2"><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].Teaser#</span><br></cfoutput><tags:countertext formname="editform" fieldname="teaser" fieldvalue="#output.teaser#" counter="#application.config.general.teaserLimit#"><cfoutput></td>
		</tr>										
		</table>
		</div>
		<div class="FormTableClear">
			<tags:plpNavigationButtons>
		</div>		
	</form>
	</cfoutput>
	
<cfelse>

	<cfparam name="form.aIds" default="">
	<cfset output.aTeaserImageIds = ListToArray(form.aIds)>
	<tags:plpUpdateOutput>
	
</cfif>

<cfsetting enablecfoutputonly="no">