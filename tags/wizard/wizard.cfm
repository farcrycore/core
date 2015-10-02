<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
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
		<cfif len(application.stCOAPI[stwizard.Data[stWizard.primaryobjectid].typename].icon)>
			<cfset attributes.icon = "#application.stCOAPI[stwizard.Data[stWizard.primaryobjectid].typename].icon#" />
		<cfelse>
			<cfset attributes.icon = "file" />
		</cfif>
	</cfif>
	
	
	<!--- Need Create a Form. Cant use <ft:form> because of incorrect nesting --->
	<cfif NOT isDefined("Request.farcryForm.name")>

		<cfset Variables.CorrectForm = 1>
		
		
		<!--- import libraries --->
		<skin:loadJS id="fc-jquery" />
		<skin:loadJS id="farcry-form" />
		
		
		<cfparam name="attributes.name" default="farcryForm#randrange(1,999999999)#">
		<cfparam name="attributes.Target" default="">
		<cfparam name="attributes.Action" default="">	
		<cfparam name="attributes.method" default="post">	
		<cfparam name="attributes.onsubmit" default="">
		<cfparam name="attributes.Class" default="">
		<cfparam name="attributes.Style" default="">
		<cfparam name="attributes.Validation" default="1">
		<cfparam name="attributes.bAddFormCSS" default="true" /><!--- Uses uniform (http://sprawsm.com/uni-form/) --->
		<cfparam name="attributes.bFieldHighlight" default="true"><!--- Highlight fields when focused --->
		<cfparam name="attributes.bFocusFirstField" default="true" /><!--- Focus on first wizard element. --->
		<cfparam name="attributes.defaultAction" default="" /><!--- The default action to be used if user presses enter key on browser that doesn't fire onClick event of first button. --->
		<cfparam name="attributes.formtheme" default="#application.fapi.getDefaultFormTheme()#"><!--- The form theme to use --->

		
		
		<cfparam name="Request.farcryFormList" default="">			
		<cfif listFindNoCase(request.farcryFormList, attributes.name)>
			<cfset attributes.name = "#attributes.name##ListLen(request.farcryFormList) + 1#">			
		</cfif>		
		<cfset Request.farcryFormList = listAppend(Request.farcryFormList,attributes.name) />		
		
		
		<!--- If we have not received an action url, get the default cgi.script_name?cgi.query_string --->
		<cfif not len(attributes.action)>
			<cfset attributes.action = "#application.fapi.fixURL()#" />
		</cfif>
		
		<cfif attributes.bFocusFirstField>
			<skin:onReady>
				<cfoutput>
					$j('###attributes.name# :input:visible:enabled:first:not("button")').addClass('focus').focus();
				</cfoutput>
			</skin:onReady>
		</cfif>
		
		
	
		<cfset Request.farcryForm = StructNew()>
		<cfset Request.farcryForm.Name = attributes.Name>	
		<cfset Request.farcryForm.Target = attributes.Target>	
		<cfset Request.farcryForm.Action = attributes.Action>
		<cfset Request.farcryForm.Method = attributes.Method>
		<cfset Request.farcryForm.onSubmit = attributes.onSubmit />
		<cfset Request.farcryForm.Validation = attributes.Validation>
		<cfset Request.farcryForm.defaultAction = attributes.defaultAction>	
		<cfset Request.farcryForm.stObjects = StructNew()>		
	<!--- 
		<cfoutput>		
		<form 	action="#attributes.FormAction#" 
				method="#attributes.FormMethod#" 
				id="#attributes.name#" 
				name="#attributes.name#" 
				<cfif len(attributes.formTarget)> target="#attributes.formTarget#"</cfif> 
				enctype="multipart/form-data" 
				class="#attributes.FormClass#"  
				style="#attributes.Formstyle#" >
		</cfoutput> --->

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

	<cfmodule template="#modulePath#" attributecollection="#attributes#">
		
		<cfoutput>#innerHTML#</cfoutput>
			
	
		
		<cfset stResult = owizard.Write(ObjectID=stwizard.ObjectID,Steps=stwizard.Steps,CurrentStep=stwizard.CurrentStep,Data=stwizard.Data)>
	
		<cfset confirmation = application.rb.getResource('forms.buttons.Cancel@confirmtext','Are you sure you wish to ignore your changes?') />
		<skin:onReady>
			<cfoutput>		
			$fc.wizardSubmission = function(formname,state) {
				btnSubmit(formname,state);	
			}
			
			$fc.wizardCancelConfirm = function(formname,confirmtext) {
				if( window.confirm(confirmtext)){
					btnTurnOffServerSideValidation();
					$j('##' + formname).attr('fc:validate',false);
					$fc.wizardSubmission(formname, 'Cancel');	
				}	
			}	
			
			$j('###Request.farcryForm.Name# :input:visible:enabled:first').addClass('focus');			
			</cfoutput>
		</skin:onReady>
		
	
		<cfoutput>
		<div id="wizard-wrap">	
				
			<div class="wizard-pagination">
				<ul>
					<cfif stwizard.CurrentStep LT ListLen(stwizard.Steps)><li class="li-next"><ft:button value="Next" rbkey="forms.buttons.Next" text="Next" renderType="link" /></li></cfif>
					<cfif stwizard.CurrentStep GT 1><li class="li-prev"><ft:button value="Previous" rbkey="forms.buttons.Back" text="Back" renderType="link" /></li></cfif>
				</ul>	
			</div>
	
			<h1>
				<cfif len(attributes.icon)>
					<i class="fa #attributes.icon#"></i>
				</cfif>
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
						<li><a href="javascript:$fc.wizardSubmission('#Request.farcryForm.Name#','#i#')"><cfif ListGetAt(stwizard.Steps,stwizard.CurrentStep) EQ i><strong>#i#</strong><cfelse>#i#</cfif></a></li>
					</cfloop>
					<li class="li-complete"><a href="javascript:$fc.wizardSubmission('#Request.farcryForm.Name#','Save');"><admin:resource key="forms.buttons.Complete@label">Complete</admin:resource></a></li>
					<li class="li-cancel"><a href="javascript:$fc.wizardCancelConfirm('#Request.farcryForm.Name#', '#confirmation#');"><admin:resource key="forms.buttons.Cancel@label">Cancel</admin:resource></a></li>
				</ul>
			</div>
	
			<div id="wizard-content">
				#stwizard.StepHTML#
			</div>
			
			<br style="clear:both;" />
			<hr class="clear hidden" />
			
			<div class="wizard-pagination pg-bot">
				<ul>
					<cfif stwizard.CurrentStep LT ListLen(stwizard.Steps)><li class="li-next"><ft:button value="Next" rbkey="forms.buttons.Next" text="Next" renderType="link" /></li></cfif>
					<cfif stwizard.CurrentStep GT 1><li class="li-prev"><ft:button value="Previous" rbkey="forms.buttons.Back" text="Back" renderType="link" /></li></cfif>
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
				<input type="hidden" name="FarcryFormSubmitButtonClicked#attributes.name#" id="FarcryFormSubmitButtonClicked#attributes.name#" class="fc-button-clicked" value="" /><!--- This contains the name of the farcry button that was clicked --->
				<input type="hidden" name="FarcryFormSubmitted"  value="#attributes.name#" /><!--- Contains the name of the farcry form submitted --->
				<input type="hidden" name="SelectedObjectID" class="fc-selected-object-id" value="" /><!--- Hidden Field to take a UUID from the attributes.SelectedObjectID on ft:button --->
			
				<input type="hidden" name="farcryFormValidation" id="farcryFormValidation#attributes.name#" class="fc-server-side-validation" value="#attributes.validation#" /><!--- Let the form submission know if it to perform serverside validation --->
			</cfoutput>
			
				
		</cfif>
	
	</cfmodule>


	<cfif isDefined("Variables.CorrectForm")>		
		<cfset dummy = structdelete(request,"farcryForm")>
	</cfif>
</cfif>