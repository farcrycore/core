<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

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
