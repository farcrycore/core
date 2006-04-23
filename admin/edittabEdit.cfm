<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/edittabEdit.cfm,v 1.5 2003/09/11 01:26:52 brendan Exp $
$Author: brendan $
$Date: 2003/09/11 01:26:52 $
$Name: b201 $
$Revision: 1.5 $

|| DESCRIPTION || 
$DESCRIPTION: edit object $
$TODO:  $ 

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in:$ 
$out:$
--->

<!--- check permissions --->
<cfscript>
	iEditTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectEditTab");
</cfscript>

<cfsetting enablecfoutputonly="Yes">

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iEditTab eq 1>
	<cfinvoke 
	 component="farcry.fourq.fourq"
	 method="findType" returnvariable="typeid">
		<cfinvokeargument name="objectid" value="#url.objectid#"/>
	</cfinvoke>
	
	<cfparam name="url.type" default="#typeid#">
	
	<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">
	
	<nj:edit>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="No">