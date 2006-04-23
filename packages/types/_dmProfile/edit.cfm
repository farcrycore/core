<cfsetting enablecfoutputonly="Yes">

<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmProfile/edit.cfm,v 1.11 2004/06/17 04:48:41 geoff Exp $
$Author: geoff $
$Date: 2004/06/17 04:48:41 $
$Name: milestone_2-2-1 $
$Revision: 1.11 $

|| DESCRIPTION || 
dmProfile edit handler

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| END FUSEDOC ||
--->

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<cfset bShowForm = "true">

<cfif isDefined("FORM.submit") AND form.email neq "" AND (find("@", form.email) eq 0 OR find(".", form.email ) eq 0)>
    <cfset errorMsg = "INVALID EMAIL ADDRESS">
<cfelseif isDefined("FORM.submit")>

	<cfscript>
	stProperties = structNew();
	// set label to something meaningful
	// stProperties.objectid = form.lastname & ', ' & form.firstname;
	stProperties.objectid = stObj.objectid;
	stProperties.firstName = form.firstName;
	stProperties.lastName = form.lastName;
	stProperties.emailAddress = form.email;
	stProperties.position = form.position;
    stProperties.department = form.department;
    stProperties.phone = form.phone;
    stProperties.fax = form.fax;
	stProperties.datetimelastupdated = now();
	stProperties.lastupdatedby = session.dmSec.authentication.userlogin;
	//unlock object
	stProperties.locked = 0;
	stProperties.lockedBy = "";

    if (isDefined("form.receiveEmail")) stProperties.bReceiveEmail = 1;
    else stProperties.bReceiveEmail = 0;
	</cfscript>

    <cftry>
        <cfscript>
			// update the OBJECT	
			oType = createobject("component", application.types.dmProfile.typePath);
			oType.setData(stProperties=stProperties);
			
	        // reload changes into session.dmProfile object
	        o_userProfile = createObject("component", application.types.dmProfile.typePath);
	        stProfile = o_userProfile.getProfile(userName=session.dmSec.authentication.userlogin);
	        // place dmProfile in session scope
	        if (isStruct(stProfile) AND not structIsEmpty(stProfile)) session.dmProfile = stProfile;
        </cfscript>

	    <cfcatch type="Any">
	        <cfoutput>
			<div class="formtitle" style="margin-left:30px;margin-top:30px;">Update Failed</div>
			<p>
			<span class="frameMenuBullet" style="margin-left:30px;">&raquo;</span> <a href="edit.cfm?objectID=#session.dmProfile.objectID#&type=dmProfile">Try again</a>
	        </cfoutput>
	    </cfcatch>
    </cftry>

    <cfoutput>
    <script language="JavaScript">window.opener.location.reload();</script>
	<div class="formtitle" style="margin-left:30px;margin-top:30px;">Update Successful</div>
	<p>
	<span class="frameMenuBullet" style="margin-left:30px;">&raquo;</span> <a href="##" onClick="window.close();">Close window</a>
    </cfoutput>

    <cfset bShowForm = "false">

</cfif>

<cfif bShowForm>

	<cfoutput>
	<br>
    <div class="FormTitle" style="margin-left:30px;margin-top:30px;">EDIT PROFILE : #stObj.userName#</div>

    <cfif isDefined("errorMsg")>
        <div class="FormTitle" style="margin-left:30px;">
        <font color="maroon"><strong>#errorMsg#</strong></font>
        </div>
    </cfif>

    <br>

	<form action="" method="POST" name="profileForm" id="profileForm">
	<table class="FormTable" style="width:320px">
	<tr>
		<td rowspan="13">&nbsp;</td>
        <td colspan="2">&nbsp;</td>
        <td rowspan="13">&nbsp;</td>
	</tr>
	<tr>
  		<td><span class="FormLabel">First Name</span></td>
   	 	<td><input type="text" name="firstName" value="#stObj.firstName#" size="30" ></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">Last Name</span></td>
   	 	<td><input type="text" name="lastName" value="#stObj.lastName#" size="30"></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">Email Address</span></td>
   	 	<td><input type="text" name="email" value="#stObj.emailAddress#" size="30"></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">Position</span></td>
   	 	<td><input type="text" name="position" value="#stObj.position#" size="30"></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">Department</span></td>
   	 	<td><input type="text" name="department" value="#stObj.department#" size="30"></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">Phone Number</span></td>
   	 	<td><input type="text" name="phone" value="#stObj.phone#" size="30"></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">Fax Number</span></td>
   	 	<td><input type="text" name="fax" value="#stObj.fax#" size="30"></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">Receive Email Notifications</span></td>
   	 	<td><input type="checkbox" name="receiveEmail" value="1"<cfif stObj.bReceiveEmail> checked</cfif>></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
        <td>&nbsp;</td>
		<td>
            <input type="submit" value="OK" name="submit" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
            <input type="button" value="Cancel" name="cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="window.close();">
		</td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	</table>
	</form>
	</cfoutput>

</cfif>

<cfsetting enablecfoutputonly="No">