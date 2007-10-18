
<!--- 
|| LEGAL ||
$Copyright: Daemon 2002-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

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
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
<cfimport taglib="/farcry/core/tags/wizard/" prefix="wiz" >

<cfset owizard = createObject("component",application.types['dmWizard'].typepath)>


<cfif thistag.executionMode eq "Start">

	<cfparam name="attributes.ReferenceID" default="" /><!--- This can be either a UUID of an object or a typename in which case it will create a default structure of the type --->
	<cfparam name="attributes.ReturnLocation" default="" />
	<cfparam name="attributes.Timeout" default="15" /><!--- Default timeout of wizard of 15 minutes --->
	<cfparam name="attributes.r_stwizard" default="stwizard" /><!--- this is the WDDX packet that will be returned --->
	<cfparam name="attributes.title" default="" />

	<!--- We only render the form if Farcrywizard OnExit has not been Fired. --->
	<cfif isDefined("Request.FarcrywizardOnExitRun") AND Request.FarcrywizardOnExitRun >			
		<cfexit method="exittag">			
	</cfif>
	
	<!--- Set User login to current user --->
	<cfif isDefined("session.dmSec.authentication.userlogin")>
		<cfset attributes.UserLogin = session.dmSec.authentication.userlogin>
	<cfelse>
		<cfset attributes.UserLogin = "Unknown#cfid##cftoken#" />
	</cfif>
	
	<!--- Add required CSS to <head> --->
	<cfset Request.InHead.Wizard = 1>
	
	<cfset stwizard = owizard.Read(ReferenceID=attributes.ReferenceID,UserLogin=attributes.UserLogin)>
	
	<cfset CALLER[attributes.r_stwizard] = stwizard>
	
	
	<!--- Need Create a Form. Cant use <ft:form> because of incorrect nesting --->
	<cfif NOT isDefined("Request.farcryForm.FormName")>

		<cfset Variables.CorrectForm = 1>
		
		<cfparam name="attributes.FormName" default="farcryForm">
		<cfparam name="attributes.FormTarget" default="">
		<cfparam name="attributes.FormAction" default="#cgi.SCRIPT_NAME#?#cgi.query_string#">	
		<cfparam name="attributes.FormMethod" default="post">	
		<cfparam name="attributes.Formonsubmit" default="">
		<cfparam name="attributes.Formcss" default="">
		<cfparam name="attributes.FormClass" default="">
		<cfparam name="attributes.FormStyle" default="">
		<cfparam name="attributes.FormHeading" default="">
		<cfparam name="attributes.FormValidation" default="1">
		
		<cfparam name="Request.farcryFormList" default="">			
		
		<cfif not isDefined("Request.farcryForm.Name")>
			<cfset Request.farcryForm = StructNew()>
			<cfset Request.farcryForm.Name = attributes.FormName>	
			<cfset Request.farcryForm.Target = attributes.FormTarget>	
			<cfset Request.farcryForm.Action = attributes.FormAction>
			<cfset Request.farcryForm.Method = attributes.FormMethod>
			<cfset Request.farcryForm.Validation = attributes.FormValidation>
			<cfset Request.farcryForm.stObjects = StructNew()>		
		</cfif>	
		
		<cfif listFindNoCase(request.farcryFormList, Request.farcryForm.Name)>
			<cfset Request.farcryForm.Name = "#Request.farcryForm.Name##ListLen(request.farcryFormList) + 1#">			
		</cfif>
	
	
		<cfif Request.farcryForm.Validation EQ 1>
			<cfset Request.InHead.FormValidation = 1>			
		</cfif>
		
		<ft:renderHTMLformStart onsubmit="#attributes.Formonsubmit#" class="#attributes.FormClass#" css="#attributes.Formcss#" style="#attributes.Formstyle#" heading="#attributes.Formheading#" />
	
	</cfif>
	

	
	
<!---	<wiz:processwizard action="Cancel" url="#attributes.ReturnLocation#" >
		<cfset stResult = owizard.deleteData(objectID=stwizard.ObjectID)>
		
		<!--- If a return location is not set, we want to delete the wizard object and exit the wizard tag. --->
		<cfif not len(attributes.ReturnLocation)>
			<cfset stResult = owizard.deleteData(objectID=stwizard.ObjectID)>
			<cfexit method="exittag">	
		</cfif>
	</wiz:processwizard> --->

	
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
	
	
<!---	<wiz:processwizard action="Save" url="#attributes.ReturnLocation#" >
		<cfloop list="#structKeyList(stwizard.Data)#" index="i">
			<cfset stProperties = stwizard.Data[i]>
			<cfset typename = owizard.FindType(ObjectID=i) />				
			<cfset otype = createObject("component",application.types["#stwizard.Data[i]['typename']#"].typepath) />
			<cfset stResult = otype.setData(stProperties=stProperties) />
		</cfloop>
		
		<!--- If a return location is not set, we want to delete the wizard object and exit the wizard tag. --->
		<cfif not len(attributes.ReturnLocation)>
			<cfset stResult = owizard.deleteData(objectID=stwizard.ObjectID)>
			<cfexit method="exittag">	
		</cfif>
	</wiz:processwizard> --->
	
		
	<!--- Reset the steps just before running them just incase they have changes since last call. --->
	<cfset stwizard.Steps = "">

</cfif>

<cfif thistag.executionMode eq "End">


	<cfset stResult = owizard.Write(ObjectID=stwizard.ObjectID,Steps=stwizard.Steps,CurrentStep=stwizard.CurrentStep,Data=stwizard.Data)>

	<!--- Include Prototype light in the head --->
	<cfset Request.InHead.PrototypeLite = 1>
	<cfsavecontent variable="wizardSubmissionJS">
		<cfoutput>
		<script language="javascript">
			function wizardSubmission(state) {
				if (state == 'Cancel') {
					$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value=state;
					$('#Request.farcryForm.Name#').submit();	
				} 
				
				<cfif Request.farcryForm.Validation>					
					else if ( realeasyvalidation#request.farcryForm.name#.validate() ) {
						$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value=state;
						$('#Request.farcryForm.Name#').submit();	
					}
				<cfelse>
					else {
						$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value=state;
						$('#Request.farcryForm.Name#').submit();	
					}
				</cfif>
			}
			function wizardCancelConfirm(){
				if( window.confirm("Changes made will not be saved.\nDo you still wish to Cancel?")){
					wizardSubmission('Cancel');
				}
			}
		</script>
		</cfoutput>
	</cfsavecontent>
	<cfhtmlhead text="#wizardSubmissionJS#" />
	
	<cfoutput>
	<div id="wizard-wrap">			
		<div class="wizard-pagination">
			<ul>
				<cfif stwizard.CurrentStep LT ListLen(stwizard.Steps)><li class="li-next"><a href="javascript:wizardSubmission('Next');">Next</a></li></cfif>
				<cfif stwizard.CurrentStep GT 1><li class="li-prev"><a href="javascript:wizardSubmission('Previous');">Back</a></li></cfif>
			</ul>
		</div>

		<h1><img src="#application.url.farcry#/images/icons/html.png" alt="HTML" /><cfif len(attributes.title)>#attributes.title#<cfelse>#ListGetAt(stwizard.Steps,stwizard.CurrentStep)#</cfif></h1>			
		<div id="wizard-nav">
			<ul>
				<cfloop list="#stwizard.Steps#" index="i">
					<li><a href="javascript:wizardSubmission('#i#')"><cfif ListGetAt(stwizard.Steps,stwizard.CurrentStep) EQ i><strong>#i#</strong><cfelse>#i#</cfif></a></li>
				</cfloop>
				<li class="li-complete"><a href="javascript:wizardSubmission('Save');">Complete</a></li>
				<li class="li-cancel"><a href="javascript:wizardCancelConfirm();">Cancel</a></li>
			</ul>
		</div>

		<div id="wizard-content">
			#stwizard.StepHTML#
		</div>
		
		<br style="clear:both;" />
		<hr class="clear hidden" />
		
		<div class="wizard-pagination pg-bot">
			<ul>
				<cfif stwizard.CurrentStep LT ListLen(stwizard.Steps)><li class="li-next"><a href="javascript:wizardSubmission('Next');">Next</a></li></cfif>
				<cfif stwizard.CurrentStep GT 1><li class="li-prev"><a href="javascript:wizardSubmission('Previous');">Back</a></li></cfif>
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
		<ft:renderHTMLformEnd />	
		<cfset dummy = structdelete(request,"farcryForm")>	
	</cfif>
	

</cfif>