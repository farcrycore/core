<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/ui/Attic/legend.cfm,v 1.3 2003/07/14 04:41:44 brendan Exp $
$Author: brendan $
$Date: 2003/07/14 04:41:44 $
$Name: b131 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: Displays a legend of all icons used in the farcry tree$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfset cimages = "#application.url.farcry#/images/treeImages/customIcons">

<cfoutput>

<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;margin-top:10px">
<tr class="dataheader">
	<td>Icon</td>
	<td>Meaning</td>
</tr>
<tr>
	<td><img src="#cimages#/defaultObjectDraft.gif" height="16" width="16" border="0"></td>
	<td>Default Draft HTML Object</td>
</tr>
<tr>
	<td><img src="#cimages#/defaultObjectLiveDraft.gif" height="16" width="16" border="0"></td>
	<td>Default Live HTML Object</td>
</tr>
<tr>
	<td><img src="#cimages#/defaultObjectPending.gif" height="16" width="16" border="0"></td>
	<td>Default Pending HTML Object</td>
</tr>
<tr>
	<td><img src="#cimages#/defaultObjectApproved.gif" height="16" width="16" border="0"></td>
	<td>Default Approved HTML Object</td>
</tr>
<tr>
	<td><img src="#cimages#/webserver.gif" height="16" width="16" border="0"></td>
	<td>Webserver</td>
</tr>
<tr>
	<td><img src="#cimages#/home.gif" height="16" width="16" border="0"></td>
	<td>Home</td>
</tr>
<tr>
	<td><img src="#cimages#/rubbish.gif" height="16" width="16" border="0"></td>
	<td>Trash Can</td>
</tr>
<tr>
	<td><img src="#cimages#/NavDraft.gif" height="16" width="16" border="0"></td>
	<td>Draft Navigation Object</td>
</tr>
<tr>
	<td><img src="#cimages#/NavApproved.gif" height="16" width="16" border="0"></td>
	<td>Approved Navigation Object</td>
</tr>
<tr>
	<td><img src="#cimages#/NavPending.gif" height="16" width="16" border="0"></td>
	<td>Pending Navigation Object</td>
</tr>
<tr>
	<td><img src="#cimages#/images.gif" height="16" width="16" border="0"></td>
	<td>Images</td>
</tr>
<tr>
	<td><img src="#cimages#/floppyDisk.gif" height="16" width="16" border="0"></td>
	<td>Files</td>
</tr>
<tr>
	<td><img src="#cimages#/pictureDraft.gif" height="16" width="16" border="0"></td>
	<td>Draft Image Object</td>
</tr>
<tr>
	<td><img src="#cimages#/picturePending.gif" height="16" width="16" border="0"></td>
	<td>Pending Image Object</td>
</tr>
<tr>
	<td><img src="#cimages#/pictureApproved.gif" height="16" width="16" border="0"></td>
	<td>Approved Image Object</td>
</tr>
<tr>
	<td><img src="#cimages#/includeDraft.gif" height="16" width="16" border="0"></td>
	<td>Draft Included Object</td>
</tr>
<tr>
	<td><img src="#cimages#/includePending.gif" height="16" width="16" border="0"></td>
	<td>Pending Included Object</td>
</tr>
<tr>
	<td><img src="#cimages#/includeApproved.gif" height="16" width="16" border="0"></td>
	<td>Approved Included Object</td>
</tr>
<tr>
	<td><img src="#cimages#/fileDraft.gif" height="16" width="16" border="0"></td>
	<td>Draft File Object</td>
</tr>
<tr>
	<td><img src="#cimages#/filePending.gif" height="16" width="16" border="0"></td>
	<td>Pending File Object</td>
</tr>
<tr>
	<td><img src="#cimages#/fileApproved.gif" height="16" width="16" border="0"></td>
	<td>Approved File Object</td>
</tr>
<tr>
	<td><img src="#cimages#/linkDraft.gif" height="16" width="16" border="0"></td>
	<td>Draft Link Object</td>
</tr>
<tr>
	<td><img src="#cimages#/linkPending.gif" height="16" width="16" border="0"></td>
	<td>Pending Link Object</td>
</tr>
<tr>
	<td><img src="#cimages#/linkApproved.gif" height="16" width="16" border="0"></td>
	<td>Approved Link Object</td>
</tr>
<tr>
	<td><img src="#cimages#/cssDraft.gif" height="16" width="16" border="0"></td>
	<td>Style Sheet Object</td>
</tr>
<tr>
	<td><img src="#cimages#/flashApproved.gif" height="16" width="16" border="0"></td>
	<td>Flash Object</td>
</tr>
</table>
</cfoutput>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">