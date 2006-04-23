
<cfsetting enablecfoutputonly="No">

<cfparam name="attributes.callingform" default="editform">
<cfparam name="ATTRIBUTES.onClick" default="">
<cfparam name="ATTRIBUTES.bDropDown" default="true">

	<cfoutput>
	<!-- Begin : PLP Navigation Buttons -->
	<div id="PLPMoveButtons" style="margin-top:10px; text-align : center;">
	</cfoutput>

	<!--- as long as we're not the first step, display back button --->
	<cfif Caller.thisstep.name NEQ CALLER.stPLP.Steps[1].name>
		<cf_dmButton name="Back" value="&lt;&lt; Back" width="80" onClick="#ATTRIBUTES.onClick#">
	</cfif>
	
	
	<input type="hidden" name="QuickNav">
	<cfif attributes.bDropDown>
		<cfoutput><select name="Navigation" onchange="javascript:window.document.forms.#attributes.callingform#.QuickNav.value='yes';#ATTRIBUTES.onClick#;submit()" class="formfield"></cfoutput>
		<!--- abs to order things above 9 in the plp --->
		<cfloop index="i" from="1" to="#ArrayLen(CALLER.stPLP.Steps)#">
			<cfoutput>
			<option value="#CALLER.stPLP.Steps[i].name#"<cfif CALLER.thisstep.name EQ CALLER.stPLP.Steps[i].name> selected="selected"</cfif>>#CALLER.stPLP.Steps[i].name#</option></cfoutput>
		</cfloop>
		<!--- /abs --->
		</select>
	</cfif>

<cfif Caller.thisstep.name NEQ CALLER.stPLP.Steps[#arraylen(CALLER.stPLP.Steps)#].name>
	<cf_dmButton name="Submit" value="Next &gt;&gt;" width="80" onClick="#ATTRIBUTES.onClick#">
<cfelse>
	<cf_dmButton name="Submit" value="Completed &gt;&gt;" width="80" onClick="#ATTRIBUTES.onClick#">
</cfif>
	<cfoutput>
	<br><br><input type="button" onClick="location.href='#application.url.farcry#/navajo/complete.cfm';" value="Cancel" class="normalbttnstyle">
	</div>
	<!-- END : PLP Navigation Buttons -->
	</cfoutput>
	
<cfsetting enablecfoutputonly="No">
