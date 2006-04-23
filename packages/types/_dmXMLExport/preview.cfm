<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmXMLExport/preview.cfm,v 1.3 2003/09/10 23:46:11 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 23:46:11 $
$Name: b201 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: generates and then previews rss feed$
$TODO: $

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


