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
<!---
|| VERSION CONTROL ||
$Header:  $
$Author: $
$Date:  $
$Name:  $
$Revision: $

|| DESCRIPTION || 
$Description:  -- $


|| DEVELOPER ||
$Developer: Matthew Bryant (mat@daemon.com.au)$

|| ATTRIBUTES ||
$in: SessionID -- $
--->
<cfimport taglib="/farcry/core/tags/core/" prefix="core" >
<cfimport taglib="/farcry/core/tags/wizard/" prefix="wiz" >
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />

<!--- We only render the wizard if FarcryForm OnExit has not been Fired. --->
<cfif structKeyExists(request, "FarcryFormOnExitRun") AND Request.FarcryFormOnExitRun>
	<cfsetting enablecfoutputonly="false" />
	<cfexit method="exittag">
</cfif>

<cfset owizard = createObject("component",application.types['dmWizard'].typepath)>


<cfif thistag.executionMode eq "Start">

	<cfparam name="attributes.ReferenceID" default="" /><!--- This can be either a UUID of an object or a typename in which case it will create a default structure of the type --->
	<cfparam name="attributes.ReturnLocation" default="" />
	<cfparam name="attributes.Timeout" default="15" /><!--- Default timeout of wizard of 15 minutes --->
	<cfparam name="attributes.r_stwizard" default="stwizard" /><!--- this is the WDDX packet that will be returned --->
	<cfparam name="attributes.title" default="" />
	<cfparam name="attributes.icon" default="" />

	<!--- We only render the form if Farcrywizard OnExit has not been Fired. --->
	<cfif isDefined("Request.FarcrywizardOnExitRun") AND Request.FarcrywizardOnExitRun >			
		<cfexit method="exittag">			
	</cfif>
	
	<!--- Set User login to current user --->
	<cfif application.security.isLoggedIn()>
		<cfset attributes.UserLogin = application.security.getCurrentUserID()>
	<cfelse>
		<cfset attributes.UserLogin = "Unknown#cfid##cftoken#" />
	</cfif>
	
	<!--- Add required CSS to <head> --->
	<cfset Request.InHead.Wizard = 1>
	
	<cfset stwizard = owizard.Read(ReferenceID=attributes.ReferenceID,UserLogin=attributes.UserLogin)>
	
	<cfset CALLER[attributes.r_stwizard] = stwizard>
	
	
	<!--- SETUP THE DEFAULT ICON IF NOTHING PASSED --->
	<cfif not len(attributes.icon)>
		<cfset attributes.icon = "#application.stCOAPI[stwizard.Data[stWizard.primaryobjectid].typename].icon#" />
	</cfif>
	
	
	<!--- Need Create a Form. Cant use <ft:form> because of incorrect nesting --->
	<cfif NOT isDefined("Request.farcryForm.FormName")>

		<cfset Variables.CorrectForm = 1>
		
		
		<!--- import libraries --->
		<skin:loadJS id="jquery" />
		<skin:loadJS id="farcry-form" />
		
		
		<cfparam name="attributes.FormName" default="farcryForm#randrange(1,999999999)#">
		<cfparam name="attributes.FormTarget" default="">
		<cfparam name="attributes.FormAction" default="">	
		<cfparam name="attributes.FormMethod" default="post">	
		<cfparam name="attributes.Formonsubmit" default="">
		<cfparam name="attributes.Formcss" default="">
		<cfparam name="attributes.FormClass" default="">
		<cfparam name="attributes.FormStyle" default="">
		<cfparam name="attributes.FormHeading" default="">
		<cfparam name="attributes.FormValidation" default="1">
		<cfparam name="attributes.bAddWizardCSS" default="true" /><!--- Uses uniform (http://sprawsm.com/uni-form/) --->
		<cfparam name="attributes.bFieldHighlight" default="true"><!--- Highlight fields when focused --->

		<!--- I18 conversion of form heading --->
		<cfif len(attributes.FormHeading)>
			<cfset attributes.FormHeading = application.rb.getResource("forms.headings.#rereplacenocase(attributes.FormHeading,'[^\w\d]','','ALL')#@text",attributes.FormHeading) />
		</cfif>
		
		<cfparam name="Request.farcryFormList" default="">			
		<cfif listFindNoCase(request.farcryFormList, attributes.FormName)>
			<cfset attributes.FormName = "#attributes.FormName##ListLen(request.farcryFormList) + 1#">			
		</cfif>		
		<cfset Request.farcryFormList = listAppend(Request.farcryFormList,attributes.FormName) />		
		
		
		<!--- If we have not received an action url, get the default cgi.script_name?cgi.query_string --->
		<cfif not len(attributes.formAction)>
			<cfset attributes.formAction = "#application.fapi.fixURL()#" />
		</cfif>
		
		
		<!--- If this is going to be a uniform, include relevent js and css --->
		<cfif attributes.bAddWizardCSS>		
			<cfset attributes.formClass = listAppend(attributes.formClass,"uniForm"," ") />
			<skin:loadCSS id="farcry-form" />				
		</cfif>
		
		
	
		<cfset Request.farcryForm = StructNew()>
		<cfset Request.farcryForm.Name = attributes.FormName>	
		<cfset Request.farcryForm.Target = attributes.FormTarget>	
		<cfset Request.farcryForm.Action = attributes.FormAction>
		<cfset Request.farcryForm.Method = attributes.FormMethod>
		<cfset Request.farcryForm.onSubmit = attributes.FormOnSubmit />
		<cfset Request.farcryForm.Validation = attributes.FormValidation>
		<cfset Request.farcryForm.stObjects = StructNew()>		
	
		<cfoutput>		
		<form 	action="#attributes.FormAction#" 
				method="#attributes.FormMethod#" 
				id="#attributes.FormName#" 
				name="#attributes.FormName#" 
				<cfif len(attributes.formTarget)> target="#attributes.formTarget#"</cfif> 
				enctype="multipart/form-data" 
				class="#attributes.FormClass#"  
				style="#attributes.Formstyle#" >
		</cfoutput>

	</cfif>
	
	
	<!--- If the wizard has been submitted then work out the next step. --->
	<wiz:processwizard>		
		<cfif FORM.FarcryFormSubmitButton EQ "Next">
			<cfset stwizard.CurrentStep = stwizard.CurrentStep + 1>
		<cfelseif FORM.FarcryFormSubmitButton EQ "Previous">
			<cfset stwizard.CurrentStep = stwizard.CurrentStep - 1>
		<cfelseif ListFindNoCase(stwizard.Steps,FORM.FarcryFormSubmitButton)>
			<cfset stwizard.CurrentStep = ListFindNoCase(stwizard.Steps,FORM.FarcryFormSubmitButton)>
		<cfelse>
			<cfset stwizard.CurrentStep = stwizard.CurrentStep>
		</cfif>
		
		<cfif stwizard.CurrentStep LTE 0 OR stwizard.CurrentStep GT ListLen(stwizard.Steps)>
			<cfset stwizard.CurrentStep = 1>
		</cfif>
			
	</wiz:processwizard>
	

	
		
	<!--- Reset the steps just before running them just incase they have changes since last call. --->
	<cfset stwizard.Steps = "">

</cfif>

<cfif thistag.executionMode eq "End">


	<cfset stResult = owizard.Write(ObjectID=stwizard.ObjectID,Steps=stwizard.Steps,CurrentStep=stwizard.CurrentStep,Data=stwizard.Data)>


	<cfsavecontent variable="wizardSubmissionJS">
		<cfoutput>
		<script language="javascript">
			function wizardSubmission(state) {
				if (state == 'Cancel') {
					btnSubmit('#Request.farcryForm.Name#',state);
				} 
				
				<cfif Request.farcryForm.Validation>					
					//else if ( realeasyvalidation#request.farcryForm.name#.validate() ) {
					else {
						btnSubmit('#Request.farcryForm.Name#',state);
					}
				<cfelse>
					else {
						btnSubmit('#Request.farcryForm.Name#',state);
					}
				</cfif>
			}
			<cfset confirmation = application.rb.getResource('forms.buttons.Cancel@confirmtext','Changes made will not be saved.\nDo you still wish to Cancel?') />
			function wizardCancelConfirm(){
				if( window.confirm("#confirmation#")){
					btnTurnOffServerSideValidation();
					$j('###Request.farcryForm.Name#').attr('fc:validate',false);
					wizardSubmission('Cancel');
				}
			}
		</script>
		</cfoutput>
	</cfsavecontent>
	<cfhtmlHead text="#wizardSubmissionJS#" />
	<cfoutput>
	<div id="wizard-wrap">	
			
		<div class="wizard-pagination">
			<ul>
				<cfif stwizard.CurrentStep LT ListLen(stwizard.Steps)><li class="li-next"><ft:button value="Next" text="#application.rb.getResource('forms.buttons.Next@label','Next')#" renderType="link" /></li></cfif><!--- <a href="javascript:wizardSubmission('Next');">#application.rb.getResource("forms.buttons.Next@label","Next")#</a> --->
				<cfif stwizard.CurrentStep GT 1><li class="li-prev"><ft:button value="Previous" text="#application.rb.getResource('forms.buttons.Next@label','Back')#" renderType="link" /></li></cfif><!--- <a href="javascript:wizardSubmission('Previous');">#application.rb.getResource("forms.buttons.Back@label","Back")#</a> --->
			</ul>	
		</div>

		<h1><admin:icon icon="#attributes.icon#" usecustom="true" />
			<cfif len(attributes.title)>
				#attributes.title#
			<cfelse>
									
				<cfif structKeyExists(stWizard.data, stWizard.primaryObjectID) and structKeyExists(stWizard.data[stWizard.primaryObjectID], "label")>
					#stWizard.data['#stWizard.primaryObjectID#'].label#
				<cfelse>
					#ListGetAt(stwizard.Steps,stwizard.CurrentStep)#
				</cfif>
			</cfif>
		</h1>			
		<div id="wizard-nav">
			<ul>
				<cfloop list="#stwizard.Steps#" index="i">
					<li><a href="javascript:wizardSubmission('#i#')"><cfif ListGetAt(stwizard.Steps,stwizard.CurrentStep) EQ i><strong>#i#</strong><cfelse>#i#</cfif></a></li>
				</cfloop>
				<li class="li-complete"><a href="javascript:wizardSubmission('Save');">#application.rb.getResource("forms.buttons.Complete@label","Complete")#</a></li>
				<li class="li-cancel"><a href="javascript:wizardCancelConfirm();">#application.rb.getResource("forms.buttons.Cancel@label","Cancel")#</a></li>
			</ul>
		</div>

		<div id="wizard-content">
			#stwizard.StepHTML#
		</div>
		
		<br style="clear:both;" />
		<hr class="clear hidden" />
		
		<div class="wizard-pagination pg-bot">
			<ul>
				<cfif stwizard.CurrentStep LT ListLen(stwizard.Steps)><li class="li-next"><ft:button value="Next" text="#application.rb.getResource('forms.buttons.Next@label','Next')#" renderType="link" /></li></cfif><!--- <a href="javascript:wizardSubmission('Next');">#application.rb.getResource("forms.buttons.Next@label","Next")#</a> --->
				<cfif stwizard.CurrentStep GT 1><li class="li-prev"><ft:button value="Previous" text="#application.rb.getResource('forms.buttons.Next@label','Back')#" renderType="link" /></li></cfif><!--- <a href="javascript:wizardSubmission('Previous');">#application.rb.getResource("forms.buttons.Back@label","Back")#</a> --->
			</ul>			
		</div>
				
	</div>
	</cfoutput>


	
	
	<!--- Need Create a Form. Cant use </ft:form> because of incorrect nesting --->
	<cfif isDefined("Variables.CorrectForm")>				
		<cfoutput>
			<input type="hidden" id="currentwizardStep" name="currentwizardStep" value="#ListGetAt(stwizard.Steps,stwizard.CurrentStep)#" />
			<input type="hidden" id="wizardID" name="wizardID" value="#stwizard.ObjectID#" />
		</cfoutput>
		
		<!--- Render the hidden form fields used to post the state of the farcry form. --->
		<cfoutput>
			<input type="hidden" name="FarcryFormPrefixes" value="" />
			<input type="hidden" name="FarcryFormSubmitButton" value="" /><!--- This is an empty field so that if the form is submitted, without pressing a farcryFormButton, the FORM.FarcryFormSubmitButton variable will still exist. --->
			<input type="hidden" name="FarcryFormSubmitButtonClicked#attributes.formName#" id="FarcryFormSubmitButtonClicked#attributes.formName#" class="fc-button-clicked" value="" /><!--- This contains the name of the farcry button that was clicked --->
			<input type="hidden" name="FarcryFormSubmitted"  value="#attributes.formName#" /><!--- Contains the name of the farcry form submitted --->
			<input type="hidden" name="SelectedObjectID" class="fc-selected-object-id" value="" /><!--- Hidden Field to take a UUID from the attributes.SelectedObjectID on ft:button --->
		
			<input type="hidden" name="farcryFormValidation" id="farcryFormValidation#attributes.formName#" class="fc-server-side-validation" value="#attributes.formValidation#" /><!--- Let the form submission know if it to perform serverside validation --->
	
		</form>
		</cfoutput>
		
		
		
		
		<cfif attributes.bAddWizardCSS AND attributes.bFieldHighlight>
						
			<skin:onReady>
				<cfoutput>
				$j('###attributes.formName#').uniform();
				</cfoutput>
			</skin:onReady>
		</cfif>
		
		
		<!--- If we are validating this form, load and initialise the validation engine.  --->
		<cfif attributes.formValidation>
			<skin:loadJS id="jquery-validate" />
			
			<!--- Setup farcry form validation (fv) --->
			<skin:onReady>
				<cfoutput>
				$fc.fv#attributes.formName# = $j("###attributes.formName#").validate({
					onsubmit: false, // let the onsubmit function handle the validation
					errorElement: "p",
					errorClass: "errorField",					   
					errorPlacement: function(error, element) {
					   error.prependTo( element.parent("div.ctrlHolder") );
					},
					highlight: function(element, errorClass) {
					   $j(element).parent("div.ctrlHolder").addClass('error');
					},
					unhighlight: function(element, errorClass) {
					   $j(element).parent("div.ctrlHolder").removeClass('error');
					}

				});
				
				
				</cfoutput>
			</skin:onReady>
		</cfif>
		
		<!--- If we have anything in the onsubmit, use jquery to run it --->
		<skin:onReady>
			<cfoutput>
			$j('###attributes.formName#').submit(function(){
				var valid = true;			
				<cfif attributes.formValidation EQ 1>
					if ( $j("###attributes.formName#").attr('fc:validate') == 'false' ) {
						$j("###attributes.formName#").attr('fc:validate',true);					
					} else {
						valid = $j('###attributes.formName#').valid();
					}
				</cfif>			
					 
				if(valid){
					#attributes.formOnSubmit#;
				} else {
					$fc.fv#attributes.formName#.focusInvalid();
					return false;
				}
		    });
			</cfoutput>				
		</skin:onReady>
		
		<!--- <core:renderHTMLformEnd />	 --->
		<cfset dummy = structdelete(request,"farcryForm")>	
	</cfif>
	

</cfif>