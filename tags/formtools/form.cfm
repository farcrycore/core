<cfsetting enablecfoutputonly="true" />

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/core/" prefix="core" />


<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag..." />
</cfif>


<!--- We only render the form if FarcryForm OnExit has not been Fired. --->
<cfif structKeyExists(request, "FarcryFormOnExitRun") AND Request.FarcryFormOnExitRun>
	<cfsetting enablecfoutputonly="false" />			
	<cfexit method="exittag">			
</cfif>


<!--- The hierarchy of formthemes requires this to be in all nested ft:forms --->
<cfparam name="attributes.formtheme" default="#application.fapi.getDefaultFormTheme()#"><!--- The form theme to use --->


<!--- MJB
This enables the developer to wrap a <ft:form> around anything without worrying about whether it will be called within an outer <ft:form>. 
It just ignores the inner ones.
--->
<cfif ListValueCountNoCase(getbasetaglist(),"CF_FORM") EQ 1>

	
	<!--- Check to make sure that Request.farcryForm.Name exists. This is because other tags may have created Request.farcryForm but only this tag creates "Name" --->
	<cfif thistag.ExecutionMode EQ "Start" AND NOT isDefined("Request.farcryForm.Name")>

		<cfset Variables.CorrectForm = 1>
		
		<!--- If XMTHML, then we need the trailing slash --->
		<cfset tagEnding = application.fapi.getDocType().tagEnding />		
		
		<!--- import libraries --->
		<skin:loadJS id="fc-jquery" />		
		<skin:loadJS id="farcry-form" />
		<skin:loadJS id="jquery-tooltip" />
		<skin:loadCSS id="jquery-tooltip" />
		<skin:loadJS id="jquery-ajaxq" />
	
	
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
		<cfparam name="attributes.bAddFormCSS" default="true" /><!--- Add relevent form layout css --->
		<cfparam name="attributes.bGenerateCSRFToken" default="#application.fapi.getConfig("security", "bCSRFTokens", "true")#" /><!--- Generate CSRF token to the form --->
		<cfparam name="attributes.bFieldHighlight" default="true"><!--- Highlight fields when focused --->
		<cfparam name="attributes.bFocusFirstField" default="false" /><!--- Focus on first form element. --->
		<cfparam name="attributes.defaultAction" default="" /><!--- The default action to be used if user presses enter key on browser that doesn't fire onClick event of first button. --->
		<cfparam name="attributes.autoSave" default="false" /><!--- Enter boolean to toggle default autosave values on properties --->
		<cfparam name="attributes.autoSaveToSessionOnly" default="false" /><!--- If there are any autosave fields, should they save to the session only? --->


		<!--- Keeps track of all the form name in the request to make sure they are all unique --->
		<cfparam name="Request.farcryFormList" default="">		
		<cfif listFindNoCase(request.farcryFormList, attributes.Name)>
			<cfset attributes.Name = "#attributes.Name##ListLen(request.farcryFormList) + 1#">			
		</cfif>		
		<cfset Request.farcryFormList = listAppend(Request.farcryFormList,attributes.Name) />
		
		
		<!--- If we have not received an action url, get the default cgi.script_name?cgi.query_string --->
        <cfif not len(attributes.action)>
            <cfif request.mode.ajax>
                <cfset attributes.Action = "#cgi.HTTP_REFERER#" />
            <cfelse>
                <cfset attributes.Action = "#application.fapi.fixURL()#" />
            </cfif>
            
        </cfif>
        
        


		
		<cfif attributes.autoSaveToSessionOnly>
			<cfset attributes.class = listAppend(attributes.class,"autoSaveToSessionOnly"," ") />
		</cfif>
		
		<cfif attributes.bFocusFirstField>
			<skin:onReady>
				<cfoutput>
					$j('###attributes.Name# :input:visible:enabled:first:not("button")').addClass('focus').focus();
				</cfoutput>
			</skin:onReady>
		</cfif>
		

		<!--- Make sure attribute is numeric for javascript --->
		<cfif not IsBoolean(attributes.Validation) OR attributes.Validation>
			<cfset attributes.Validation = 1>
		<cfelse>
			<cfset attributes.Validation = 0>
		</cfif>

		<!--- Keep the form information available in the request scope --->
		<cfset Request.farcryForm = structNew()>
		<cfset Request.farcryForm.Name = attributes.Name>
		<cfset Request.farcryForm.Target = attributes.Target>
		<cfset Request.farcryForm.Action = attributes.Action>
		<cfset Request.farcryForm.Method = attributes.Method>
		<cfset Request.farcryForm.onSubmit = attributes.onSubmit>
		<cfset Request.farcryForm.Validation = attributes.Validation>
		<cfset Request.farcryForm.stObjects = structNew()>
		<cfset Request.farcryForm.bAjaxSubmission = attributes.bAjaxSubmission>
		<cfset Request.farcryForm.lFarcryObjectsRendered = "">	
		<cfset Request.farcryForm.defaultAction = attributes.defaultAction>	
		<cfset Request.farcryForm.autoSave = "">	


		<!--- Add form protection --->
		<cfparam name="session.stFarCryFormSpamProtection" default="#structNew()#">
		<cfparam name="session.stFarCryFormSpamProtection['#attributes.Name#']" default="#structNew()#">


	</cfif>
	
	<cfif thistag.ExecutionMode EQ "End" and isDefined("Variables.CorrectForm")>

		<cfset innerHTML = "" />
		<cfif len(thisTag.generatedContent)>
			<cfset innerHTML = thisTag.generatedContent />
			<cfset thisTag.generatedContent = "" />
		</cfif>

		<!--- Ensure that the webskin exists for the formtheme otherwise default to bootstrap --->
		<cfif structKeyExists(application.forms, "formTheme" & attributes.formtheme) AND structKeyExists(application.forms["formTheme" & attributes.formtheme].stWebskins, 'form') >
			<cfset modulePath = application.forms["formTheme" & attributes.formtheme].stWebskins['form'].path>
		<cfelse>
			<cfset modulePath = application.forms["formThemeBootstrap"].stWebskins['form'].path>
		</cfif>

	
		<!--- If submitting by ajax, append the ajax submission function call to the onsubmit. --->
		<cfif attributes.bAjaxSubmission>

			<!--- Make sure the ajax submission is told to go into ajax mode. --->
			<cfset attributes.action = application.fapi.fixURL(url=attributes.action,addvalues="ajaxmode=true") />
					
			<!--- Add the function call to onsubmit --->
			<cfsavecontent variable="sAjaxSubmission">
				<cfoutput>
		        farcryForm_ajaxSubmission('#attributes.Name#','#attributes.Action#','#attributes.ajaxMaskMsg#','#attributes.ajaxMaskCls#', #attributes.ajaxTimeout#<cfif len(attributes.ajaxTarget)>,'#attributes.ajaxTarget#'</cfif>);
		        return false;
				</cfoutput>				
			</cfsavecontent>
			
			<cfset attributes.onSubmit = "#attributes.onSubmit#;#sAjaxSubmission#" />
			
		</cfif>		



		
		<!--- Setup the ajax wrapper if this is the first render of the form. When the ajax submission is made, the returned HTML is placed in this div. --->
		<cfif attributes.bAjaxSubmission AND NOT structKeyExists(form, "farcryformajaxsubmission")>
			<cfoutput><div id="#attributes.Name#formwrap" class="ajaxformwrap"></cfoutput>				
		</cfif>
			
		<cfmodule template="#modulePath#" attributecollection="#attributes#">
			<cfoutput>#innerHTML#</cfoutput>
	
	
			<!--- Render the hidden form fields used to post the state of the farcry form. --->
			<cfoutput>
				<input type="hidden" name="FarcryFormPrefixes" value="" #tagEnding#>
				<input type="hidden" name="FarcryFormSubmitButton" value="" #tagEnding#><!--- This is an empty field so that if the form is submitted, without pressing a farcryFormButton, the FORM.FarcryFormSubmitButton variable will still exist. --->
				<input type="hidden" name="FarcryFormSubmitButtonClicked#attributes.Name#" id="FarcryFormSubmitButtonClicked#attributes.Name#" class="fc-button-clicked" value="#Request.farcryForm.defaultAction#" #tagEnding#><!--- This contains the name of the farcry button that was clicked --->
				<input type="hidden" name="FarcryFormSubmitted"  value="#attributes.Name#" #tagEnding#><!--- Contains the name of the farcry form submitted --->
				<input type="hidden" name="SelectedObjectID" class="fc-selected-object-id" value="" #tagEnding#><!--- Hidden Field to take a UUID from the attributes.SelectedObjectID on ft:button --->
			
				<input type="hidden" name="farcryFormValidation" id="farcryFormValidation#attributes.Name#" class="fc-server-side-validation" value="#attributes.Validation#" #tagEnding#><!--- Let the form submission know if it to perform serverside validation --->

				<cfif attributes.bGenerateCSRFToken>
					<input type="hidden" name="FarcryFormToken" value="#csrfGenerateToken(attributes.Name)#">
				</cfif>

			</cfoutput>		
	
		</cfmodule>
	

		
		<!--- Close the div if we have the ajax wrapper --->
		<cfif attributes.bAjaxSubmission AND NOT structKeyExists(form, "farcryformajaxsubmission")>
			<cfoutput></div></cfoutput>
		</cfif>
		
		
		
		
			
			
		<!--- Clear the farcry form from the request scope now that it is complete. --->
		<cfset dummy = structdelete(request,"farcryForm")>

	
	</cfif>

</cfif>


<cfsetting enablecfoutputonly="false" />