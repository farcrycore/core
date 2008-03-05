<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/admin/config_restore.cfm,v 1.17 2005/09/07 22:36:11 tom Exp $
$Author: tom $
$Date: 2005/09/07 22:36:11 $
$Name: milestone_3-0-1 $
$Revision: 1.17 $

|| DESCRIPTION || 
$DESCRIPTION: restore default config settings$
 

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in:$ 
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="AdminGeneralTab">
	<cfoutput><h3>#application.rb.getResource("restoreDefaultConfig")#</h3></cfoutput>
	
	<!--- drop tables and recreate --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="deployConfig" returnvariable="deployConfigRet">
		<cfinvokeargument name="bDropTable" value="1"/>
	</cfinvoke>
	
	<cfoutput><ul></cfoutput>
	
	<cfoutput><li>#deployConfigRet.msg#...</li></cfoutput><cfflush><cfflush>
	
	<!--- setup default file config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultFile" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><li>#stStatus.message#...</li></cfoutput><cfflush>
	
	<!--- setup default image config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultImage" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><li>#stStatus.message#...</li></cfoutput><cfflush>
	
	<!--- setup default verity config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultVerity" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><li>#stStatus.message#...</li></cfoutput><cfflush>
	
	<!--- setup default soEditor config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultSoEditor" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><li>#stStatus.message#...</li></cfoutput><cfflush>
	
	<!--- setup default soEditorPro config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultSoEditorPro" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><li>#stStatus.message#...</li></cfoutput><cfflush>
	
	<!--- setup default EWebEditPro config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultEWebEditPro" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><li>#stStatus.message#...</li></cfoutput><cfflush>
	
	<!--- setup default Plugin config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultPlugins" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><li>#stStatus.message#...</li></cfoutput><cfflush>
	
	<!--- setup default Friendly URLs config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultFU" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><li>#stStatus.message#...</li></cfoutput><cfflush>
	
	
	<!--- setup default General config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultGeneral" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><li>#stStatus.message#...</li></cfoutput><cfflush>
	
	<!--- setup default Overview tree config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultOverviewTree" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><li>#stStatus.message#...</li></cfoutput><cfflush>
	
	<!--- setup default htmlarea config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultHTMLArea" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><li>#stStatus.message#...</li></cfoutput><cfflush>
	
	<!--- setup default fckeditor config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultFCKEditor" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><li>#stStatus.message#...</li></cfoutput><cfflush>
	
	<!--- setup default EOPro4 config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultEOPro4" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><li>#stStatus.message#...</li></cfoutput><cfflush>
	
	<!--- setup default TinyMCE config --->
	<cfinvoke component="#application.packagepath#.farcry.config" method="defaultTinyMCE" returnvariable="stStatus">
	</cfinvoke>
	
	<cfoutput><li>#stStatus.message#...</li></cfoutput><cfflush>
	
	<cfoutput></ul></cfoutput>
	
	<cfoutput><h3 class="fade success" id="fader1">#application.rb.getResource("allDone")#</h3></cfoutput>
</sec:CheckPermission>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="no">