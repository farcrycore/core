<cfoutput>
<!--- help tooltips --->
<cfset help = structNew() />
<cfsavecontent variable="help.siteName">
	<strong>Application Name</strong>
	<br /><br /> 
	This is the name of your new FarCry application. 
	<br /><br /> This name will be set in the &lt;cfapplication&gt; tag and is also the physical directory name of your new application. 
	<br /><br />  Your web server mappings will/should point to this directory.
</cfsavecontent>	
<cfsavecontent variable="help.domain">
	<strong>Installer Domain Name</strong>
	<br /><br /> This needs to be the domain you are using for your installation.
	<br /><br /> Your entry here will be used to make some checks to ensure you have the correct web mappings/alias in place.
	<br /><br /> The default may not be valid on all systems. If this is the case, try 127.0.0.1 or localhost
</cfsavecontent>
	
<cfsavecontent variable="help.appDSN">
	<strong>Project DSN</strong>
	<br /><br />  
	This is the name of your datasource created in ColdFusion Administrator. 
	<br /><br /> 
	This needs to be a blank database which will then be populated by this install process.
</cfsavecontent>
<cfsavecontent variable="help.dbOwner">
	<strong>Database Owner</strong>
	<br /><br />  
	Owner of the database tables to be created. Often used values: 
	<br /><br /> 
	 - Microsoft SQL Server - dbo.<br /> - MySQL - blank<br /> - Oracle 8i+ - username<br /> - PostgreSQL - blank
</cfsavecontent>
<cfsavecontent variable="help.appMapping">
	<strong>Project Web Mapping</strong>
	<br /><br />  
	This is the relative path to your FarCry application. 
	<br /><br /> 
	If you have set up the root of your project as a web-site (eg a VirtualHost in Apache), the entry will be the default "/". 
	<br /><br />Otherwise if you have set up your project as a sub-directory of a web-site (as you might in IIS off 'localhost')
	it will be the name of your project. For example "/farcry_test" would translate to http://localhost/farcry_test
	<br /><br />See the installation guide for further information
</cfsavecontent>
<cfsavecontent variable="help.farcryMapping">
	<strong>Farcry Web Mapping</strong>
	<br /><br />  
	This is the relative path to your FarCry administration site.
	<br /><br /> 
	Use the name set in your webserver mappings that pointed to core/admin.
	<br /><br /> 
	By default this will be /farcry
</cfsavecontent>
<cfsavecontent variable="help.dbonly">
	<strong>Install Database Only</strong>
	<br /><br /> 
	This is used when you already have your site set up and config set.
	<br /><br /> 
	Only database install operations will be run. No config changes.
</cfsavecontent>
<cfsavecontent variable="help.bDeleteApp">
	<strong>Delete Installer</strong>
	<br /><br />
	When selected, the installer will be deleted at the end of the install process. 
	<br /><br />  **Note: This is highly recommended for security reasons particularly in production environments
</cfsavecontent>
</cfoutput>