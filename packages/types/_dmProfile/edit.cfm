<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmProfile/edit.cfm,v 1.13 2004/08/20 04:28:23 brendan Exp $
$Author: brendan $
$Date: 2004/08/20 04:28:23 $
$Name: milestone_2-3-2 $
$Revision: 1.13 $

|| DESCRIPTION || 
dmProfile edit handler

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| END FUSEDOC ||
--->
<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- i18n: grab all available locales on this server --->
<cfset locales=listToArray(application.i18nUtils.getLocales())>
<cfset localeNames=listToArray(application.i18nUtils.getLocaleNames())>

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

<cfset bShowForm = "true">

<cfif isDefined("FORM.submit") AND form.email neq "" AND (find("@", form.email) eq 0 OR find(".", form.email ) eq 0)>
    <cfset errorMsg = "#application.adminBundle[session.dmProfile.locale].badEmail#">
<cfelseif isDefined("FORM.submit")>

	<cfscript>
	stProperties = structNew();
	stProperties.objectid = stObj.objectid;
	stProperties.firstName = form.firstName;
	stProperties.lastName = form.lastName;
	stProperties.emailAddress = form.email;
	stProperties.position = form.position;
    stProperties.department = form.department;
    stProperties.phone = form.phone;
    stProperties.fax = form.fax;
	stProperties.locale = form.locale;
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

			// i18n: reload i18n bits
			if(NOT structKeyExists(application.adminBundle, session.dmProfile.locale))
				// application.adminBundle[session.dmProfile.locale]=application.rB.getResourceBundle("farcry.admin",session.dmProfile.locale,true);
				application.adminBundle[session.dmProfile.locale]=application.rB.getResourceBundle("#application.path.core#/packages/resources/admin.properties",session.dmProfile.locale,false);
			// i18n: find out this locale's writing system direction using our special psychic powers
			if (application.i18nUtils.isBIDI(session.dmProfile.locale))
				session.writingDir="rtl";
			else
				session.writingDir="ltr";
			// i18n: final bit, grab user language from locale, tarts up html tag
			session.userLanguage=left(session.dmProfile.locale,2);
        </cfscript>

	    <cfcatch type="Any">
	        <cfoutput>
			<div class="formtitle" style="margin-left:30px;margin-top:30px;">#application.adminBundle[session.dmProfile.locale].updateFailed#</div>
			<p>
			<span class="frameMenuBullet" style="margin-left:30px;">&raquo;</span> <a href="edit.cfm?objectID=#session.dmProfile.objectID#&type=dmProfile">#application.adminBundle[session.dmProfile.locale].tryAgain#</a>
	        </cfoutput>
	    </cfcatch>
    </cftry>

    <cfoutput>
    <script language="JavaScript">window.opener.location.reload();</script>
	<div class="formtitle" style="margin-left:30px;margin-top:30px;">#application.adminBundle[session.dmProfile.locale].updateSuccessful#</div>
	<p>
	<span class="frameMenuBullet" style="margin-left:30px;">&raquo;</span> <a href="##" onClick="window.close();">#application.adminBundle[session.dmProfile.locale].closeWindow#</a>
    </cfoutput>

    <cfset bShowForm = "false">

</cfif>

<cfif bShowForm>

	<cfoutput>
	<br>
    <div class="FormTitle" style="margin-left:30px;margin-top:30px;">#application.adminBundle[session.dmProfile.locale].editProfile# : #stObj.userName#</div>

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
  		<td><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].firstName#</span></td>
   	 	<td><input type="text" name="firstName" value="#stObj.firstName#" size="30" ></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].lastName#</span></td>
   	 	<td><input type="text" name="lastName" value="#stObj.lastName#" size="30"></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].emailAddress#</span></td>
   	 	<td><input type="text" name="email" value="#stObj.emailAddress#" size="30"></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].position#</span></td>
   	 	<td><input type="text" name="position" value="#stObj.position#" size="30"></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].department#</span></td>
   	 	<td><input type="text" name="department" value="#stObj.department#" size="30"></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].phoneNumber#</span></td>
   	 	<td><input type="text" name="phone" value="#stObj.phone#" size="30"></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].faxNumber#</span></td>
   	 	<td><input type="text" name="fax" value="#stObj.fax#" size="30"></td>
	</tr>
	<tr>
  		<td><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].locale#</span></td>
   	 	<td>
		<!--- i18n: swap to use server locales --->
		<!--- <input type="text" name="locale" value="#stObj.locale#" size="30"> --->
		<select name="locale" size="1">
		<cfloop index="i" from="1" to="#arrayLen(locales)#">
			<option value="#locales[i]#" <cfif locales[i] EQ stObj.locale>SELECTED</cfif>>#localeNames[i]#</option>			
		</cfloop>
		</select>
		</td>
	</tr>
	<tr>
  		<td><span class="FormLabel">#application.adminBundle[session.dmProfile.locale].getEmailNotifications#</span></td>
   	 	<td><input type="checkbox" name="receiveEmail" value="1"<cfif stObj.bReceiveEmail> checked</cfif>></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
        <td>&nbsp;</td>
		<td>
            <input type="submit" value="#application.adminBundle[session.dmProfile.locale].ok#" name="submit" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
            <input type="button" value="#application.adminBundle[session.dmProfile.locale].cancel#" name="cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="window.close();">
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