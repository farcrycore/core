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
<!--- @@displayname: Render a form  --->
<!--- @@description: Renders the farcry form with relevent css and markup.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>

<cfparam name="attributes.Name" default="farcryForm#randrange(1,999999999)#">
<cfparam name="attributes.Target" default="">
<cfparam name="attributes.Action" default="">
<cfparam name="attributes.method" default="post">
<cfparam name="attributes.onsubmit" default="">
<cfparam name="attributes.Class" default="">
<cfparam name="attributes.Style" default="">
<cfparam name="attributes.Validation" default="1">
<cfparam name="attributes.bAjaxSubmission" default="false">
<cfparam name="attributes.ajaxMaskMsg" default="Form Submitting, please wait...">
<cfparam name="attributes.ajaxMaskCls" default="x-mask-loading">
<cfparam name="attributes.ajaxTimeout" default="30">
<cfparam name="attributes.ajaxTarget" default=""><!--- jQuery selector specifying the target element for the form response. Defaults to the FORM element. --->
<cfparam name="attributes.bAddFormCSS" default="true" /><!--- Uses uniform (http://sprawsm.com/uni-form/) --->
<cfparam name="attributes.bFieldHighlight" default="true"><!--- Highlight fields when focused --->
<cfparam name="attributes.bFocusFirstField" default="false" /><!--- Focus on first form element. --->
<cfparam name="attributes.defaultAction" default="" /><!--- The default action to be used if user presses enter key on browser that doesn't fire onClick event of first button. --->
<cfparam name="attributes.autoSave" default="false" /><!--- Enter boolean to toggle default autosave values on properties --->
<cfparam name="attributes.autoSaveToSessionOnly" default="false" /><!--- If there are any autosave fields, should they save to the session only? --->

<cfif thistag.ExecutionMode eq "start">
	<!--- Do Nothing --->
</cfif>



<cfif thistag.ExecutionMode eq "end">


	<cfset innerHTML = "" />
	<cfif len(thisTag.generatedContent)>
		<cfset innerHTML = thisTag.generatedContent />
		<cfset thisTag.generatedContent = "" />
	</cfif>
	
	<cfif attributes.bAddFormCSS>
		<skin:loadCSS id="farcry-form" />
	</cfif>

	<cfoutput>
	<form 	action="#attributes.Action#" 
			method="#attributes.Method#" 
			id="#attributes.Name#" 
			name="#attributes.Name#" 
			<cfif len(attributes.Target)> target="#attributes.Target#"</cfif> 
			enctype="multipart/form-data" 
			class="#attributes.class#"  
			style="#attributes.style#" >
		
			#innerHTML#
			
	</form>
		
	</cfoutput>
</cfif>

