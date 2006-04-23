<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmProfile/displaySummary.cfm,v 1.4 2005/02/04 05:23:46 brendan Exp $
$Author: brendan $
$Date: 2005/02/04 05:23:46 $
$Name: milestone_2-3-2 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: dmProfile -- standard page $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@dameon.com.au) $
--->
		<cfprocessingDirective pageencoding="utf-8">
		<cfsavecontent variable="profilehtml">
		<cfset request.stObj.title = "#stObj.firstName# #stObj.lastName#">
		
		<cfoutput>
			<table width="250" border="0" cellspacing="1" cellpadding="3" style="border: 1px solid ##000;">
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>#application.adminBundle[session.dmProfile.locale].name#&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.firstName# #stObj.lastName#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>#application.adminBundle[session.dmProfile.locale].email#&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.emailAddress#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>#application.adminBundle[session.dmProfile.locale].Position#&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.position#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>#application.adminBundle[session.dmProfile.locale].Department#&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.department#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>#application.adminBundle[session.dmProfile.locale].Phone#&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.phone#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>#application.adminBundle[session.dmProfile.locale].Fax#&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.fax#</td>
	        </tr>
			<tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>#application.adminBundle[session.dmProfile.locale].Locale#&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.locale#</td>
	        </tr>
	        </table>
			
			 <br>
			<!--- link to edit profile and change password --->
    	    <table width="250" border="0" cellspacing="0" cellpadding="2">
        	<tr>
            <td nowrap><span class="frameMenuBullet">&raquo;</span> <a href="##"  onClick="javascript:window.open('edit.cfm?objectID=#session.dmProfile.objectID#&type=dmProfile','edit_profile','width=385,height=385,left=200,top=100');startTimer(#application.config.general.sessionTimeOut#)" title="#application.adminBundle[session.dmProfile.locale].editProfileLC#">#application.adminBundle[session.dmProfile.locale].editProfileLC#</a></td>
           	<cfif application.dmSec.userDirectory[session.dmProfile.userDirectory].type neq "ADSI">
            <td>&nbsp;</td>
            <td nowrap><span class="frameMenuBullet">&raquo;</span> <a href="##"  onClick="javascript:window.open('security/updatePassword.cfm','update_password','width=350,height=250,left=200,top=100');startTimer(#application.config.general.sessionTimeOut#)" title="#application.adminBundle[session.dmProfile.locale].changePassword#">#application.adminBundle[session.dmProfile.locale].changePassword#</a></td>
	        </cfif>
    	    </tr>
        	</table>
		</cfoutput>
		</cfsavecontent>
		
