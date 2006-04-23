
<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_UserCreateEdit.cfm,v 1.7 2003/12/08 00:25:13 brendan Exp $
$Author: brendan $
$Date: 2003/12/08 00:25:13 $
$Name: milestone_2-1-2 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: Interface for creating and editing users.$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Matt Dawson (mad@daemon.com.au)$

|| ATTRIBUTES ||
$in: url.userLogin: name of the user you want to edit$
$in: url.userDirectory: which userdirectory this user belongs to$
$out:$
--->

<cfimport taglib="/farcry/farcry_core/tags/security/ui/" prefix="dmsec">
<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">

<cfparam name="url.userLogin" default="">
<cfparam name="form.deleteuser" default="0">

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
				oAuthentication.createUser(userlogin=form.userlogin,userpassword=form.userpassword,userdirectory=form.userdirectory,usernotes=form.usernotes,userstatus=form.userstatus);
			</cfscript>
		<cfelse>
			<cfscript>
				oAuthentication.updateUser(userid=form.userid,userlogin=form.userlogin,userpassword=form.userpassword,userdirectory=form.userdirectory,usernotes=form.usernotes,userstatus=form.userstatus);
			</cfscript>

            <!--- update dmProfile object --->
			<cftry>
	            <cfscript>
		            o_profile = createObject("component", application.types.dmProfile.typePath);
		            stProfile = o_profile.getProfile(userName=URL.userLogin);
					
		
		            stProps = structNew();
					stProps.objectid = stProfile.objectID;
		            if (form.userStatus eq 4) stProps.bActive = 1;
		            else if (form.userStatus eq 2) stProps.bActive = 0;
					
					// update object	
					oType = createobject("component", application.types.dmProfile.typePath);
					oType.setData(stProperties=stProps);	
	            </cfscript>
				 
				 <cfcatch></cfcatch>
			</cftry>
		</cfif>
		
		<cfcatch type="dmSec">
			<cfoutput>#cfcatch.message#</cfoutput>
			<cfset noError=0>
		</cfcatch>
	</cftry>
	
	<cfif noError>
		<cfoutput><span style="color:green;">OK:</span> User Update/Create success<p></p></cfoutput>
		<!--- Now grab the user --->
		<cfscript>
			stObj = oAuthentication.getUser(userlogin=form.userlogin,userdirectory=form.userdirectory);
		</cfscript>
		<cfscript>
			oAuthorisation = request.dmsec.oAuthorisation;
			oAuthentication = request.dmsec.oAuthentication;
			stObj = oAuthentication.getUser(userLogin="#form.UserLogin#", userDirectory="#form.UserDirectory#");
		</cfscript>
		
		
	<cfelse>
		<cfset stObj=form>
	</cfif>
	
<cfelseif len(url.userLogin)>
	<!--- Editing a user --->
	<cfscript>
		stObj = oAuthentication.getUser(userlogin=url.userlogin,userdirectory=url.userdirectory);
	</cfscript>
	
	<cfif StructIsEmpty(stObj)>
		<dmSec:dmSec_throw errorcode="dmSec_UserGetUnableToFind" lExtra="#url.userLogin#,#url.userDirectory#">
		
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
	</cfscript>
</cfif>

<cfif stObj.userId eq -1 >
	<cfoutput><span class="formtitle">Create User</span><p></cfoutput>
<cfelse>
	<cfoutput><span class="formtitle">Edit User</span><p></cfoutput>
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
	document.forms['user'].userPassword.value=words[Math.floor(Math.random()*words.length)]+words[Math.floor(Math.random()*words.length)]+Math.floor(Math.random()*1000);
}
</script>


<form action="" name="user" method="POST">
<table class="formtable" border="0">
<tr>
	<td rowspan="20" colspan="2">&nbsp;</td>
</tr>
<tr>
	<td colspan="2">&nbsp;</td>
</tr>
<tr>
	
	<cfif stObj.userId eq -1>
		<td><span class="formlabel">Select a user directory to create the user in.</span></td>
		<td>
		<select name="UserDirectory" class="formselectlist">
			<cfloop index="i" list="#structKeyList(stUd)#">
				<cfif stUD[i].type neq "ADSI"><option value="#i#" <cfif stObj.userDirectory eq i>selected</cfif>>#i#</option></cfif>
			</cfloop>
		</select>
		</td>
	<cfelse>
		<td><span class="formlabel">UserDirectory:</span></td>
		<td>#stObj.UserDirectory#<input type="hidden" name="UserDirectory" value="#stObj.UserDirectory#"></td>
	</cfif>
	
</tr>
<tr>
	<td colspan="2">&nbsp;</td>
</tr>
<input type="hidden" name="UserId" value="#stObj.userId#"> 
<!--- User Details --->
<tr>
	<td><span class="formlabel">User Login:</span></td>
	<td>
	<cfif stObj.userId eq -1 OR stUd[stObj.UserDirectory].type neq 'Custom'>
		<input type="text" size="32" maxsize="32" name="userLogin" value="#stObj.userLogin#">
	<cfelse>
		<input type="hidden" size="32" maxsize="32" name="userLogin" value="#stObj.userLogin#">#stObj.userLogin#
	</cfif>
	</td>
</tr>
<tr>
	<td colspan="2">&nbsp;</td>
</tr>
<cfif stObj.userId eq -1 OR stUd[stObj.UserDirectory].type neq 'Custom'>
	<tr>
		<td valign="top"><span class="formlabel">User Notes:</span></td>
		<td><Textarea name="userNotes" class="formtextarea" rows="5">#stObj.userNotes#</textarea></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
</cfif>

<tr>
	<td valign="top"><span class="formlabel">User Password:</span></td>
	<td>
		<input type="text" maxsize="32" name="userPassword" value="#stObj.userPassword#">
		<input type="button" onClick="generateRandomPassword()" value="Generate Random Password" style="width:150px;">
	</td>
</tr>
<tr>
	<td colspan="2">&nbsp;</td>
</tr>
<cfif stObj.userId eq -1 OR stUd[stObj.UserDirectory].type neq 'Custom'>
	<tr>
		<td><span class="formlabel">User Status:</span></td>
		<td>
		<select name="userStatus" class="formselectlist">
			<option value="4" <cfif stObj.userStatus eq 4>selected</cfif>>Active
			<!--- <option value="1" <cfif stObj.userStatus eq 1>selected</cfif>>Blacklisted --->
			<option value="2" <cfif stObj.userStatus eq 2>selected</cfif>>Disabled
			<!--- <option value="3" <cfif stObj.userStatus eq 3>selected</cfif>>Pending Approval --->
		</select>
		</td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
</cfif>
<tr>
	<cfif stObj.userId eq -1>
	<td colspan="2"><input type="submit" name="Submit" value="Create User"><br></td>
	<cfelse>
		<cfscript>
			aUserGroups = oAuthentication.getMultipleGroups(userLogin="#stObj.userLogin#", userDirectory="#stObj.userdirectory#");
		</cfscript>
		
		<td><span class="formlabel">Member of Groups:</span></td>
		<td>
		<cfif arrayLen(aUserGroups) neq 0>
			<cfloop index="i" from="1" to="#arrayLen(aUserGroups)#">
				<cfif i neq 1>,</cfif>
				#aUserGroups[i].groupName#
			</cfloop>
		<cfelse>
			None.
		</cfif>
		</td>		
		<p></p>
		<input type="hidden" name="deleteuser" value="0">
		<input type="submit" name="Submit" value="Update User">
		<input type="button" name="delete" value="Delete User" onClick="if(confirm('Are you sure you wish to delete this user?')){document.user.deleteuser.value=1;user.submit();}">
		
	</cfif>
	</td>
</tr>
<tr>
	<td colspan="2">&nbsp;</td>
</tr>
<!--- form validation --->
	<SCRIPT LANGUAGE="JavaScript">
	<!--//
	objForm = new qForm("user");
	objForm.userLogin.validateNotNull("Please enter a user name");
	objForm.userPassword.validateNotNull("Please enter a password");
	objForm.userPassword.validatePassword(null, '1','32',"Please enter a valid password");
	//-->
	</SCRIPT>
</form>

<cfif stObj.userId neq -1>
	<form action="?tag=UserGroups&userLogin=#stObj.userLogin#&userdirectory=#stobj.userdirectory#" method="POST" style="display:inline">
	<tr>
		<td><input type="submit" name="GroupManage" value="Manage Groups"></td>

	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	</form>	
</cfif>
</table>
</cfoutput>

<cfsetting enablecfoutputonly="No">
