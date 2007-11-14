<cfsetting enablecfoutputonly="true" />
<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: $
$Author: $
$Date: $
$Name: $
$Revision: $

|| DESCRIPTION || 
$DESCRIPTION: Displays an audit log for object$

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$
--->

<!--- import tag library --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<!--- set up page header --->
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:restricted permission="ObjectDumpTab">
	<cfoutput>
	<h3>#application.adminBundle[session.dmProfile.locale].objectDump#</h3>
	</cfoutput>
	
	<!--- get object details and dump results --->
	<q4:contentobjectget objectid="#url.objectid#" r_stobject="stobj">
	<cfdump var="#stobj#" label="#stobj.label# Dump">
</sec:restricted>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="false" />