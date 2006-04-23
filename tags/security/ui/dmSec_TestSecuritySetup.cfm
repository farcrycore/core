<cfsetting enablecfoutputonly="Yes">

<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSec_TestSecuritySetup.cfm,v 1.3 2004/01/18 22:45:44 brendan Exp $
$Author: brendan $
$Date: 2004/01/18 22:45:44 $
$Name: milestone_2-1-2 $
$Revision: 1.3 $

|| DESCRIPTION || 
Shows the userdirectory and policy store setup.
Allows verification of setup.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

--->

<cfoutput>
<span class="formtitle">Security Setup</span><p></p>

<cfscript>
	stUD=request.dmSec.oAuthentication.getUserDirectory();
</cfscript>


<form action="" method="POST">

<cfif isDefined("form.verify")>
	
	<h3>Testing setup</h3>
	
	<h4>Security Tests</h4>
	
	<table border=0 cellpadding=0 cellspacing=0>
	<tr>
	<td>&nbsp;&nbsp;</td>
	<td>
	<span style="color:green;">OK:</span> UserDirectory attribute exists.<br>
	
	<cfloop index="udName" list="#StructKeyList(stUd)#">
		<h5>Testing UserDirectory '#udName#'.</h5>
	
		<cfswitch expression="#stUd[udName].type#">
		<cfcase value="Daemon">
		
			<cfif not isDefined("stUd.#udName#.datasource")>
		
				<span style="color:red;">Error:</span> UserDirectory '#udName#' Datasource attribute not found.<br>
			
			<cfelse>
			
				<span style="color:green;">OK:</span> UserDirectory Datasource attribute exists.<br>
				
				<!--- Test the odbc connection works --->
				<cfquery name="testODBC" datasource="#stUd[udName].datasource#" dbtype="ODBC">
					SELECT 1;
				</cfquery>
				
				<span style="color:green;">OK:</span> UserDirectory Datasource '#stUd[udName].datasource#' connection success.<br>
				<a href="?tag=CreateSecurityTables&userDirectory=#udName#" onClick="return confirm('Are you sure you wish to recreate you security tables?');">Create Security Tables</a><br>
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
				<span style="color:red;">Error:</span> UserDirectory '#udName#' Domain attribute not found.<br>
			
			<cfelse>
				<span style="color:green;">OK:</span> UserDirectory '#udName#' Domain attribute exists.<br>
				
				<!--- test the connection by downloading all Active Directory groups --->
				<cfscript>
                o_NTsec = createObject("component", "#application.packagepath#.security.NTsecurity");
                aGroups = o_NTsec.getDomainGroups(domain=stUd[udName].domain);
                </cfscript>

				<cfif arrayLen(aGroups)>
                    <span style="color:green;">OK:</span> ADSI connection('#udName#') to domain '#stUd[udName].domain#' success.<br>
                <cfelse>
                    <span style="color:red;">Error:</span> ADSI connection('#udName#') to domain '#stUd[udName].domain#' failed.<br>
                </cfif>
			</cfif>
					
		</cfcase>
		
		<cfdefaultcase>
		
			<span style="color:Orange;">Warning:</span> Unknown user directory type.<br>
		</cfdefaultcase>
		</cfswitch>
		
	</cfloop>
	</td>
	</tr>
	</table>

<cfelse>

<cfdump var="#stUd#">
	
</cfif>

<br><br>
<input type="Submit" name="Verify" value="Verify Setup">&nbsp;<input type="Submit" name="View" value="View Setup"><br>
<br>
</form>

</cfoutput>
<cfsetting enablecfoutputonly="No">