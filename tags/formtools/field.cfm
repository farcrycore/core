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
<!--- @@displayname: Render a form field --->
<!--- @@description: Renders the field with label and hint if requested.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>

<cfparam name="attributes.label" default="&nbsp;"><!--- The fields label --->
<cfparam name="attributes.labelAlignment" default="inline"><!---  options:inline,block; Used by FarCry Form Layouts for positioning of labels. inline or block. --->
<cfparam name="attributes.class" default="string"><!---  The class to apply to the field wrapping div. --->
<cfparam name="attributes.bMultiField" default="false"><!--- Setting this to true, will wrap a div with a class 'multiField', that floats the field correctly, to allow more than just a simple input to be displayed. --->
<cfparam name="attributes.hint" default=""><!--- This will place a hint below the field --->


<cfif thistag.ExecutionMode eq "start">
	<cfoutput>
	<div class="ctrlHolder <cfif attributes.labelAlignment EQ "inline">inlineLabels<cfelse>blockLabels</cfif> #attributes.class#">
		<label class="label">#attributes.label#</label>
		<cfif attributes.bMultiField>
			<div class="multiField">
		</cfif>
	</cfoutput>
</cfif>



<cfif thistag.ExecutionMode eq "end">
	<cfoutput>
		<cfif attributes.bMultiField>
			</div>
		</cfif>
		<cfif len(trim(attributes.hint))>
			<p class="formHint">#trim(attributes.hint)#</p>
		</cfif>
		<br style="clear: both;"/>
	</div>	
	</cfoutput>
</cfif>

