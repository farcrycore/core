<!--- 
plpNavigationMove
 - dependent on PLP navigation tags
 --->

<cfimport taglib="/farcry/tags/" prefix="farcry">

<cfif IsDefined("CALLER.FORM.Submit")>
	<cfscript>
		CALLER.thisstep.isComplete = 1;
		CALLER.thisstep.advance = 1;
	</cfscript>
<cfelseif IsDefined("CALLER.FORM.Back")>
	<cfscript>
		PrevStep = "";
	</cfscript>
	<cfloop index="i" from="1" to="#ArrayLen(CALLER.stPLP.Steps)#">
		<cfscript>
		if (CALLER.thisstep.name EQ CALLER.stPLP.Steps[i].name AND Len(PrevStep)) {
			CALLER.thisstep.nextStep = PrevStep;
		}
		PrevStep = CALLER.stPLP.Steps[i].name;
		</cfscript>
	</cfloop>
	<cfscript>
		CALLER.thisstep.isComplete = 1;
		CALLER.thisstep.advance = 1;
	</cfscript>
<cfelseif IsDefined("CALLER.FORM.QuickNav") AND CALLER.FORM.QuickNav EQ "Yes">
	<cfscript>
		CALLER.thisstep.nextStep = CALLER.FORM.Navigation;
		CALLER.thisstep.advance = 1;
		CALLER.thisstep.isComplete = 1;
	</cfscript>
</cfif>
<!--- display tabs for plp --->
<!--- <div>
	<farcry:tabs>
	<cfloop index="i" from="1" to="#ArrayLen(CALLER.stPLP.Steps)#">
		<cfif CALLER.thisstep.name EQ CALLER.stPLP.Steps[i].name>
			<farcry:tabitem class="activesubtab" href="#cgi.script_name#/#CALLER.stPLP.Steps[i].template#?#cgi.query_string#" text="#CALLER.stPLP.Steps[i].name#">
		<cfelse>
			<farcry:tabitem class="subtab" href="#cgi.script_name#/#CALLER.stPLP.Steps[i].template#?#cgi.query_string#" text="#CALLER.stPLP.Steps[i].name#">
		</cfif>
	</cfloop>
	</farcry:tabs>
</div> --->