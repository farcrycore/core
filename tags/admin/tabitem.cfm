<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/admin/tabitem.cfm,v 1.1 2003/03/20 21:35:03 brendan Exp $
$Author: brendan $
$Date: 2003/03/20 21:35:03 $
$Name: b201 $
$Revision: 1.1 $

|| DESCRIPTION || 
Sets attributes for tab

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: onclick, id, style, target, title
out:
--->
<cfsetting enablecfoutputonly="Yes">

<cfparam name="attributes.onclick" default="">
<cfparam name="attributes.id" default="">
<cfparam name="attributes.style" default="">
<cfparam name="attributes.target" default="">
<cfparam name="attributes.title" default="">

<cfassociate basetag="cf_tabs" datacollection="tabs">

<cfsetting enablecfoutputonly="No">