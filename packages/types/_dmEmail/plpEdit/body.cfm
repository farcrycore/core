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
$Header: /cvs/farcry/core/packages/types/_dmEmail/plpEdit/body.cfm,v 1.5 2005/09/02 06:27:37 guy Exp $
$Author: guy $
$Date: 2005/09/02 06:27:37 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: body step for dmNews plp. Displays text editor with option to toggle to plain html text area. $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->
<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/widgets" prefix="widgets">
<cfinclude template="/farcry/core/webtop/includes/utilityFunctions.cfm">

<!--- check for toggle option --->
<cfif isdefined("form.toggle")>
	<cfset session.toggleTextArea = 1>
<cfelse>
	<cfset session.toggleTextArea = 0>
</cfif>

<cfset onClickEvent = fGetOnclickEvent()>

<!--- copy related items to a list for looping --->

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<widgets:plpAction>

<cfif NOT thisstep.isComplete>

<widgets:plpWrapper><cfoutput>
<form action="#cgi.script_name#?#cgi.query_string#" name="editform" method="post">
	<label for="body"><b>Body:</b>
		<textarea name="body" id="body">#output.body#</textarea>
	</label>

	<input type="hidden" name="plpAction" value="" />
	<input type="hidden" name="bBodySubmit" value="1" />
	<input style="display:none;" type="submit" name="buttonSubmit" value="submit" />
</form></cfoutput>
</widgets:plpWrapper>

<cfelse>
	<widgets:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="No">
