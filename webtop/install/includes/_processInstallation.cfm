<cfsetting enablecfoutputonly="true" />
<!--- 
	Write the project Application.cfm with values taken from the installation form. To change these values
	edit the install/config_files/_Application.cfm.
	
	Any values being replaced by installation form variables are in square brackets; i.e.
		<farcry:farcryInit 
			name="[siteName]" 
			dsn="[appDSN]"
			dbType="[dbType]" 
			lFarcryLib="[plugins]" />
 --->

<cfparam name="request.bSuccess" default="1" type="boolean" />
<cfparam name="form.chkPlugins" default="" type="string" /><!--- you don't need to insall ANY plugin (including farcrycms) --->

<cfinclude template="_functions.cfm" />

<!--- don't write www/Application.cfm if the user only wants to install the DB --->
<cfif NOT isDefined("form.dbonly")>
	
		<!--- make sure you can see both www/Application.cfm and install/config_files/_Application.cfm (where we'll get the Application.cfm content from) --->
		<cfset sProjectAppFile = "#expandPath('/farcry/projects/#form.siteName#/www/Application.cfm')#" />
		<cfset sProjectConfigFile = "#expandPath('./config_files/_Application.cfm')#" />
		<cfset sProjectAppIndex = "#expandPath('/farcry/projects/#form.siteName#/www/index.cfm')#" />
		<cfset sProjectConfigIndex = "#expandPath('./config_files/_index.cfm')#" />
		
	
		<cfif NOT fileExists("#sProjectAppFile#")>
			<cfthrow detail="/farcry/projects/#form.siteName#/www/Application.cfm cannot be found." />
		</cfif>
		
		<cfif NOT fileExists("#sProjectConfigFile#")>
			<cfthrow detail="/farcry/projects/#form.siteName#/www/install/config_files/_Application.cfm cannot be found." />
		</cfif> 
	
		<cfif NOT fileExists("#sProjectAppIndex#")>
			<cfthrow detail="/farcry/projects/#form.siteName#/www/index.cfm cannot be found." />
		</cfif>
		
		<cfif NOT fileExists("#sProjectConfigIndex#")>
			<cfthrow detail="/farcry/projects/#form.siteName#/www/install/config_files/_index.cfm cannot be found." />
		</cfif>
	
			<!--- read the master config data --->
			<cffile action="read" file="#sProjectConfigFile#" variable="sApplicationInit" />
				
			<!--- i wanted to leave the form values for dbType for safety, unfortunately that meant having a crappy switch here :( --->
			<cfswitch expression="#form.dbType#">
				<cfcase value="mssql">
					<cfset sDBType = "mssql" />
				</cfcase>
				<cfcase value="ora,oracle">
					<cfset sDBType = "ora" />					
				</cfcase>
				<cfcase value="mysql">
					<cfset sDBType = "mysql" />					
				</cfcase>
				<cfcase value="postgresql">
					<cfset sDBType = "postgresql" />					
				</cfcase>
				<cfdefaultcase>
					<cfthrow detail="Could not determine database type." />
				</cfdefaultcase>
			</cfswitch>
			
			<!--- farcryInit content specific to each project --->
			<cfset sApplicationInit = replaceNoCase(sApplicationInit, "[siteName]", "#oFlightCheck.getProjectName()#") />
			<cfset sApplicationInit = replaceNoCase(sApplicationInit, "[appDSN]", "#form.appDSN#") />
			<cfset sApplicationInit = replaceNoCase(sApplicationInit, "[dbType]", "#sDBType#") />
			<cfset sApplicationInit = replaceNoCase(sApplicationInit, "[plugins]", "#form.chkPlugins#") />
			<cfif Len(form.appMapping) AND form.appMapping NEQ "/">
				<!--- add the subfolder of the web app to farcryInit --->
				<cfset sApplicationInit = replaceNoCase(sAPplicationInit, "[projectURL]", form.appMapping) />
			<cfelse>
				<!--- or set it to nothing because the app is in the root of the site --->
				<cfset sApplicationInit = replaceNoCase(sAPplicationInit, "[projectURL]", "") />
			</cfif>
			
			<!--- write the final farcry_[project]/www/Application.cfm --->
			<cffile action="write" file="#sProjectAppFile#" output="#sApplicationInit#" addnewline="false" mode="777" />
				
				
			
			<!--- read the master index data --->
			<cffile action="read" file="#sProjectConfigIndex#" variable="sIndexInit" />
			
			<!--- write the final farcry_[project]/www/index.cfm --->
			<cffile action="write" file="#sProjectAppIndex#" output="#sIndexInit#" addnewline="false" mode="777" />
		<!--- //end fileExists() --->
		
</cfif>
<!--- //end writing application config files --->


<!----------------------------------------------------------------------------------------
DATABASE INSTALLATION: 
	- Having written the application init in www/Application.cfm (or dbOnly), 
	  continue with the installation
-----------------------------------------------------------------------------------------> 
<cftry>
		
    <cfoutput>
		<div id="content">
		<h2>Installing your FarCry project</h2>
	</cfoutput>
    <cfflush />
		
	<cfscript>
		application.dsn = form.appDSN;
		application.dbType = form.dbType;
		//check for valid dbOwner
		if (len(form.dbOwner) and right(form.dbOwner,1) neq ".") {
        	application.dbowner = form.dbOwner & ".";
		} else {
			application.dbowner = form.dbOwner;
		}
		application.packagepath = "farcry.core.packages";
	    application.securitypackagepath = application.packagepath & ".security";
		application.path.project = expandPath("/farcry/projects/#form.siteName#");
		application.url.webroot = form.appMapping;
		application.url.farcry = form.farcryMapping;
		application.path.defaultImagePath = "#application.path.project#/www/images";
	    application.path.defaultFilepath = "#application.path.project#/www/files";
		application.path.core = expandPath("/farcry/core");
	    	    
		// determing browser being used
		if (cgi.http_user_agent contains "MSIE") browser = "IE"; else browser = "NS";				
	</cfscript>

	
    <!--- install farcry --->
    <cfinclude template="_installFarcry.cfm" />

    <cfcatch type="any">
		<cfdump var="#cfcatch#">
    </cfcatch>

</cftry>

<cfif request.bSuccess>
	<!--- copied by bowden 7/23/2006. copied from b300.cfm. --->
	<!--- FU updates --->
	<cftry>
	   	<cfinclude template="fu.cfm" />
	   	<cfcatch>
			<!--- display form with error message --->
			<cfset errorMsg = "Problem building friendly URL table.">
	 	   	<cfoutput>#errorMsg#</cfoutput>
	 	   	<cfdump var="#cfcatch#">
	    </cfcatch>
	</cftry>
</cfif>

<cfif request.bSuccess>
	<cfoutput>
		<div>
			<div class="item">
				<h3>Installation Success!</h3>
				<p>Default Farcry credentials (sa) are:</p>
				<ul>
					<li>U: farcry</li>
					<li>P: farcry</li>
				</ul>
				<p>Please be sure to change this account information on your first login for security reasons</p>
				<cfif isDefined("form.bDeleteApp")>
					<p>Note that your installation directory is being deleted.</p>
				</cfif>
			</div>
			<div class="itemButtons">
				<form name="installComplete" id="installComplete" method="post" action="">
					<input type="button" name="login" value="LOGIN TO FARCRY" onClick="alert('Your default Farcry login is\n\n u: farcry\n p: farcry');window.open('http://#cgi.HTTP_HOST##form.farcryMapping#/')" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle'" onMouseOut="this.className='normalbttnstyle'" />
					<input type="button" name="view" value="VIEW SITE" onClick="window.open('http://#cgi.HTTP_HOST##form.appMapping#/')" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle'" onMouseOut="this.className='normalbttnstyle'" />
				</form><br /> 
			</div>
		</div>
	</div>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false" />