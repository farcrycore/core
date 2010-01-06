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
<!--- @@displayname: Set fieldHint --->
<!--- @@description: Sets the Field Hint of the parent ft:field  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>

<cfset ParentTag = GetBaseTagList()>

<cfif ListFindNoCase(ParentTag, "cf_field")>
	<cfset baseTagData = getBaseTagData("cf_field")>
<cfelse>
	<cfabort showerror="You must use the ft:fieldHint inside of an ft:field...">
</cfif>


<cfparam name="attributes.hint" default=""><!--- The hint to render. --->


<cfif thistag.ExecutionMode eq "start">
	<!--- Do Nothing --->
</cfif>



<cfif thistag.ExecutionMode eq "end">
	<cfif len(thisTag.generatedContent)>
		<cfset attributes.hint = thisTag.generatedContent />
		<cfset thisTag.generatedContent = "" />
	</cfif>

	<cfif len(trim(attributes.hint))>
		<cfset baseTagData.attributes.hint = trim(attributes.hint) />
	</cfif>	
</cfif>

