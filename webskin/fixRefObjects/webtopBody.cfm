<cfsetting enablecfoutputonly="true" requesttimeout="2000">
<cfprocessingDirective pageencoding="utf-8">

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<!--- enforce developer permissions on this utility --->
<sec:CheckPermission 
	permission="Developer" result="bPermitted"
	error="true"
	errorMessage="Your role does not have <strong>Developer</strong> permissions.">

<!--- 
 // process form 
--------------------------------------------------------------------------------->
<ft:processForm action="Repair Table">
	<ft:processFormObjects typename="fixRefObjects">
		<cfif stproperties.bProcessTypes>
			<cfset stResult = fixReferences()>
			<skin:bubble title="Rebuild Type/Rule References" message="#stResult.message#" tags="success" />
		</cfif>
		<cfif stproperties.bPurgeTypes>
			<cfset stResult = purgeReferences()>
			<skin:bubble title="Purge Unused Type/Rule References" message="#stResult.message#" tags="success" />
		</cfif>
		<cfif stproperties.bFixNav>
			<cfset stResult = fixNav()>
			<skin:bubble title="Navigation Sub-Objects" message="#stResult.message#" tags="success" />
		</cfif>
		<!--- <cfdump var="#stproperties#" label="Stuff in the form" /> --->
	</ft:processFormObjects>
</ft:processForm>

<!--- 
 // show alerts 
--------------------------------------------------------------------------------->
<skin:pop>
	<cfoutput>
		<div class="alert <cfif listfindnocase(message.tags,'info')> alert-info<cfelseif listfindnocase(message.tags,'error')> alert-error<cfelseif listfindnocase(message.tags,'success')> alert-success</cfif>">
			<button type='button' class='close' data-dismiss='alert'>&times;</button>
			<h4>#message.title#</h4>
			<cfif len(trim(message.message))>#message.message#</cfif>
		</div>
	</cfoutput>
</skin:pop>

<!--- 
 // view 
--------------------------------------------------------------------------------->
<ft:form>
	<ft:object typename="fixRefObjects" legend="Repair refObjects Table" />
	<ft:buttonpanel>
		<ft:button value="Repair Table" textOnSubmit="Fixing..." priority="primary" />
	</ft:buttonpanel>
</ft:form>


<!--- debugging
<cfdump var="#getTypesToFix(bRefObjects=true)#" label="Using refObjects">
<cfdump var="#getTypesToFix(bRefObjects=false)#" label="Not Using refObjects">
--->

</sec:checkpermission>
<cfsetting enablecfoutputonly="false">