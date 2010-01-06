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

<cfif ListFindNoCase(ParentTag, "cf_fieldset")>
	<cfset baseTagData = getBaseTagData("cf_fieldset")>
<cfelse>
	<cfabort showerror="You must use the ft:fieldsetHelp inside of an ft:fieldset...">
</cfif>


<cfparam name="attributes.helpSection" default=""><!--- The help text to render. --->


<cfif thistag.ExecutionMode eq "start">
	<!--- Do Nothing --->
</cfif>



<cfif thistag.ExecutionMode eq "end">
	<cfif len(thisTag.generatedContent)>
		<cfset attributes.helpSection = thisTag.generatedContent />
		<cfset thisTag.generatedContent = "" />
	</cfif>

	<cfif len(trim(attributes.helpSection))>
		<cfset baseTagData.attributes.helpSection = trim(attributes.helpSection) />
	</cfif>	
</cfif>

