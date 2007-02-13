<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/_dmProfile/displaySummary.cfm,v 1.8 2005/10/06 00:02:24 daniela Exp $
$Author: daniela $
$Date: 2005/10/06 00:02:24 $
$Name: milestone_3-0-1 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: dmProfile -- standard page $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@dameon.com.au) $
--->
		<cfprocessingDirective pageencoding="utf-8">
		<cfsavecontent variable="profilehtml">
		<cfset request.stObj.title = "#stObj.firstName# #stObj.lastName#">
		
		<cfoutput>
			<dl id="profile" class="dl-style2">
	        <dt>#application.adminBundle[session.dmProfile.locale].name#</dt>
	        <dd><cfif len(trim(request.stObj.title))>#stObj.firstName# #stObj.lastName#<cfelse>-</cfif></dd>
	        <dt>#application.adminBundle[session.dmProfile.locale].email#</dt>
	        <dd><cfif len(stObj.emailAddress)>#stObj.emailAddress#<cfelse>-</cfif></dd>
	        <dt>#application.adminBundle[session.dmProfile.locale].Position#</dt>
	        <dd><cfif len(stObj.position)>#stObj.position#<cfelse>-</cfif></dd>
	        <dt>#application.adminBundle[session.dmProfile.locale].Department#</dt>
	        <dd><cfif len(stObj.department)>#stObj.department#<cfelse>-</cfif></dd>
	        <dt>#application.adminBundle[session.dmProfile.locale].Phone#</dt>
	        <dd><cfif len(stObj.phone)>#stObj.phone#<cfelse>-</cfif></dd>
	        <dt>#application.adminBundle[session.dmProfile.locale].Fax#</dt>
	        <dd><cfif len(stObj.fax)>#stObj.fax#<cfelse>-</cfif></dd>
	        <dt>#application.adminBundle[session.dmProfile.locale].Locale#</dt>
	        <dd><cfif len(stObj.locale)>#stObj.locale#<cfelse>-</cfif></dd>
	        </dl>

			<!--- link to edit profile and change password --->
    	    <h3>Your settings</h3>
			<ul>
			<li><small>
			<a href="##"  onClick="javascript:window.open('#application.url.farcry#/edit.cfm?objectID=#session.dmProfile.objectID#&type=dmProfile','edit_profile','width=459,height=500,left=200,top=100,scrollbars=yes');startTimer(#application.config.general.sessionTimeOut#)" title="#application.adminBundle[session.dmProfile.locale].editProfileLC#">#application.adminBundle[session.dmProfile.locale].editProfileLC#</a>
			</small></li>
           	<cfif application.dmSec.userDirectory[session.dmProfile.userDirectory].type neq "ADSI">
            <li><small>
			<a href="##"  onClick="javascript:window.open('#application.url.farcry#/security/updatePassword.cfm','update_password','width=459,height=250,left=200,top=100');startTimer(#application.config.general.sessionTimeOut#)" title="#application.adminBundle[session.dmProfile.locale].changePassword#">#application.adminBundle[session.dmProfile.locale].changePassword#</a>
			</small></li>
	        </cfif>
    	    </ul>
		</cfoutput>
		</cfsavecontent>
		
