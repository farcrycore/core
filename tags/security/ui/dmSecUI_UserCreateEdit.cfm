<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/security/ui/dmSecUI_UserCreateEdit.cfm,v 1.18 2005/10/20 06:49:27 guy Exp $
$Author: guy $
$Date: 2005/10/20 06:49:27 $
$Name: milestone_3-0-1 $
$Revision: 1.18 $

|| DESCRIPTION || 
$Description: Interface for creating and editing users.$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Matt Dawson (mad@daemon.com.au)$

|| ATTRIBUTES ||
$in: url.userLogin: name of the user you want to edit$
$in: url.userDirectory: which userdirectory this user belongs to$
$out:$
--->

<cfimport taglib="/farcry/core/tags/security/ui/" prefix="dmsec">
<cfinclude template="/farcry/core/admin/includes/cfFunctionWrappers.cfm">

<cfparam name="url.userLogin" default="">
<cfparam name="form.deleteuser" default="0">
<cfparam name="original_userlogin" default="">
<cfif len(url.userLogin)>
	<cfparam name="url.userDirectory">
</cfif>

<!--- Get all the current user directories --->
<cfscript>
	oAuthorisation = request.dmsec.oAuthorisation;
	oAuthentication = request.dmsec.oAuthentication;
	stUD = oAuthentication.getUserDirectory();
	if(form.deleteUser){
		oAuthentication.deleteUser(userid=form.userid,dsn=stud[form.userdirectory].datasource);
		location(url='redirect.cfm?tag=UserSearch&msg');
	}	
</cfscript>

<!--- Create/Update the user details on submit--->
<cfif isDefined("form.submit")>
	<cfset noError=1>
	<cftry>
		<cfif form.userId eq -1>
			<cfscript>
				//Create the new user
				stResult = oAuthentication.createUser(userlogin=form.userlogin,userpassword=form.userpassword,userdirectory=form.userdirectory,usernotes=form.usernotes,userstatus=form.userstatus); //CHG 1235 03/07/07 Coach: added veriable to capture results of call to oAuthentication.createUser
		
				//CHG 1235 03/07/07 Coach: Added if statement to trap if the user was created or not from previous call to oAuthentication.createUser
				if(stResult.bSuccess) 
				{				
					//Now create a structure to hold new profile properties
					stProps = structNew();
					stProps.userLogin = form.userlogin;
					stProps.userDirectory = form.userdirectory;
					
					//Create new profile. This used to be done as part of the login
					o_profile = createObject("component", application.types.dmProfile.typePath);
					stNewProfile = o_profile.createProfile(stProperties=stProps);
					
					//Now update the profile with the users home node in the Overview tree
					structClear(stProps); //clear and reuse stProps
					stProps.overviewHome = form.overviewHome;
					stProps.objectId = stNewProfile.objectId;
					o_profile.setData(stProperties=stProps);	
				}
				else //CHG 1235 03/07/07 Coach: added else clause to handle when a user was not created
				{
					// For some reason the new user wasn't created. (Most likely user already exists)
					noError=0;			
					stProfile = structNew();
					stProfile.overviewHome = form.overviewHome;
				}
			</cfscript>
		<cfelse>

			<cfset oAuthentication.updateUser(userid=form.userid,userlogin=form.userlogin,userpassword=form.userpassword,userdirectory=form.userdirectory,usernotes=form.usernotes,userstatus=form.userstatus)>

            <!--- update dmProfile object --->
			<cftry>
				<cfset o_profile = createObject("component", application.types.dmProfile.typePath)>
				<cfset stProfile = o_profile.getProfile(userName=original_userlogin)>
				<cfset stProps = structNew()>
				<cfset stProps.objectid = stProfile.objectID>
				<cfset stProps.username = form.userLogin>
				
				<cfif form.userStatus eq 4>
					<cfset stProps.bActive = 1>
				<cfelseif form.userStatus eq 2>
					<cfset stProps.bActive = 0>
				</cfif>
				<cfset stProps.overviewHome =  form.overviewHome>
				<cfset o_profile.setData(stProperties = stProps)>

				 <cfcatch><cfdump var="#cfcatch#"><cfabort></cfcatch>
			</cftry>
		</cfif>

		<cfcatch type="dmSec">
			<cfoutput>#cfcatch.message#</cfoutput>
			<cfset noError=0>
		</cfcatch>
	</cftry>
	
	<cfif noError>
		<cfoutput>
			<p id="fading1" class="fade"><span class="success">#application.adminBundle[session.dmProfile.locale].userChangeOK#</span></p>
			<!--- <br /> --->
		</cfoutput>
		<!--- Now grab the user --->
		<cfscript>
			stObj = oAuthentication.getUser(userlogin=form.userlogin,userdirectory=form.userdirectory);
	        stProfile = createObject("component", application.types.dmProfile.typePath).getProfile(userName=form.userlogin);
		</cfscript>
		<!--- What is this for??? ~tom
		<cfscript>
			oAuthorisation = request.dmsec.oAuthorisation;
			oAuthentication = request.dmsec.oAuthentication;
			stObj = oAuthentication.getUser(userLogin="#form.UserLogin#", userDirectory="#form.UserDirectory#");
		</cfscript>
		--->
		
	<cfelse>
		<cfset stObj=form>
		
		<!--- CHG 1235 03/07/07 Coach: If the error was generated from oAuthentication.createUser, then display the error message it sent --->
		<cfif isDefined("stResult") And Not stResult.bSuccess>
			<cfoutput><p id="fading1" class="fade"><span class="error">#stResult.message#</span></p></cfoutput>
		</cfif>
	</cfif>
	
<cfelseif len(url.userLogin)>
	<!--- Editing a user --->
	<cfscript>
		stObj = oAuthentication.getUser(userlogin=url.userlogin,userdirectory=url.userdirectory);
        stProfile = createObject("component", application.types.dmProfile.typePath).getProfile(userName=URL.userLogin);
	</cfscript>

	<cfif StructIsEmpty(stObj)>
		<dmSec:dmSec_throw errorcode="dmSec_UserGetUnableToFind" lExtra="#url.userLogin#,#url.userDirectory#">	
	</cfif>
	
	<!--- if, for whatever reason, the key 'overviewHome' does not exist in the profile structure... --->
	<cfif NOT structKeyExists(stProfile,"overviewHome")>
		<!--- create the key and assign default value of 'home' node --->
		<cfset tmp = structInsert(stProfile, "overviewHome", "HOME", "yes")>
	</cfif>
<cfelse>
	<!--- Creating new user --->
	<cfscript>
		stObj=structNew();
		stObj.userId=-1;
		stObj.userLogin="";
		stObj.userNotes="";
		stObj.userPassword="";
		stObj.userStatus="";
		stObj.userDirectory="";
		
		//struct to hold overviewHome variable. This is part of dmProfile
		stProfile = structNew();
		stProfile.overviewHome = "";
	</cfscript>
</cfif>

<cfoutput>
<script language="JavaScript">
function generateRandomPassword()
{
	words=['fuss','colour','edit','content','best','copy','job','snake','single','days','razor',
			'sweet','gang', 'expert','rumble','ants','narco','fatigue','message','disorder',
			'alive','express','hay','hungry','men','stud','foot','beauty','newt','miss','look',
			'party','bliss','beach','life','wet','peril','body','cast','jack','bee','sheep','kiwi','pear',
			'ike','park','south','kill','quick','spam','split','spock','crack','clean','speck','moral','dilemma',
			'your','spoke','bike','crave','crabs','clip','snoop','baby','maker','dune','wars','star','speck',
			'prove','muppet','show','tonight','very','special','guest','god','gremlin','jake','land','wack',
			'read','mag','mad','yum','kid','nubile','boy','attitude','feel','what','why','you','gotta','like','right',
			'ride','up','down','world','sick','people','know','beast','window','some','thing','nana','goat','blow','spank'];
	document.forms['user'].generatedPassword.value=words[Math.floor(Math.random()*words.length)]+words[Math.floor(Math.random()*words.length)]+Math.floor(Math.random()*1000);
}
</script>

<form action="" name="user" method="POST" class="f-wrap-2 f-bg-long">
	<fieldset>
		<div class="req"><b>*</b>Required</div>
		<cfif stObj.userId eq -1 >
			<h3>#application.adminBundle[session.dmProfile.locale].createUser#</h3>
		<cfelse>
			<h3>#application.adminBundle[session.dmProfile.locale].editUser#</h3>
		</cfif>			
	
		<label for="UserDirectory">
			<cfif stObj.userId eq -1>
				<b>#application.adminBundle[session.dmProfile.locale].selectUserDirCreateUser#</b>
				<select name="UserDirectory" id="UserDirectory">
					<cfloop index="i" list="#structKeyList(stUd)#">
						<cfif stUD[i].type neq "ADSI"><option value="#i#" <cfif stObj.userDirectory eq i>selected="selected"</cfif>>#i#</option></cfif>
					</cfloop>
				</select>
			<cfelse>
				<b>#application.adminBundle[session.dmProfile.locale].userDirectoryLabel#</b>
				<span style="font-weight:bold;margin-left:8px">#stObj.UserDirectory#</span><input type="hidden" name="UserDirectory" id="UserDirectory" value="#stObj.UserDirectory#" />
			</cfif>
			<br />
		</label>
		<!--- User Details --->
		<input type="hidden" name="UserId" value="#stObj.userId#" /> 
		<input type="hidden" name="original_userlogin" value="#stObj.userLogin#" /> 
		<label for="userLogin"><b>#application.adminBundle[session.dmProfile.locale].userLoginLabel#<span class="req">*</span></b>
			<cfif stObj.userId eq -1 OR stUd[stObj.UserDirectory].type neq 'Custom'>
				<input type="text" name="userLogin" id="userLogin" value="#stObj.userLogin#" maxsize="32" />
			<cfelse>
				<input type="hidden" name="userLogin" id="userLogin" value="#stObj.userLogin#" />#stObj.userLogin#
			</cfif>
			<br />
		</label>
		<cfif stObj.userId eq -1 OR stUd[stObj.UserDirectory].type neq 'Custom'>
			<label for="userNotes"><b>#application.adminBundle[session.dmProfile.locale].userNotes#</b>
				<textarea name="userNotes" class="f-comments" id="userNotes" rows="5" cols="30">#stObj.userNotes#</textarea><br />
			</label>
		</cfif>			
		
		<label for="generatedPassword"><b>#application.adminBundle[session.dmProfile.locale].genRandomPassword#:</b>
			<input type="text" name="generatedPassword" id="generatedPassword" maxsize="32" class="subdued" readonly /> 
			<a href="##" onclick="generateRandomPassword()" class="f-extratext">#application.adminBundle[session.dmProfile.locale].genRandomPassword#</a><br />
		</label>

		<label for="userPassword">
			<b>#application.adminBundle[session.dmProfile.locale].userPasswordLabel#<span class="req">*</span></b>
			<input type="password" name="userPassword" id="userPassword" value="#stObj.userPassword#" /><br />
		</label>
		
		<label for="userPassword2">
			<b>#application.adminBundle[session.dmProfile.locale].confirmPassword#:<span class="req">*</span></b>
			<input type="password" name="userPassword2" id="userPassword2" value="#stObj.userPassword#" />
			<br />			
		</label>
		
		<cfif stObj.userId eq -1 OR stUd[stObj.UserDirectory].type neq 'Custom'>
			<label for="userStatus">
				<b>#application.adminBundle[session.dmProfile.locale].userStatusLabel#</b>
				<select name="userStatus" id="userStatus" class="formselectlist">
					<option value="4" <cfif stObj.userStatus eq 4>selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].active#</option>
					<option value="2" <cfif stObj.userStatus eq 2>selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].disabled#</option>
				</select>
				<br />
			</label>
		</cfif>
	
		<label for="overviewHome">
			<cfset aNavalias = listToArray(listSort(structKeyList(application.navid),'textnocase'))>
			<b>#application.adminBundle[session.dmProfile.locale].userHomeNodeLabel#</b>
			<select name="overviewHome" id="overviewHome">
				<option value="HOME">HOME</option>
				<cfloop from="1" to="#arraylen(aNavalias)#" index="i">
					<cfset key=aNavalias[i]>
					<cfif key neq "home">
						<option value="#key#"<cfif stProfile.overviewHome eq key> selected="selected"</cfif>>#UCase(key)#</option>
					</cfif>
				</cfloop>
			</select>
			<br />
		</label>
		
		<label for="userGroup">
			<cfif stObj.userId eq -1>
				<div class="f-submit-wrap">
					<input type="submit" name="Submit" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].createUser#">
				</div>
			<cfelse>
				<cfscript>
					aUserGroups = oAuthentication.getMultipleGroups(userLogin="#stObj.userLogin#", userDirectory="#stObj.userdirectory#");
				</cfscript>
				<b>#application.adminBundle[session.dmProfile.locale].memberOfGroupsLabel#</b>
				<cfif arrayLen(aUserGroups) neq 0>
					<cfloop index="i" from="1" to="#arrayLen(aUserGroups)#">
						<cfif i neq 1>,</cfif>
						<span style="font-weight:bold;margin-left:8px">#trim(aUserGroups[i].groupName)#</span>
					</cfloop>
				<cfelse>
					<span style="font-weight:bold;margin-left:8px">None.</span>
				</cfif>
				
				<br />
				
				<p style="font-weight:bold;margin-left:0"><a href="#application.url.farcry#/security/redirect.cfm?tag=UserGroups&userLogin=#stObj.userLogin#&userdirectory=#stobj.userdirectory#">#application.adminBundle[session.dmProfile.locale].manageGroups#</a>
				</p>
				<div class="f-submit-wrap">
					<input type="hidden" name="deleteuser" value="0" />
					<input type="submit" name="Submit" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].updateUser#" />
					<input type="button" name="delete" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].deleteUser#" onClick="if(confirm('#application.adminBundle[session.dmProfile.locale].confirmDeleteUser#')){document.user.deleteuser.value=1;user.submit();}" />
				</div>
			</cfif>
		</label>
	</fieldset>
	<!--- form validation --->
	<SCRIPT LANGUAGE="JavaScript">
		<!--//
		objForm = new qForm("user");
		qFormAPI.errorColor="##cc6633";
		objForm.userLogin.validateNotNull("#application.adminBundle[session.dmProfile.locale].enterUserName#");
		objForm.userPassword.validateNotNull("#application.adminBundle[session.dmProfile.locale].enterPassword#");		
		objForm.userPassword.validatePassword(null,"1","32","#application.adminBundle[session.dmProfile.locale].enterValidPassword#");
		objForm.userPassword2.validateNotNull("#application.adminBundle[session.dmProfile.locale].reenterPassword#");
		objForm.userPassword.validatePassword('userPassword2', '1','32',"#application.adminBundle[session.dmProfile.locale].badPasswords#");
		//-->
	</SCRIPT>
</form>
</cfoutput>

<cfsetting enablecfoutputonly="No">
