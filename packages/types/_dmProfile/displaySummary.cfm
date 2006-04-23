<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmProfile/displaySummary.cfm,v 1.2 2003/11/28 08:42:43 paul Exp $
$Author: paul $
$Date: 2003/11/28 08:42:43 $
$Name: milestone_2-2-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: dmProfile -- standard page $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@dameon.com.au) $
--->

		<cfsavecontent variable="profilehtml">
		<cfset request.stObj.title = "#stObj.firstName# #stObj.lastName#">
		
		<cfoutput>
			<table width="250" border="0" cellspacing="1" cellpadding="3" style="border: 1px solid ##000;">
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>Name&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.firstName# #stObj.lastName#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>Email&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.emailAddress#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>Position&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.position#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>Department&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.department#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>Phone&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.phone#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>Fax&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.fax#</td>
	        </tr>
	        </table>
			
			 <br>
			<!--- link to edit profile and change password --->
    	    <table width="250" border="0" cellspacing="0" cellpadding="2">
        	<tr>
            <td nowrap><span class="frameMenuBullet">&raquo;</span> <a href="##"  onClick="javascript:window.open('edit.cfm?objectID=#session.dmProfile.objectID#&type=dmProfile','edit_profile','width=385,height=385,left=200,top=100');startTimer(#application.config.general.sessionTimeOut#)" title="Edit your profile">Edit your profile</a></td>
           	<cfif application.dmSec.userDirectory[session.dmProfile.userDirectory].type neq "ADSI">
            <td>&nbsp;</td>
            <td nowrap><span class="frameMenuBullet">&raquo;</span> <a href="##"  onClick="javascript:window.open('security/updatePassword.cfm','update_password','width=350,height=250,left=200,top=100');startTimer(#application.config.general.sessionTimeOut#)" title="Change your password">Change your password</a></td>
	        </cfif>
    	    </tr>
        	</table>
		</cfoutput>
		</cfsavecontent>
		
