<cfsetting enablecfoutputonly="true" />
<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2005, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header$
$Author$
$Date$
$Name$
$Revision$

|| DESCRIPTION ||
$Description: Generic type administration. $
$TODO: i18n resource bundle update$
$TODO: requires specific permission set for access$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">

<cfdirectory action="list" directory="#application.config.general.ARCHIVEDIRECTORY#" name="qFiles" filter="*" />


<!--- set up page header --->
<admin:header title="Archived Media Admin" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1');">

<cfoutput>
<h1>Archived Media Assets</h1>
<p>Archive: #application.config.general.ARCHIVEDIRECTORY#</p>
</cfoutput>

<cfdump var="#qFiles#">

<admin:footer>
<cfsetting enablecfoutputonly="false" />