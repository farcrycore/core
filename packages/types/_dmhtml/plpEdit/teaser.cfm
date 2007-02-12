<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmhtml/plpEdit/teaser.cfm,v 1.6 2004/07/15 02:00:49 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 02:00:49 $
$Name: milestone_3-0-1 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: teaser step for dmHTML plp. $
$TODO: clean up formatting -- test in Mozilla 20030503 GB$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->
<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfimport taglib="/farcry/farcry_core/fourq/tags/" prefix="q4">

<!--- copy related items to a list for looping --->
<cfset aRelatedItems = output.aObjectIDs>


<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<tags:plpNavigationMove>

<cfif NOT thisstep.isComplete>
	<cfoutput><form action="#cgi.script_name#?#cgi.query_string#" name="editform" method="post">
			
		<div class="FormSubTitle">#output.label#</div>
		<div class="FormTitle">#application.adminBundle[session.dmProfile.locale].teaser#</div>	
		<div class="FormTable">
		<table class="BorderTable" width="400" align="center">
		<tr>
			<td width="100"><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].teaserImage#</span></td>
			<td width="300">
				<select name="teaserImage">
					<option value="">#application.adminBundle[session.dmProfile.locale].none#</option>
					</cfoutput>
					<cfloop from="1" to="#arrayLen(aRelatedItems)#" index="id">
						<!--- get the objectType --->
						<cfinvoke component="farcry.farcry_core.fourq.fourq" returnVariable="typeName" method="findType" objectID="#aRelatedItems[id]#">
						<cfif typename eq "dmImage">
							<q4:contentObjectGet objectID="#aRelatedItems[id]#" r_stObject="stImage">
							<cfif stImage.thumbnail neq "">
								<cfoutput><option value="#stImage.objectID#"<cfif output.teaserImage eq stImage.objectid> selected</cfif>>#stImage.title#</option></cfoutput>
							</cfif>
						</cfif>
					</cfloop>
				<cfoutput>
				</select>
			</td>
		</tr>
		<tr>
			<td colspan="2"><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].teaser#</span><br><tags:countertext formname="editform" fieldname="teaser" fieldvalue="#output.teaser#" counter="#application.config.general.teaserLimit#"></td>
		</tr>										
	</table>
	</div>
	
	<div class="FormTableClear">
		<tags:plpNavigationButtons>
	</div>
	
	</form>
	</cfoutput>
	
<cfelse>
	<!--- <cfparam name="form.aIds" default="">
	<cfset output.aTeaserImageIds = ListToArray(form.aIds)> --->

	<tags:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">
