<cfsetting enablecfoutputonly="true">
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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@displayname: farcryButtonPanel --->
<!--- @@Description: Wrapper for farcry buttons. --->
<!--- @@Developer: Matthew Bryant (mbryant@daemon.com.au) --->


<!--- Import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >

<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>

<cfparam name="attributes.id" default="#application.fc.utils.createJavaUUID()#" />
<cfparam name="attributes.indentForLabel" default="true" />

<cfif thistag.ExecutionMode EQ "Start">
	<cfoutput>
		<div id="#attributes.id#" class="farcryButtonPanel">
			<cfif attributes.indentForLabel>
			<div class="fieldSection">
				<label class="fieldsectionlabel">&nbsp;</label>
				<div class="fieldAlign">
			</cfif>
	</cfoutput>
</cfif>

<cfif thistag.ExecutionMode EQ "End">

	<cfoutput>
			<cfif attributes.indentForLabel>
					</div>
				</div>
			</cfif>
			<br style="height:0px;clear:both;" />
		</div>
	</cfoutput>

</cfif>


<cfsetting enablecfoutputonly="false">
