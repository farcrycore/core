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
$Header: /cvs/farcry/core/tags/admin/tabitem.cfm,v 1.2 2004/07/15 02:01:35 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 02:01:35 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
Sets attributes for tab

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: onclick, id, style, target, title
out:
--->
<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfparam name="attributes.onclick" default="">
<cfparam name="attributes.id" default="">
<cfparam name="attributes.style" default="">
<cfparam name="attributes.target" default="">
<cfparam name="attributes.title" default="">

<cfassociate basetag="cf_tabs" datacollection="tabs">

<cfsetting enablecfoutputonly="No">
