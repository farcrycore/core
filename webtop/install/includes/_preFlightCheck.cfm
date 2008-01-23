<cfsetting enablecfoutputonly="true">

<!--- 
	Run a pre-installation flight check to ensure the installer has all the requisites it needs including:
	 - Can see the core directory
	 - Can see the fourq directory
	 - Can see the plugins directory
	 - A project directory is visible via a ColdFusion mapping
 --->

<cfparam name="bFlightCheckError" default="1" type="boolean" />

<cfset oFlightCheck = createObject("component", "FlightCheck") />

<cfset bFlightCheckError = oFlightCheck.preFlightCheck() />
	
<cfif NOT bFlightCheckError>
	<!--- output any flight check errors --->
		
	<cfoutput>#oFlightCheck.displayErrors()#</cfoutput>
	
<cfelse>
	<!--- no error means there is a farcry mapping pointing to the right location, list the directories to see what plugins need installing --->
	
	<cftry>
		
		<cfif isDefined("form.preInstallSubmit")>
			<cfset sFarcryCoreDir = expandPath("#form.parentDirName#") />
		<cfelse>
			<cfset sFarcryCoreDir = expandPath("/farcry") />
		</cfif>		
		
		<cfif directoryExists(sFarcryCoreDir & "/core")>
			<!--- there is no guarantee that users will name their parent directory 'farcry', so we need see if we can access the parent dir --->
			
			<cfset qPlugins = oFlightCheck.checkPlugins(sFarcryCoreDir) />

		<cfelse>
			<!--- bugger, we can't seem to find the parent directory of core, fourq and plugins. Prompt the user to enter the parent dir name --->
						
			<cfset bFlightCheckError = 1 />
			<cfinclude template="_enterFarcryParentDir.cfm" />
						
		</cfif>		
		
		<cfcatch>
			<!--- TODO: exception handling --->
		</cfcatch>
		
	</cftry>
	
</cfif>

<cfsetting enablecfoutputonly="false">