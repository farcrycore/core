<cfsetting enablecfoutputonly="true" />
<cfprocessingDirective pageencoding="utf-8" />
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: $
$Author: $
$Date: $
$Name: $
$Revision: $

|| DESCRIPTION || 
$DESCRIPTION: edit object invoker for primarily tree based content; on its way out the door 20050728 GB$
$TODO: get rid of this crack edittabEdit.cfm GB$

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">

<!--- check for content type and objectid--->
<cfparam name="url.objectid" type="uuid" />
<cfparam name="url.typename" type="string" />


<cfif NOT len(url.typename)>
	<cfinvoke 
		component="farcry.core.packages.fourq.fourq"
		method="findType" 
		returnvariable="typename"
		objectid="#url.objectid#" />
	<cfset url.typename=typename />
</cfif>

<!--- set up page header --->
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectEditTab")>
	
	<nj:edit objectid="#url.objectid#" typename="#url.typename#" cancelCompleteURL="#application.url.farcry#/edittabOverview.cfm?objectid=#url.objectid#" />

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="false" />