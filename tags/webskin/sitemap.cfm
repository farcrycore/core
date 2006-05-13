<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/webskin/sitemap.cfm,v 1.20.2.3 2006/05/06 11:31:34 geoff Exp $
$Author: geoff $
$Date: 2006/05/06 11:31:34 $
$Name: p300_b113 $
$Revision: 1.20.2.3 $

|| DESCRIPTION || 
$Description: Farcry - Sitemap Include
This tag is really kind of DEPRECATED.  It's just a legacy shell that calls genericNav.
$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@deamon.com.au) $

|| ATTRIBUTES ||
$in: attributes.startPoint - default="application.navid.home" $
$in: attributes.depth - default="4" type="numeric"$
$in: attributes.r_navQuery - default="r_navQuery"$
$out: caller.r_navQuery - complete qNav query$
--->

<!--- import tag library --->
<cfimport taglib="/farcry/farcry_core/tags/webskin" prefix="skin">

<!--- optional attributes --->
<cfparam name="attributes.depth" default="4" type="numeric">
<cfparam name="attributes.startPoint" default="#application.navid.home#">

<!--- deprecated attributes --->
<cfparam name="attributes.bDisplay" default="true">
<cfparam name="attributes.r_navQuery" default="r_navQuery">



<!--- build site map & display --->
<skin:genericNav navID="#attributes.startPoint#" depth="#attributes.depth#">

<cfsetting enablecfoutputonly="no">