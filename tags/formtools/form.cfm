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
		
	
		<cfset formtheme = application.fapi.getDefaultFormTheme()>
		
		
		
		<!--- Ensure that the webskin exists for the formtheme otherwise default to bootstrap --->
		<cfif structKeyExists(application.forms.formTheme.stWebskins, '#formtheme#Form') >
			<cfset modulePath = application.forms.formTheme.stWebskins['#formtheme#Form'].path>
		<cfelse>
			<cfset modulePath = application.forms.formTheme.stWebskins['bootstrapForm'].path>
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
		
			
			</cfoutput>		
	
		</cfmodule>
	

		
		<!--- Close the div if we have the ajax wrapper --->
		<cfif attributes.bAjaxSubmission AND NOT structKeyExists(form, "farcryformajaxsubmission")>
			<cfoutput></div></cfoutput>
		</cfif>
		
		
		<!--- If we are validating this form, load and initialise the validation engine.  --->
		<cfif attributes.validation>
			<skin:loadJS id="fc-jquery-validate" />

			<!--- set up validation selectors and classes based on the form theme --->
			<cfset stValConfig = structNew()>
			<cfif formtheme eq "bootstrap">
				<cfset stValConfig.wrapper = "">
				<cfset stValConfig.errorElement = "p">
				<cfset stValConfig.errorElementClass = "text-error">
				<cfset stValConfig.errorPlacementSelector = "div.control-group">
				<cfset stValConfig.fieldContainerSelector = "div.control-group">
				<cfset stValConfig.fieldContainerClass = "error">
			<cfelse>
				<cfset stValConfig.wrapper = "">
				<cfset stValConfig.errorElement = "p">
				<cfset stValConfig.errorElementClass = "errorField">
				<cfset stValConfig.errorPlacementSelector = "div.ctrlHolder">
				<cfset stValConfig.fieldContainerSelector = "div.ctrlHolder">
				<cfset stValConfig.fieldContainerClass = "error">
			</cfif>
			
			<!--- Setup farcry form validation (fv) --->
			<skin:onReady>
				<cfoutput>
				if(typeof $j('###attributes.Name#').validate != "undefined") {
					$fc.fv#attributes.Name# = $j("###attributes.Name#").validate({
						onsubmit: false, // let the onsubmit function handle the validation
						errorElement: "#stValConfig.errorElement#",
						errorClass: "#stValConfig.errorElementClass#",
						<cfif len(stValConfig.wrapper)>
							wrapper: "#stValConfig.wrapper#",  // a wrapper around the error message					   
						</cfif>					   
						errorPlacement: function(error, element) {
					  		error.prependTo( element.closest("#stValConfig.errorPlacementSelector#") );
				        },
						highlight: function(element, errorClass) {
						   $j(element).closest("#stValConfig.fieldContainerSelector#").addClass('#stValConfig.fieldContainerClass#');
						},
						unhighlight: function(element, errorClass) {
						   $j(element).closest("#stValConfig.fieldContainerSelector#").removeClass('#stValConfig.fieldContainerClass#');
						}
					});
				}
				
				</cfoutput>
			</skin:onReady>
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
			
		<!--- If we have anything in the onsubmit, use jquery to run it --->
		<skin:onReady>
			<cfoutput>
			$j('###attributes.Name#').submit(function(){	
				var valid = true;			
				<cfif attributes.validation EQ 1>
					if ( $j("###attributes.Name#").attr('fc:validate') == 'false' ) {
						$j("###attributes.Name#").attr('fc:validate',true);					
					} else {
						valid = $j('###attributes.Name#').valid();
					}
				</cfif>			
					 
				if(valid){
					
					#attributes.onSubmit#;
					
					$j("###attributes.Name# .fc-btn, ###attributes.Name# .fc-btn-link").each(function(index,el){
						
						if( $j(el).attr('fc:disableOnSubmit') ) {
							 $j(el).attr('disabled', 'disabled');
						};
						
					});
					
				} else {
					$fc.fv#attributes.Name#.focusInvalid();
					return false;
				}
		    });
			<cfif len(Request.farcryForm.defaultAction)>
				$j('###attributes.Name# input,select').on("keypress",function(e){
				if ((e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)) {
					$j('button[value="#replace(replacelist(Request.farcryForm.defaultAction,"\,!,"",##,$,%,&,',(,),*,+,.,/,:,;,<,=,>,?,@,[,],^,`,{,|,},~","\\\,\\!,\\"",\\##,\\$,\\%,\\&,\\',\\(,\\),\\*,\\+,\\.,\\/,\\:,\\;,\\<,\\=,\\>,\\?,\\@,\\[,\\],\\^,\\`,\\{,\\|,\\},\\~"), ",", "\\,", "ALL")#"]').click();
					return false;
				} else {
					return true;
				}
			});</cfif>
			</cfoutput>				
		</skin:onReady>
		
		
			
			
		<!--- Clear the farcry form from the request scope now that it is complete. --->
		<cfset dummy = structdelete(request,"farcryForm")>

	
	</cfif>

</cfif>


<cfsetting enablecfoutputonly="false" />