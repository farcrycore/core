<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSec_TestSecuritySetup.cfm,v 1.7 2005/08/17 06:50:52 pottery Exp $
$Author: pottery $
$Date: 2005/08/17 06:50:52 $
$Name: milestone_3-0-1 $
$Revision: 1.7 $

|| DESCRIPTION || 
Shows the userdirectory and policy store setup.
Allows verification of setup.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

--->

<cfoutput>


<cfscript>
	stUD=request.dmSec.oAuthentication.getUserDirectory();
</cfscript>


<form action="" method="post" class="f-wrap-1 f-bg-medium wider">
<fieldset>
	<h3>Security Setup</h3>
	
<cfif isDefined("form.verify")>
	
	<h5>#application.adminBundle[session.dmProfile.locale].testingSetup#, #application.adminBundle[session.dmProfile.locale].securityTests#</h5>
	

	<p>#application.adminBundle[session.dmProfile.locale].userDirExists#</p>
	
	<cfloop index="udName" list="#StructKeyList(stUd)#">
		<h5>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].testingUserDir,"#udName#")#</h5>
	
		<cfswitch expression="#stUd[udName].type#">
		<cfcase value="Daemon">
		
			<cfif not isDefined("stUd.#udName#.datasource")>
		
				application.rb.formatRBString(userDirNotFound,"#udName#")<br>
			
			<cfelse>
			
				#application.adminBundle[session.dmProfile.locale].userDirOK#<br>
				
				<!--- Test the odbc connection works --->
				<cfswitch expression="#application.dbType#">
					
					<cfcase value="ora">
						<cfquery name="testODBC" datasource="#stUd[udName].datasource#" dbtype="ODBC">
							SELECT 1 FROM DUAL
						</cfquery>
					</cfcase>
					
					<cfdefaultcase>
						<cfquery name="testODBC" datasource="#stUd[udName].datasource#" dbtype="ODBC">
							SELECT 1;
						</cfquery>
					</cfdefaultcase>
				
				</cfswitch>
				
				#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].userDirConnectedOK,"#stUd[udName].datasource#")#<br>
				<a href="?tag=CreateSecurityTables&userDirectory=#udName#" onClick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmCreateSecurityTables#');">#application.adminBundle[session.dmProfile.locale].createSecurityTables#</a><br>
				<br>
				<cfimport taglib="/farcry/farcry_core/tags/security/ui/" prefix="dmsec">
				<!--- Test the correct tables are in the user Directory --->
				<dmsec:dmSec_TableTest table="dmUser"
						fields="userId,userLogin,userNotes,userPassword,userStatus"
						datasource="#stUd[udName].datasource#">
	
				<!--- Test for Group table --->
				<dmsec:dmSec_TableTest table="dmGroup"
									fields="groupId,groupName,groupNotes"
									datasource="#stUd[udName].datasource#">
				
				<!--- Test for UserToGroup table --->
				<dmsec:dmSec_TableTest table="dmUserToGroup"
									fields="UserId,GroupId"
									datasource="#stUd[udName].datasource#">

			</cfif>
		
		</cfcase>
		
		<cfcase value="ADSI">
			<cfif not isDefined("stUd.#udName#.domain")>
				#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].userDirDomainNotFound,"#udName#")#<br>
			
			<cfelse>
				#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].userDirDomainOK,"#udName#")#<br>
				
				<!--- test the connection by downloading all Active Directory groups --->
				<cfscript>
                o_NTsec = createObject("component", "#application.packagepath#.security.NTsecurity");
                aGroups = o_NTsec.getDomainGroups(domain=stUd[udName].domain);
                </cfscript>

				<cfif arrayLen(aGroups)>
					<cfset subS=listToArray('#udName#,#stUd[udName].domain#')>
                    #application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].adsiConnectionOK,subS)#<br>
                <cfelse>
					<cfset subS=listToArray('#udName#,#stUd[udName].domain#')>
                    #application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].adsiConnectionFailed,subS)#.<br>
                </cfif>
			</cfif>
					
		</cfcase>
		
		<cfdefaultcase>
			#application.adminBundle[session.dmProfile.locale].userDirUnknownType#<br>
		</cfdefaultcase>
		</cfswitch>
		
	</cfloop>
	</td>
	</tr>
	</table>
	
<cfelse>

<cfdump var="#stUd#">
	
</cfif>

	<div class="f-submit-wrap" style="padding-left:0;padding-top:15px">
	<input type="Submit" name="Verify" class="f-submit" style="margin-left:0" value="#application.adminBundle[session.dmProfile.locale].verifySetup#" />
	<input type="Submit" name="View" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].viewSetup#" />
	</div>
</fieldset>
</form>

</cfoutput>
<cfsetting enablecfoutputonly="No">