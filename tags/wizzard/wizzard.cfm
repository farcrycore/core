
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
<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="wiz" >

<cfset odmWizzard = createObject("component",application.types['dmWizzard'].typepath)>


<cfif thistag.executionMode eq "Start">

	<cfparam name="attributes.ReferenceID" default="" /><!--- This can be either a UUID of an object or a typename in which case it will create a default structure of the type --->
	<cfparam name="attributes.ReturnLocation" default="#cgi.script_name#?#cgi.query_String#" />
	<cfparam name="attributes.Timeout" default="15" /><!--- Default timeout of wizzard of 15 minutes --->
	<cfparam name="attributes.r_stWizzard" default="stWizzard" /><!--- this is the WDDX packet that will be returned --->
	
	<!--- Set User login to current user --->
	<cfset attributes.UserLogin = session.dmSec.authentication.userlogin>
		
	<!--- Set to the session id given to the user by ColdFusion --->
	<cfif attributes.UserLogin EQ "anonymous">
		<cfset attributes.UserLogin = "#attributes.UserLogin##cfid##cftoken#" />
	</cfif>
	

	
	<cfset stWizzard = odmWizzard.Read(ReferenceID=attributes.ReferenceID,UserLogin=attributes.UserLogin)>
	
	<cfset CALLER[attributes.r_stWizzard] = stWizzard>
	
	
	<!--- Need Create a Form. Cant use <ft:form> because of incorrect nesting --->
	<cfif NOT isDefined("Request.farcryForm")>

		<cfset Variables.CorrectForm = 1>
		
		<cfparam name="attributes.FormName" default="farcryForm">
		<cfparam name="attributes.FormTarget" default="">
		<cfparam name="attributes.FormAction" default="#cgi.SCRIPT_NAME#?#cgi.query_string#">	
		<cfparam name="attributes.Formonsubmit" default="">
		<cfparam name="attributes.Formcss" default="">
		<cfparam name="attributes.FormClass" default="f-wrap-1">
		<cfparam name="attributes.FormStyle" default="">
		<cfparam name="attributes.FormHeading" default="">
		
		<cfparam name="Request.farcryFormList" default="">			
		
		<cfif not isDefined("Request.farcryForm.Name")>
			<cfset Request.farcryForm = StructNew()>
			<cfset Request.farcryForm.Name = attributes.FormName>	
			<cfset Request.farcryForm.Target = attributes.FormTarget>	
			<cfset Request.farcryForm.Action = attributes.FormAction>
			<cfset Request.farcryForm.stObjects = StructNew()>		
		</cfif>	
		
		<cfif listFindNoCase(request.farcryFormList, Request.farcryForm.Name)>
			<cfset Request.farcryForm.Name = "#Request.farcryForm.Name##ListLen(request.farcryFormList) + 1#">			
		</cfif>
	
		<ft:renderHTMLformStart onsubmit="#attributes.Formonsubmit#" class="#attributes.FormClass#" css="#attributes.Formcss#" style="#attributes.Formstyle#" heading="#attributes.Formheading#" />
	
	</cfif>
	

	
	
	<ft:processForm action="Cancel" url="#attributes.ReturnLocation#" >
		<cfset stResult = odmWizzard.deleteData(objectID=stWizzard.ObjectID)>
	</ft:processForm>
	
	
	<!--- If the wizzard has been submitted then do it here. --->
	<ft:processForm>
	
		
		<cfif FORM.FarcryFormSubmitButton EQ "Next">
			<cfset stWizzard.CurrentStep = stWizzard.CurrentStep + 1>
		<cfelseif FORM.FarcryFormSubmitButton EQ "Previous">
			<cfset stWizzard.CurrentStep = stWizzard.CurrentStep - 1>
		<cfelse>
			<cfset stWizzard.CurrentStep = ListFindNoCase(stWizzard.Steps,FORM.FarcryFormSubmitButton)>
		</cfif>
		
		<cfif stWizzard.CurrentStep LTE 0 OR stWizzard.CurrentStep GT ListLen(stWizzard.Steps)>
			<cfset stWizzard.CurrentStep = 1>
		</cfif>
	
		<ft:processFormObjects objectid="#stWizzard.PrimaryObjectID#" />
<!--- 		
		<cfif listLen(lSavedObjectIDs)>
			<cfset stWizzard.Data = StructNew()>
			<cfloop list="#lSavedObjectIDs#" index="i">
				<cfset typename = odmWizzard.FindType(ObjectID=i) />				
				<cfset otype = createObject("component",application.types[typename].typepath) />
				<cfset stWizzard.Data[i] = otype.getData(objectID=i) />
			</cfloop>
		</cfif> --->
		<cfset stWizzard = odmWizzard.Write(ObjectID=stWizzard.ObjectID,CurrentStep=stWizzard.CurrentStep,Data="#stWizzard.Data#")>
		
	</ft:processForm>
	
	
	<ft:processForm action="Save" url="#attributes.ReturnLocation#" >
		
		<cfloop list="#structKeyList(stWizzard.Data)#" index="i">
			<cfset stProperties = stWizzard.Data[i]>

			<cfset typename = odmWizzard.FindType(ObjectID=i) />				
			<cfset otype = createObject("component",application.types["#stWizzard.Data[i]['typename']#"].typepath) />
			<cfset stResult = otype.setData(stProperties=stProperties) />
		</cfloop>

		<cfset stResult = odmWizzard.deleteData(objectID=stWizzard.ObjectID)>
	</ft:processForm>
	
		
	<!--- Reset the steps just before running them just incase they have changes since last call. --->
	<cfset stWizzard.Steps = "">

</cfif>

<cfif thistag.executionMode eq "End">

	
	<cfset stResult = odmWizzard.Write(ObjectID=stWizzard.ObjectID,Steps=stWizzard.Steps,CurrentStep=stWizzard.CurrentStep,Data=stWizzard.Data)>

	<!--- Include Prototype light in the head --->
	<cfset Request.InHead.PrototypeLite = 1>
	<cfsavecontent variable="WizzardSubmissionJS">
		<cfoutput>
		<script language="javascript">
			function WizzardSubmission(state) {
				$('FarcryFormSubmitButton').value=state;
				$('#Request.farcryForm.Name#').submit();	
			}
			function WizzardCancelConfirm(){
				if( window.confirm("Changes made will not be saved.\nDo you still wish to Cancel?")){
					WizzardSubmission('cancel');
				}
			}
		</script>
		</cfoutput>
	</cfsavecontent>
	<cfhtmlhead text="#WizzardSubmissionJS#" />
	
	<cfoutput>
	<div id="plp-wrap">			
		<div class="pagination">
			<ul>
				<cfif stWizzard.CurrentStep LT ListLen(stWizzard.Steps)><li class="li-next"><a href="javascript:WizzardSubmission('next');">Next</a></li></cfif>
				<cfif stWizzard.CurrentStep GT 1><li class="li-prev"><a href="javascript:WizzardSubmission('previous');">Back</a></li></cfif>
			</ul>
		</div>

		<h1><img src="/farcry/images/icons/HTML.png" alt="HTML" />#ListGetAt(stWizzard.Steps,stWizzard.CurrentStep)#</h1>			
		<div id="plp-nav">
			<ul>
				<cfloop list="#stWizzard.Steps#" index="i">
					<li><a href="javascript:WizzardSubmission('#i#')"><cfif ListGetAt(stWizzard.Steps,stWizzard.CurrentStep) EQ i><strong>#i#</strong><cfelse>#i#</cfif></a></li>
				</cfloop>
				<li class="li-complete"><a href="javascript:WizzardSubmission('save');">Save</a></li>
				<li class="li-cancel"><a href="javascript:WizzardCancelConfirm();">Cancel</a></li>
			</ul>
		</div>

		<div id="plp-content">
			#stWizzard.StepHTML#
		</div>
		
		<br style="clear:both;" />
		<hr class="clear hidden" />
		
		<div class="pagination pg-bot">
			<ul>
				<cfif stWizzard.CurrentStep LT ListLen(stWizzard.Steps)><li class="li-next"><a href="javascript:WizzardSubmission('next');">Next</a></li></cfif>
				<cfif stWizzard.CurrentStep GT 1><li class="li-prev"><a href="javascript:WizzardSubmission('previous');">Back</a></li></cfif>
			</ul>
		</div>
				
	</div>
	</cfoutput>


	
	
	<!--- Need Create a Form. Cant use </ft:form> because of incorrect nesting --->
	<cfif isDefined("Variables.CorrectForm")>		
		<ft:renderHTMLformEnd />	
		<cfset dummy = structdelete(request,"farcryForm")>	
	</cfif>
	
	<!--- At the end we need to loop through all the objects and save each to db --->

</cfif>