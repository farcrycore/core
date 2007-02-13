<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2005, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/custom/sidebar.cfm,v 1.4 2005/08/09 03:42:09 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:42:09 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Custom admin sidebar. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
$Developer: Guy Phanvongsa (guy@daemon.com.au)$
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin" prefix="admin">

<cfparam name="url.sub" default="" type="string">
<cfparam name="url.sec" default="" type="string">

<admin:menu subsectionid="#url.sub#" webTop="#application.factory.owebtop#" />
