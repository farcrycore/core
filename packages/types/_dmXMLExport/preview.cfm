<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmXMLExport/preview.cfm,v 1.4 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: generates and then previews rss feed$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- first need to generate feed --->
<cfset generate(arguments.objectid)>

<!--- display --->
<CFHEADER NAME="content-disposition" VALUE="inline; filename=#stObj.xmlFile#">
<cfcontent type="text/xml" file="#application.path.project#/#application.config.general.exportPath#/#stObj.xmlFile#" deletefile="No" reset="Yes">


