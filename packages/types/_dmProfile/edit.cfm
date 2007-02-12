<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2005, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmProfile/edit.cfm,v 1.16 2005/08/16 05:53:23 pottery Exp $
$Author: pottery $
$Date: 2005/08/16 05:53:23 $
$Name: milestone_3-0-1 $
$Revision: 1.16 $

|| DESCRIPTION || 
dmProfile edit handler

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)
--->

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">


<!--- i18n: grab all available locales on this server --->
<cfset locales=listToArray(application.i18nUtils.getLocales())>
<cfset localeNames=listToArray(application.i18nUtils.getLocaleNames())>

<cfimport taglib="/farcry/farcry_core/fourq/tags/" prefix="q4">
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
			<div class="fade error" style="margin-left:15px" id="fader2">#application.adminBundle[session.dmProfile.locale].updateFailed# | <a href="edit.cfm?objectID=#session.dmProfile.objectID#&type=dmProfile">#application.adminBundle[session.dmProfile.locale].tryAgain#</a></div>
	        </cfoutput>
	    </cfcatch>
    </cftry>

    <cfoutput>
    <script language="JavaScript">window.opener.location.reload();</script>
	<div class="fade success" id="fader" style="margin-left:15px"><strong>#application.adminBundle[session.dmProfile.locale].updateSuccessful#</strong> | <a href="##" onClick="window.close();">#application.adminBundle[session.dmProfile.locale].closeWindow#</a></div>
    </cfoutput>

    <cfset bShowForm = "false">

</cfif>

<cfif bShowForm>

	<cfoutput>

	<form action="" method="POST" name="profileForm" id="profileForm" class="f-wrap-1 f-bg-medium" style="margin-left:8px">
	<fieldset>
	
		<h3>#application.adminBundle[session.dmProfile.locale].editProfile# : #stObj.userName#</h3>
		
		<cfif isDefined("errorMsg")>
        <div class="fade error" id="fader3"><strong>#errorMsg#</strong></div>
    	</cfif>
		
		<label for="firstname">
		<b>#application.adminBundle[session.dmProfile.locale].firstName#</b>
		<input type="text" name="firstName" id="firstName" value="#stObj.firstName#" /><br />
		</label>
		
		<label for="lastName">
		<b>#application.adminBundle[session.dmProfile.locale].lastName#</b>
		<input type="text" name="lastName" id="lastName" value="#stObj.lastName#" /><br />
		</label>
		
		<label for="email">
		<b>#application.adminBundle[session.dmProfile.locale].emailAddress#</b>
		<input type="text" name="email" id="email" value="#stObj.emailAddress#" /><br />
		</label>
		
		<label for="position">
		<b>#application.adminBundle[session.dmProfile.locale].position#</b>
		<input type="text" name="position" id="position" value="#stObj.position#" /><br />
		</label>
		
		<label for="department">
		<b>#application.adminBundle[session.dmProfile.locale].department#</b>
		<input type="text" name="department" id="department" value="#stObj.department#" /><br />
		</label>
		
		<label for="phone">
		<b>#application.adminBundle[session.dmProfile.locale].phoneNumber#</b>
		<input type="text" name="phone" id="phone" value="#stObj.phone#" /><br />
		</label>
		
		<label for="fax">
		<b>#application.adminBundle[session.dmProfile.locale].faxNumber#</b>
		<input type="text" name="fax" id="fax" value="#stObj.fax#" /><br />
		</label>
		
		<label for="locale">
		<b>#application.adminBundle[session.dmProfile.locale].locale#</b>
		
			<!--- i18n: swap to use server locales --->
			<!--- <input type="text" name="locale" value="#stObj.locale#" size="30"> --->
			<select name="locale" size="1" id="locale">
			<cfloop index="i" from="1" to="#arrayLen(locales)#">
				<option value="#locales[i]#" <cfif locales[i] EQ stObj.locale>selected="selected"</cfif>>#localeNames[i]#</option>			
			</cfloop>
			</select><br />
		</label>
		
		<fieldset class="f-checkbox-wrap">
		
			<b>&nbsp;</b>
			
			<fieldset>
			<label for="blue" style="width:200px">
			<input class="f-checkbox" type="checkbox" name="receiveEmail" value="1"<cfif stObj.bReceiveEmail> checked="checked"</cfif> />
			#application.adminBundle[session.dmProfile.locale].getEmailNotifications#
			</label>
			</fieldset>
				
		</fieldset>
			
		<div class="f-submit-wrap">
		<input type="submit" value="#application.adminBundle[session.dmProfile.locale].ok#" name="submit" class="f-submit" /><br />
		</div>
		
	</fieldset>
	</form>
	</cfoutput>

</cfif>
<admin:footer>
<cfsetting enablecfoutputonly="No">