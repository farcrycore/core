<cfsetting enablecfoutputonly="true" />

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />


<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag..." />
</cfif>

<!--- import Javascript Libraries libraries --->
<skin:htmlHead library="farcryForm" />

<!--- MJB
This enables the developer to wrap a <ft:form> around anything without worrying about whether it will be called within an outer <ft:form>. 
It just ignores the inner ones.
--->
<cfif ListValueCountNoCase(getbasetaglist(),"CF_FORM") EQ 1>

	
	<!--- Check to make sure that Request.farcryForm.Name exists. This is because other tags may have created Request.farcryForm but only this tag creates "Name" --->
	<cfif thistag.ExecutionMode EQ "Start" AND NOT isDefined("Request.farcryForm.Name")>

		<cfset Variables.CorrectForm = 1>
		
		<cfparam name="attributes.Name" default="farcryForm#randrange(1,999999999)#">
		<cfparam name="attributes.Target" default="">
		<cfparam name="attributes.Action" default="#application.fapi.fixURL()#">
		<cfparam name="attributes.method" default="post">
		
	
		<cfparam name="attributes.onsubmit" default="">
		<cfparam name="attributes.css" default=""><!--- To Override pass in the name of custom css file located in /projectWebRoot/css/ . Empty string will stop a css file being loaded. --->
		<cfparam name="attributes.bAddFormCSS" default="true" />
		<cfparam name="attributes.Class" default="">
		<cfparam name="attributes.Style" default="">
		<cfparam name="attributes.Heading" default="">
		<cfparam name="attributes.Validation" default="1">
		<cfparam name="attributes.bAjaxSubmission" default="false">
		<cfparam name="attributes.ajaxMaskMsg" default="Saving Changes">
		<cfparam name="attributes.ajaxMaskCls" default="x-mask-loading">
		
		<!--- We only render the form if FarcryForm OnExit has not been Fired. --->
		<cfif isDefined("Request.FarcryFormOnExitRun") AND Request.FarcryFormOnExitRun >
			<cfsetting enablecfoutputonly="false" />			
			<cfexit method="exittag">			
		</cfif>
		

		<cfparam name="Request.farcryFormList" default="">
		<cfif listFindNoCase(request.farcryFormList, attributes.Name)>
			<cfset attributes.Name = "#attributes.Name##ListLen(request.farcryFormList) + 1#">			
		</cfif>
				
		
		<!--------------------------------------------- 
		IF SUBMITTING BY AJAX, SET REQUIRED VARIABLES.
		 --------------------------------------------->
		<cfif attributes.bAjaxSubmission>

			<cfif NOT len(attributes.Action)>
				<cfabort showerror="You must provide the action for an ajax form submission" />
			<cfelse>
				<cfif NOT findNoCase("?",attributes.action)>
					<cfset attributes.action = "#attributes.action#?" />
				</cfif>
				<cfif NOT findNoCase("ajaxmode=true",attributes.action)>
					<cfset attributes.action = "#attributes.action#&ajaxmode=true" />
				</cfif>
			</cfif>
			
			
			<skin:htmlHead library="extJS" />

			<cfset attributes.onSubmit = "#attributes.onSubmit#;farcryForm_ajaxSubmission('#attributes.Name#','#attributes.Action#','#attributes.ajaxMaskMsg#','#attributes.ajaxMaskCls#');return false;" />
			
		<cfelseif NOT len(attributes.Action)>
			<cfset attributes.Action = "#cgi.SCRIPT_NAME#?#cgi.query_string#" />				
		</cfif>
	
		
		
		<cfif not isDefined("Request.farcryForm.Name")>
			<cfparam name="Request.farcryForm" default="#StructNew()#">
			<cfparam name="Request.farcryForm.Name" default="#attributes.Name#">
			<cfparam name="Request.farcryForm.Target" default="#attributes.Target#">
			<cfparam name="Request.farcryForm.Action" default="#attributes.Action#">
			<cfparam name="Request.farcryForm.Method" default="#attributes.Method#">
			<cfparam name="Request.farcryForm.onSubmit" default="#attributes.onSubmit#">
			<cfparam name="Request.farcryForm.Validation" default="#attributes.Validation#">
			<cfparam name="Request.farcryForm.stObjects" default="#StructNew()#">		
			<cfparam name="Request.farcryForm.bAjaxSubmission" default="#attributes.bAjaxSubmission#">	
			<cfparam name="Request.farcryForm.lFarcryObjectsRendered" default="">		
		</cfif>
	
		
		
		<cfif Request.farcryForm.Validation EQ 1>
			<skin:htmlHead library="FormValidation" />		
		</cfif>
		
		<!--- ADD FORM PROTECTION --->
		<cfparam name="session.stFarCryFormSpamProtection" default="#structNew()#" />
		<cfparam name="session.stFarCryFormSpamProtection['#Request.farcryForm.Name#']" default="#structNew()#" />
			
		<ft:renderHTMLformStart attributeCollection="#attributes#" />
	
	</cfif>
	
	<cfif thistag.ExecutionMode EQ "End" and isDefined("Variables.CorrectForm")>


	<!--- TODO: locking of objects needs to be handled. This is causing problems however as it locks things that shouldnt be locked. --->
<!---		<cfparam name="session.dmSec.authentication.userlogin" default="anonymous" />
		<cfparam name="session.dmSec.authentication.userDirectory" default="clientud" />
		
		<cfif structkeyexists(Request.farcryForm, "stObjects") AND len(structKeyList(Request.farcryForm.stObjects))>

			<cfloop list="#structKeyList(Request.farcryForm.stObjects)#" index="i">
				<cfif structkeyexists(Request.farcryForm.stObjects[i], "FARCRYFORMOBJECTINFO") 
					AND structkeyexists(Request.farcryForm.stObjects[i].FarcryFormObjectInfo, "objectid")
					AND structkeyexists(Request.farcryForm.stObjects[i].FarcryFormObjectInfo, "typename")
					AND structkeyexists(Request.farcryForm.stObjects[i].FarcryFormObjectInfo, "Lock") 
					AND Request.farcryForm.stObjects[i].FarcryFormObjectInfo.Lock >
					
					<cfset oType = createObject("component", application.types[Request.farcryForm.stObjects[i].FarcryFormObjectInfo.typename].packagepath) />
					<cfset stType = oType.getData(objectid=Request.farcryForm.stObjects[i].FarcryFormObjectInfo.objectID) />
					<cfset oType.setLock(locked=true,lockedby="application.security.getCurrentUserID()") >
				</cfif>
			</cfloop>
		</cfif> --->
		
		<ft:renderHTMLformEnd attributeCollection="#attributes#" />
	
	
		<cfset dummy = structdelete(request,"farcryForm")>

	
	</cfif>

</cfif>


<cfsetting enablecfoutputonly="false" />