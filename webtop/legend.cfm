<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/legend.cfm,v 1.12 2005/08/09 03:54:40 geoff Exp $
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
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfset cimages = "#application.url.farcry#/images/treeImages/customIcons">

<cfoutput>

<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;margin-top:10px">
<tr class="dataheader">
	<td>#application.rb.getResource("icon")#</td>
	<td>#application.rb.getResource("meaning")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/defaultObjectDraft.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("defaultDraftHTMLobj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/defaultObjectLiveDraft.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("defaultLiveHTMLobj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/defaultObjectPending.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("defaulPendingHTMLobj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/defaultObjectApproved.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("defaultApprovedHTMLobj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/webserver.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("webserver")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/home.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("home")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/rubbish.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("trashCan")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/NavDraft.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("draftNavigationObj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/NavApproved.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("approvedNavigationObj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/NavPending.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("pendingNavigationObj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/images.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("Images")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/floppyDisk.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("Files")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/pictureDraft.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("draftImageObj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/picturePending.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("pendingImageObj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/pictureApproved.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("approvedImageObj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/includeDraft.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("draftIncludedObj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/includePending.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("pendingIncludedObj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/includeApproved.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("approvedIncludedObj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/fileDraft.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("draftFileObj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/filePending.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("pendingFileObj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/fileApproved.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("approvedFileObj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/linkDraft.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("draftJoinObj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/linkPending.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("pendingLinkObj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/linkApproved.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("approvedLinkObj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/cssDraft.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("styleSheetObj")#</td>
</tr>
<tr>
	<td align="center"><img src="#cimages#/flashApproved.gif" height="16" width="16" border="0"></td>
	<td>#application.rb.getResource("flashObj")#</td>
</tr>
</table>
</cfoutput>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">