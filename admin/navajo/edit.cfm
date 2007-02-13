<cfprocessingDirective pageencoding="utf-8">
<cfsetting enablecfoutputonly="Yes">
<!--- DEPRECATED:
		To be replaced by a central invocation point.
		eg. ../conjuror/invocation.cfm
	 --->
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/navajo/edit.cfm,v 1.5 2005/08/02 02:27:12 geoff Exp $
$Author: geoff $
$Date: 2005/08/02 02:27:12 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
$DESCRIPTION: edit object invoker for primarily tree based content; on its way out the door 20050728 GB$
$TODO: get rid of this crack ../navajo/edit.cfm GB$

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$
--->
<cflog file="deprecated" application="true" type="warning" text="../admin/navajo/edit.cfm should be replaced by call to ../conjuror/invocation.cfm" />

<!--- import tag libraries --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">

<!--- check for content type and objectid--->
<cfparam name="url.objectid" type="uuid">
<!--- type deprecated in favour of typename --->
<cfparam name="url.type" default="" type="string">
<cfparam name="url.typename" default="#url.type#" type="string">

<cfif NOT len(url.typename)>
	<cfinvoke 
		component="farcry.farcry_core.packages.fourq.fourq"
		method="findType" 
		returnvariable="typename"
		objectid="#url.objectid#" />
	<cfset url.typename=typename>
</cfif>

<!--- set up page header --->
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
	<nj:edit objectid="#url.objectid#" typename="#url.typename#" />
<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="No">