<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2005, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/admin/sidebar.cfm,v 1.3 2005/08/09 03:42:09 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:42:09 $
$Name: milestone_3-0-1 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: Admin subsection sidebar. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->
<cfparam name="url.sub" default="general" type="string">
<cfimport taglib="/farcry/core/tags/admin" prefix="admin">
<admin:menu sectionid="admin" subsectionid="#url.sub#" webTop="#application.factory.owebtop#" />
