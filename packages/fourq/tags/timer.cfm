<cfsetting enablecfoutputonly="Yes">
<!--- ///////////////////////////////////////////////////
	//////	cf_timer
			created by: Mike Nimer <mnimer@allaire.com>
			created on: 9/16/2000
			
			This tag is using the GetTickCount() function in ColdFusion. to get an exact ms time a 
			section of code took to execute.
			
			Modeled after the <cfa_ExecutionTime> tag found in Spectra. But this does a little more. 
			for instance you activate it with an attribute so you can leave it in your code and use 
			a request scope variable to turn on debugging for a page, when needed. You can also have 
			the tag draw a box around the section it's timing. (IE only)
						
			Attributes:
			Label = (optional / string) - name of section with time
			bActive = (optional / true|false) - Turn on/off
			bBox = (optional / true|false) - draw box for IE browsers.
			
			examples:
			----------------
			minimal:
			<cf_timer>
				....
			</cf_timer>
			
			hard coded:
			<cf_timer label="left column" bActive="true" bBox="true">
				....
			</cf_timer>
			
			Variable based (most common usage)
			<cf_timer bActive="#request.bShowTimer#">
				....
			</cf_timer>
	////// --->

<!--- //	set defaults	//--->
<cfparam name="attributes.Label" default="execution time" type="string">
<cfparam name="attributes.bActive" default="true" type="boolean">
<cfparam name="attributes.bBox" default="true" type="boolean">

<cfif attributes.bActive>
	<cfswitch expression="#thisTag.executionMode#">
		<cfcase value="start">
			<!--- ///	create unique ID for this instance of <cf_timer>	/// --->
			<cfset timerid = replace(application.fc.utils.createJavaUUID(), "-", "", "ALL")>

			<!--- //	Fieldset logic for IE	//--->
			<cfif attributes.bBox and cgi.HTTP_User_Agent contains "MSIE">
				<cfoutput>
					<fieldset>
						<legend id="cftimer#timerid#" align="top" style="font-family: Verdana, Arial, Geneva, Helvetica, sans-serif; font-size: 12;"></legend>
				</cfoutput>
			</cfif>
			
			<cfset startTime = getTickCount()>
		</cfcase>
		
		<!--- //	Process Body	//--->
		
		<cfcase value="end">
			<cfset endTime = getTickCount()>
	
			<!--- //	Add fieldset logic for IE	//--->
			<cfif attributes.bBox and cgi.HTTP_User_Agent contains "MSIE">
				<cfoutput>
					<script language="JavaScript">
						document.all.cftimer#timerid#.innerText = "#attributes.Label#: #evaluate(endTime - startTime)#ms";
					</script>
					</fieldset>
				</cfoutput>
			<cfelse>
				<!--- //	default output.	//--->
				<cfoutput><font face="Verdana, Arial, Geneva, Helvetica, sans-serif" size="-2">[#attributes.Label#: #evaluate(endTime - startTime)#]</font></cfoutput>
			</cfif>

		</cfcase>
	</cfswitch>
</cfif>
<cfsetting enablecfoutputonly="no">