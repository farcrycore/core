<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/config_restore.cfm,v 1.10 2004/06/16 04:55:15 brendan Exp $
$Author: brendan $
$Date: 2004/06/16 04:55:15 $
$Name: milestone_2-2-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$DESCRIPTION: restore default config settings$
$TODO: $ 

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in:$ 
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<!--- check permissions --->
<cfscript>
	iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iGeneralTab eq 1>

	<span class="formHeader">Restore Default Config</span>
	
	<!--- drop tables and recreate --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="deployConfig" returnvariable="deployConfigRet">
		<cfinvokeargument name="bDropTable" value="1"/>
	</cfinvoke>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #deployConfigRet.msg#...<p></p></cfoutput><cfflush><cfflush>
	
	<!--- setup default file config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultFile" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	<!--- setup default image config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultImage" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	<!--- setup default verity config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultVerity" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	<!--- setup default soEditor config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultSoEditor" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	<!--- setup default soEditorPro config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultSoEditorPro" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	<!--- setup default EWebEditPro config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultEWebEditPro" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	<!--- setup default Plugin config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultPlugins" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	<!--- setup default Friendly URLs config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultFU" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	
	<!--- setup default General config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultGeneral" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	<!--- setup default Overview tree config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultOverviewTree" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	<!--- setup default htmlarea config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultHTMLArea" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #stStatus.message#...<p></p></cfoutput><cfflush>
	
	<cfoutput>All done.</cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="no">