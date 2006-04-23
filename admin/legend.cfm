<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/legend.cfm,v 1.12 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.12 $

|| DESCRIPTION || 
$Description: Displays a legend of all icons used in the farcry tree$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfset cimages = "#application.url.farcry#/images/treeImages/customIcons">

<cfoutput>

<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;margin-top:10px">
<tr class="dataheader">
	<td>#application.adminBundle[session.dmProfile.locale].icon#</td>
	<td>#application.adminBundle[session.dmProfile.locale].meaning#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/defaultObjectDraft.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].defaultDraftHTMLobj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/defaultObjectLiveDraft.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].defaultLiveHTMLobj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/defaultObjectPending.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].defaulPendingHTMLobj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/defaultObjectApproved.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].defaultApprovedHTMLobj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/webserver.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].webserver#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/home.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].home#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/rubbish.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].trashCan#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/NavDraft.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].draftNavigationObj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/NavApproved.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].approvedNavigationObj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/NavPending.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].pendingNavigationObj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/images.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].Images#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/floppyDisk.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].Files#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/pictureDraft.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].draftImageObj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/picturePending.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].pendingImageObj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/pictureApproved.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].approvedImageObj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/includeDraft.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].draftIncludedObj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/includePending.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].pendingIncludedObj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/includeApproved.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].approvedIncludedObj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/fileDraft.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].draftFileObj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/filePending.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].pendingFileObj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/fileApproved.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].approvedFileObj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/linkDraft.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].draftLinkObj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/linkPending.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].pendingLinkObj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/linkApproved.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].approvedLinkObj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/cssDraft.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].styleSheetObj#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/flashApproved.gif" height="16" width="16" border="0"></td>
	<td>#application.adminBundle[session.dmProfile.locale].flashObj#</td>
</tr>
</table>
</cfoutput>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">