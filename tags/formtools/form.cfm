<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >

 


<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>


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
		<cfparam name="attributes.Action" default="">
		
	
		<cfparam name="attributes.onsubmit" default="">
		<cfparam name="attributes.css" default="">
		<cfparam name="attributes.Class" default="">
		<cfparam name="attributes.Style" default="">
		<cfparam name="attributes.Heading" default="">
		<cfparam name="attributes.Validation" default="1">
		<cfparam name="attributes.bAjaxSubmission" default="false">
		
		
		<!--- We only render the form if FarcryForm OnExit has not been Fired. --->
		<cfif isDefined("Request.FarcryFormOnExitRun") AND Request.FarcryFormOnExitRun >			
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
		
			<!--- If the form is contained in a webskin, these variables can be determined automatically. --->
			<cfparam name="attributes.typename" default="#caller.stobj.typename#" />
			<cfparam name="attributes.webskin" default="#caller.arguments.template#" />
			<cfparam name="attributes.objectid" default="#caller.stobj.objectid#" />
			
			<!---<cfdump var="#attributes#"> --->
			<cfif NOT len(attributes.Action)>
				<cfset attributes.Action = "#application.url.farcry#/facade/ajaxFormSubmission.cfm?typename=#attributes.typename#&webskin=#attributes.webskin#&objectid=#attributes.ObjectID#" />
			</cfif>
			<cfset request.inHead.prototypelite = "true" />
			<cfset attributes.onSubmit = "#attributes.onSubmit#;$('#attributes.Name#ajaxsubmission').innerHTML='saving changes';new Ajax.Updater('#attributes.Name#formwrap', '#attributes.Action#', {asynchronous:true, parameters:Form.serialize(this)}); return false;" />
			
		<cfelseif NOT len(attributes.Action)>
			<cfset attributes.Action = "#cgi.SCRIPT_NAME#?#cgi.query_string#" />				
		</cfif>
	
		
		
		<cfif not isDefined("Request.farcryForm.Name")>
			<cfparam name="Request.farcryForm" default="#StructNew()#">
			<cfparam name="Request.farcryForm.Name" default="#attributes.Name#">
			<cfparam name="Request.farcryForm.Target" default="#attributes.Target#">
			<cfparam name="Request.farcryForm.Action" default="#attributes.Action#">
			<cfparam name="Request.farcryForm.Validation" default="#attributes.Validation#">
			<cfparam name="Request.farcryForm.stObjects" default="#StructNew()#">		
			<cfparam name="Request.farcryForm.bAjaxSubmission" default="#attributes.bAjaxSubmission#">		
		</cfif>
	
		
		
		<cfif Request.farcryForm.Validation EQ 1>
			<cfset Request.InHead.FormValidation = 1>			
		</cfif>
		
		<!--- <cfoutput><h1><a href="#cgi.SCRIPT_NAME#?#cgi.query_string#">Farcry Form #Request.farcryForm.Name#</a></h1></cfoutput> --->
		
		<ft:renderHTMLformStart onsubmit="#attributes.onsubmit#" class="#attributes.Class#" css="#attributes.css#" style="#attributes.style#" heading="#attributes.heading#" />
	
	</cfif>
	
	<cfif thistag.ExecutionMode EQ "End" and isDefined("Variables.CorrectForm")>
		
		
		
		<ft:renderHTMLformEnd />
	
	
		<cfset dummy = structdelete(request,"farcryForm")>

	
	</cfif>

</cfif>


