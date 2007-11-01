<cfprocessingDirective pageencoding="utf-8" />
<cfsetting enablecfoutputonly="true" />
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Edit Invocation --->
<!--- @@Description: edit object invoker for primarily tree based content; on its way out the door 20050728 GB --->
<!--- @@Developer: Geoff Bowers (modius@daemon.com.au) --->

<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="../admin/navajo/edit.cfm should be replaced by call to ../conjuror/invocation.cfm" />

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">

<!--- check for content type and objectid--->
<cfparam name="url.objectid" type="uuid">
<!--- type deprecated in favour of typename --->
<cfparam name="url.type" default="" type="string">
<cfparam name="url.typename" default="#url.type#" type="string">

<cfif NOT len(url.typename)>
	<cfinvoke 
		component="farcry.core.packages.fourq.fourq"
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

<cfsetting enablecfoutputonly="false" />