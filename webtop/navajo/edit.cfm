<cfprocessingDirective pageencoding="utf-8" />
<cfsetting enablecfoutputonly="true" />
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
<!--- @@displayname: Edit Invocation --->
<!--- @@Description: edit object invoker for primarily tree based content; on its way out the door 20050728 GB --->
<!--- @@Developer: Geoff Bowers (modius@daemon.com.au) --->

<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="../admin/navajo/edit.cfm should be replaced by call to ../conjuror/invocation.cfm" />

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">

<!--- check for content type and objectid--->
<cfparam name="url.objectid" type="uuid" default="#createuuid()#" />
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