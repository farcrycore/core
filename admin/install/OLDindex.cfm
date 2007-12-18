<cfsetting enablecfoutputonly="true" requesttimeout="2000">

<!--- environment varaibles --->
<cfset request.farcryVersion = "mollio" />
<cfparam name="bFlightCheckError" default="1" type="boolean" />
<cfparam name="bValidateForm" default="1" type="boolean" />
<cfparam name="qPlugins" default="#queryNew('type')#" type="query" />
<cfparam name="request.bSuccess" default="1" type="boolean" />

<!--------------------------------------------------------- 
VIEW:
 - pre-flight check
 - installation
 - post-flight check
---------------------------------------------------------->
<cfinclude template="dmHeader.cfm" />


<!--- run the initial pre-install form flight check display the installation form --->
<cfif NOT isDefined("form.proceed")>
	<cfinclude template="_preFlightCheck.cfm" />
	<cfif bFlightCheckError>
		<!--- passed pre-install, display installation form --->
	    <cfinclude template="_installForm.cfm" />
	</cfif>


<!--- process installation form --->
<cfelse>
	<!--- instantiate flight check object --->
	<cfset oFlightCheck = createObject("component", "FlightCheck") />

	<!--- run server side validation --->
	<cfset bValidateForm = oFlightCheck.validate(form) />
	
	<cfif bValidateForm>
		<!--- form passed validation, run post-install checklist --->
		<cfset bFlightCheckError = oFlightCheck.postFlightCheck(form) />
		
		<cfif NOT bFlightCheckError>
			<!--- output any flight check errors --->
			<cfset request.bsuccess=false />
			<cfoutput>
				<h1 class="errorHeading">Installation Config Error</h1>
				#oFlightCheck.displayErrors()#
			</cfoutput>
		<cfelse>
			<!--- success! pre and post checks have passed, run installation --->
			<cfinclude template="_processInstallation.cfm" />
		</cfif>
		
	<cfelse>
		<!--- server side form post error (validation) --->
		<cfoutput>
			<h1 class="errorHeading">Installation Config Error</h1>
			#oFlightCheck.displayErrors()#
			<p><a href="##" onclick="history.back();">&laquo; Back to the installation form</a></p>
		</cfoutput>
	</cfif>

</cfif>


<cfinclude template="dmFooter.cfm" />


<!------------------------------------------------------------------------------ 
POST INSTALL:
	- user has chosen to delete the sample application directory after install 
------------------------------------------------------------------------------->
<cfif (isDefined("form.proceed") AND request.bSuccess) AND isDefined("form.bDeleteApp")>
		
	<cftry>
	
		<cfif directoryExists(expandPath("/farcry/#form.siteName#/www/install"))>
			<cfset projectDirectory = expandPath("/farcry/#form.siteName#/www/install") />
			<cfdirectory action="delete" directory="#projectDirectory#" mode="777" recurse="true" />
		</cfif>
	
		<cfcatch type="any">
			<cfoutput>
				<p>An error occured when deleting #form.siteName#/www/install, please delete manually</p>
			</cfoutput>
		</cfcatch>
		
	</cftry>
	
</cfif>

<cfsetting enablecfoutputonly="false">