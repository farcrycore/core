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
<cfparam name="attributes.for" default=""><!--- The fieldname the label is for --->
<cfparam name="attributes.class" default="string"><!---  The class to apply to the field wrapping div. --->
<cfparam name="attributes.style" default=""><!---  The class to apply to the field wrapping div. --->
<cfparam name="attributes.hint" default=""><!--- This will place a hint below the field --->
<cfparam name="attributes.errorMessage" default=""><!--- This will place an errormessage above the field --->
<cfparam name="attributes.rbkey" default="coapi.field.#rereplace(attributes.label,'[^\w]','','ALL')#" /><!--- The resource path for this field. --->

<cfif thistag.ExecutionMode eq "start">
	<!--- Do Nothing --->
</cfif>



<cfif thistag.ExecutionMode eq "end">


	<cfset innerHTML = "" />
	<cfif len(thisTag.generatedContent)>
		<cfset innerHTML = thisTag.generatedContent />
		<cfset thisTag.generatedContent = "" />
	</cfif>
	
	
	<cfif len(attributes.label) and len(attributes.rbkey)>
		<cfset attributes.label = application.fapi.getResource(key=attributes.rbkey & "@label",default=attributes.label) />
	</cfif>
	<cfif len(attributes.hint) and len(attributes.rbkey)>
		<cfset attributes.hint = application.fapi.getResource(key=attributes.rbkey & "@hint",default=attributes.hint) />
	</cfif>
	
	
	
	<cfoutput>
		
		<cfif attributes.labelAlignment EQ 'inline'>
			<div class="form-horizontal">
		</cfif>
		
			<div class="control-group #attributes.class#" style="#attributes.style#">
				
				<cfif len(attributes.errorMessage)>
					<p class="text-error">#attributes.errorMessage#</p>
				</cfif>
				
				<cfif len(attributes.label)>
					<label class="control-label" <cfif len(attributes.for)>for="#attributes.for#"</cfif>>
						#attributes.label#
					</label>
				</cfif>
				
				<div class="controls">
		
					#innerHTML#
			
					<cfif len(trim(attributes.hint))>
						<span class="help-inline">#trim(attributes.hint)#</span>
					</cfif>
				</div>
				
			</div>	
			
		<cfif attributes.labelAlignment EQ 'inline'>
			</div>
		</cfif>
		
	</cfoutput>
</cfif>

