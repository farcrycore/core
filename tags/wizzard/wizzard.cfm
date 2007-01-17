
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
<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >
<cfimport taglib="/farcry/farcry_core/tags/wizzard/" prefix="wiz" >

<cfset oWizzard = createObject("component",application.types['dmWizzard'].typepath)>


<cfif thistag.executionMode eq "Start">

	<cfparam name="attributes.ReferenceID" default="" /><!--- This can be either a UUID of an object or a typename in which case it will create a default structure of the type --->
	<cfparam name="attributes.ReturnLocation" default="" />
	<cfparam name="attributes.Timeout" default="15" /><!--- Default timeout of wizzard of 15 minutes --->
	<cfparam name="attributes.r_stWizzard" default="stWizzard" /><!--- this is the WDDX packet that will be returned --->

	<!--- We only render the form if FarcryWizzard OnExit has not been Fired. --->
	<cfif isDefined("Request.FarcryWizzardOnExitRun") AND Request.FarcryWizzardOnExitRun >			
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
	
	<cfset stWizzard = oWizzard.Read(ReferenceID=attributes.ReferenceID,UserLogin=attributes.UserLogin)>
	
	<cfset CALLER[attributes.r_stWizzard] = stWizzard>
	
	
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
	

	
	
<!---	<wiz:processWizzard action="Cancel" url="#attributes.ReturnLocation#" >
		<cfset stResult = oWizzard.deleteData(objectID=stWizzard.ObjectID)>
		
		<!--- If a return location is not set, we want to delete the wizzard object and exit the wizzard tag. --->
		<cfif not len(attributes.ReturnLocation)>
			<cfset stResult = oWizzard.deleteData(objectID=stWizzard.ObjectID)>
			<cfexit method="exittag">	
		</cfif>
	</wiz:processWizzard> --->

	
	<!--- If the wizzard has been submitted then work out the next step. --->
	<wiz:processWizzard>		
		<cfif FORM.FarcryFormSubmitButton EQ "Next">
			<cfset stWizzard.CurrentStep = stWizzard.CurrentStep + 1>
		<cfelseif FORM.FarcryFormSubmitButton EQ "Previous">
			<cfset stWizzard.CurrentStep = stWizzard.CurrentStep - 1>
		<cfelseif ListFindNoCase(stWizzard.Steps,FORM.FarcryFormSubmitButton)>
			<cfset stWizzard.CurrentStep = ListFindNoCase(stWizzard.Steps,FORM.FarcryFormSubmitButton)>
		<cfelse>
			<cfset stWizzard.CurrentStep = stWizzard.CurrentStep>
		</cfif>
		
		<cfif stWizzard.CurrentStep LTE 0 OR stWizzard.CurrentStep GT ListLen(stWizzard.Steps)>
			<cfset stWizzard.CurrentStep = 1>
		</cfif>
			
	</wiz:processWizzard>
	
	
<!---	<wiz:processWizzard action="Save" url="#attributes.ReturnLocation#" >
		<cfloop list="#structKeyList(stWizzard.Data)#" index="i">
			<cfset stProperties = stWizzard.Data[i]>
			<cfset typename = oWizzard.FindType(ObjectID=i) />				
			<cfset otype = createObject("component",application.types["#stWizzard.Data[i]['typename']#"].typepath) />
			<cfset stResult = otype.setData(stProperties=stProperties) />
		</cfloop>
		
		<!--- If a return location is not set, we want to delete the wizzard object and exit the wizzard tag. --->
		<cfif not len(attributes.ReturnLocation)>
			<cfset stResult = oWizzard.deleteData(objectID=stWizzard.ObjectID)>
			<cfexit method="exittag">	
		</cfif>
	</wiz:processWizzard> --->
	
		
	<!--- Reset the steps just before running them just incase they have changes since last call. --->
	<cfset stWizzard.Steps = "">

</cfif>

<cfif thistag.executionMode eq "End">


	<cfset stResult = oWizzard.Write(ObjectID=stWizzard.ObjectID,Steps=stWizzard.Steps,CurrentStep=stWizzard.CurrentStep,Data=stWizzard.Data)>

	<!--- Include Prototype light in the head --->
	<cfset Request.InHead.PrototypeLite = 1>
	<cfsavecontent variable="WizzardSubmissionJS">
		<cfoutput>
		<script language="javascript">
			function WizzardSubmission(state) {
				if (state == 'Cancel') {
					$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value=state;
					$('#Request.farcryForm.Name#').submit();	
				} 
				
				<cfif Request.farcryForm.Validation>					
					else if ( realeasyvalidation.validate() ) {
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
			function WizzardCancelConfirm(){
				if( window.confirm("Changes made will not be saved.\nDo you still wish to Cancel?")){
					WizzardSubmission('Cancel');
				}
			}
		</script>
		</cfoutput>
	</cfsavecontent>
	<cfhtmlhead text="#WizzardSubmissionJS#" />
	
	<cfoutput>
	<div id="wizard-wrap">			
		<div class="wizard-pagination">
			<ul>
				<cfif stWizzard.CurrentStep LT ListLen(stWizzard.Steps)><li class="li-next"><a href="javascript:WizzardSubmission('Next');">Next</a></li></cfif>
				<cfif stWizzard.CurrentStep GT 1><li class="li-prev"><a href="javascript:WizzardSubmission('Previous');">Back</a></li></cfif>
			</ul>
		</div>

		<h1><img src="/farcry/images/icons/HTML.png" alt="HTML" />#ListGetAt(stWizzard.Steps,stWizzard.CurrentStep)#</h1>			
		<div id="wizard-nav">
			<ul>
				<cfloop list="#stWizzard.Steps#" index="i">
					<li><a href="javascript:WizzardSubmission('#i#')"><cfif ListGetAt(stWizzard.Steps,stWizzard.CurrentStep) EQ i><strong>#i#</strong><cfelse>#i#</cfif></a></li>
				</cfloop>
				<li class="li-complete"><a href="javascript:WizzardSubmission('Save');">Save</a></li>
				<li class="li-cancel"><a href="javascript:WizzardCancelConfirm();">Cancel</a></li>
			</ul>
		</div>

		<div id="wizard-content">
			#stWizzard.StepHTML#
		</div>
		
		<br style="clear:both;" />
		<hr class="clear hidden" />
		
		<div class="wizard-pagination pg-bot">
			<ul>
				<cfif stWizzard.CurrentStep LT ListLen(stWizzard.Steps)><li class="li-next"><a href="javascript:WizzardSubmission('Next');">Next</a></li></cfif>
				<cfif stWizzard.CurrentStep GT 1><li class="li-prev"><a href="javascript:WizzardSubmission('Previous');">Back</a></li></cfif>
			</ul>
		</div>
				
	</div>
	</cfoutput>


	
	
	<!--- Need Create a Form. Cant use </ft:form> because of incorrect nesting --->
	<cfif isDefined("Variables.CorrectForm")>				
		<cfoutput>
			<input type="hidden" id="currentWizzardStep" name="currentWizzardStep" value="#ListGetAt(stWizzard.Steps,stWizzard.CurrentStep)#" />
			<input type="hidden" id="wizzardID" name="wizzardID" value="#stWizzard.ObjectID#" />
		</cfoutput>
		<ft:renderHTMLformEnd />	
		<cfset dummy = structdelete(request,"farcryForm")>	
	</cfif>
	

</cfif>