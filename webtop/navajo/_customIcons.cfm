<cfsetting enablecfoutputonly="Yes">
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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/navajo/_customIcons.cfm,v 1.16 2005/10/17 00:47:55 paul Exp $
$Author: paul $
$Date: 2005/10/17 00:47:55 $
$Name: milestone_3-0-1 $
$Revision: 1.16 $

|| DESCRIPTION || 
$Description: Sets icons to images$

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

--->
<cfscript>
nimages = "#application.url.farcry#/images/treeImages";
cimages = "#nimages#/customIcons";
customIcons = StructNew();

customIcons.Type = StructNew();
customIcons.Type.default = StructNew();
customIcons.Type.default.draft ="#cimages#/defaultObjectDraft.gif";
customIcons.Type.default.pending ="#cimages#/defaultObjectPending.gif";
customIcons.Type.default.approved ="#cimages#/defaultObjectApproved.gif";
customIcons.Type.default.livedraft ="#cimages#/defaultObjectLiveDraft.gif";
customIcons.Type.default.livependingdraft ="#cimages#/defaultObjectLivePendingDraft.gif";

customIcons.Type.imageRoot = StructNew();
customIcons.Type.imageRoot.draft = "#cimages#/images.gif";
customIcons.Type.imageRoot.pending = "#cimages#/images.gif";
customIcons.Type.imageRoot.approved = "#cimages#/images.gif";

customIcons.Type.home = StructNew();
customIcons.Type.home.draft = "#cimages#/home.gif";
customIcons.Type.home.pending = "#cimages#/home.gif";
customIcons.Type.home.approved = "#cimages#/home.gif";

customIcons.Type.Rubbish = StructNew();
customIcons.Type.Rubbish.draft = "#cimages#/rubbish.gif";
customIcons.Type.Rubbish.pending = "#cimages#/rubbish.gif";
customIcons.Type.Rubbish.approved = "#cimages#/rubbish.gif";

customIcons.Type.root = StructNew();
customIcons.Type.root.draft = "#cimages#/webserver.gif";
customIcons.Type.root.pending = "#cimages#/webserver.gif";
customIcons.Type.root.approved = "#cimages#/webserver.gif";

customIcons.Type.FileRoot = StructNew();
customIcons.Type.FileRoot.draft = "#cimages#/floppyDisk.gif";
customIcons.Type.FileRoot.pending = "#cimages#/floppyDisk.gif";
customIcons.Type.FileRoot.approved = "#cimages#/floppyDisk.gif";

customIcons.Type.externallink = StructNew();
customIcons.Type.externallink.draft ="#cimages#/NavDraftExtLink.gif";
customIcons.Type.externallink.pending ="#cimages#/NavPendingExtLink.gif";
customIcons.Type.externallink.approved ="#cimages#/NavApprovedExtLink.gif";

if( StructKeyExists( application.types, "dmNavigation" ) )
{
	customIcons.Type.dmnavigation = StructNew();
	customIcons.Type.dmnavigation.draft ="#cimages#/NavDraft.gif";
	customIcons.Type.dmnavigation.pending ="#cimages#/NavPending.gif";
	customIcons.Type.dmnavigation.approved ="#cimages#/NavApproved.gif";
}

if( StructKeyExists( application.types, "dmImage" ) )
{
	customIcons.Type.dmImage = StructNew();
	customIcons.Type.dmImage.draft ="#cimages#/pictureDraft.gif";
	customIcons.Type.dmImage.pending ="#cimages#/picturePending.gif";
	customIcons.Type.dmImage.approved ="#cimages#/pictureApproved.gif";
}

if( StructKeyExists( application.types, "dmInclude" ) )
{
	customIcons.Type.dmInclude = StructNew();
	customIcons.Type.dmInclude.draft ="#cimages#/includeDraft.gif";
	customIcons.Type.dmInclude.pending ="#cimages#/includePending.gif";
	customIcons.Type.dmInclude.approved ="#cimages#/includeApproved.gif";
}

if( StructKeyExists( application.types, "dmFile" ) )
{
	customIcons.Type.dmFile = StructNew();
	customIcons.Type.dmFile.draft ="#cimages#/fileDraft.gif";
	customIcons.Type.dmFile.pending ="#cimages#/filePending.gif";
	customIcons.Type.dmFile.approved ="#cimages#/fileApproved.gif";
}

if( StructKeyExists( application.types, "dmCSS" ) )
{
	customIcons.Type.dmCSS = StructNew();
	customIcons.Type.dmCSS.draft ="#cimages#/cssDraft.gif";
	customIcons.Type.dmCSS.pending ="#cimages#/cssDraft.gif";
	customIcons.Type.dmCSS.approved ="#cimages#/cssDraft.gif";
}

if( StructKeyExists( application.types, "dmFlash" ) )
{
	customIcons.Type.dmFlash = StructNew();
	customIcons.Type.dmFlash.draft ="#cimages#/flashApproved.gif";
	customIcons.Type.dmFlash.pending ="#cimages#/flashApproved.gif";
	customIcons.Type.dmFlash.approved ="#cimages#/flashApproved.gif";
}

if( StructKeyExists( application.types, "dmLink" ) )
{
	customIcons.Type.dmLink = StructNew();
	customIcons.Type.dmLink.draft ="#cimages#/linkDraft.gif";
	customIcons.Type.dmLink.pending ="#cimages#/linkPending.gif";
	customIcons.Type.dmLink.approved ="#cimages#/linkApproved.gif";
}

customIcons.locked = "#cimages#/padlock.gif";
</cfscript>

<cfif fileexists("#application.path.project#/system/overviewTree/_customIcons.cfm")>
	<cfinclude template="/farcry/projects/#application.projectDirectoryName#/system/overviewTree/_customIcons.cfm">
</cfif>

<cfsetting enablecfoutputonly="No">
