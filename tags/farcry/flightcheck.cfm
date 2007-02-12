<cfoutput><h1>Flight Check for #application.applicationname#</h1></cfoutput>

<!---
STEP 1. CHECK FOR CORRECT COLD FUSION [/FARCRY] MAPPING
 --->
<cftry>
	<cfsavecontent variable="ping">
		<cfinclude template="/farcry/farcry_core/admin/ping.cfm" />
	</cfsavecontent>
	
	<cfoutput><p>Your Coldfusion [ /farcry ] mapping is currently pointing to #expandpath("/farcry")#</p></cfoutput>
	
	<cfcatch type="missinginclude"><cfoutput><p>We could not find your Coldfusion [ /farcry ] mapping.</p></cfoutput><cfabort /></cfcatch>
</cftry>


<!---
STEP 2. CHECK FOR CORRECT LOCATION OF FARCRY_CORE DIRECTORY
 --->
<cftry>
	
	<cfsavecontent variable="ping">
		<cfinclude template="/farcry/farcry_core/asdmin/ping.cfm" />
	</cfsavecontent>
	
	<cfoutput><p>Your [ farcry_core ] directory is is currently located to #expandpath("/farcry/farcry_core")#</p></cfoutput>
	
	<cfcatch type="any">
		<cfoutput>
		<p>We could not find your [ farcry_core ] directory. <br />
		If you have not placed the [ farcry_core ] directory in #expandpath("/farcry")#, please do so now.<br />
		If you would prefer to have the [ farcry_core ] directory in a different location, you will need to create a specific Coldfusion mapping called [ /farcry/farcry_core ] that points to that location.
		</p>
		</cfoutput>
		<cfabort>
	</cfcatch>
</cftry>


<!---
STEP 3. CHECK FOR CORRECT LOCATION OF FOURQ DIRECTORY
 --->
<cftry>
	
	<cfsavecontent variable="ping">
		<cfinclude template="/farcry/farcry_core/fourq/ping.cfm" />
	</cfsavecontent>
	
	<cfoutput><p>Your [ fourq ] directory is is currently located to #expandpath("/farcry/fourq")#</p></cfoutput>
	
	<cfcatch type="any">
		<cfoutput>
		<p>We could not find your [ fourq ] directory. <br />
		If you have not placed the [ fourq ] directory in #expandpath("/farcry")#, please do so now.<br />
		If you would prefer to have the [ fourq ] directory in a different location, you will need to create a specific Coldfusion mapping called [ /farcry/fourq ] that points to that location.
		</p>
		</cfoutput>
		<cfabort>
	</cfcatch>
</cftry>



<!---
STEP 4. CHECK FOR CORRECT WEBSERVER MAPPING OF APPLICATION
 --->
<cftry>
	
	<cfsavecontent variable="ping">
		<cfinclude template="/farcry/fourq/ping.cfm" />
	</cfsavecontent>
	
	<cfoutput><p>Your [ fourq ] directory is is currently located to #expandpath("/farcry/fourq")#</p></cfoutput>
	
	<cfcatch type="any">
		<cfoutput>
		<p>We could not find your [ fourq ] directory. <br />
		If you have not placed the [ fourq ] directory in #expandpath("/farcry")#, please do so now.<br />
		If you would prefer to have the [ fourq ] directory in a different location, you will need to create a specific Coldfusion mapping called [ /farcry/fourq ] that points to that location.
		</p>
		</cfoutput>
		<cfabort>
	</cfcatch>
</cftry>

<cfabort>