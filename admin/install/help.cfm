<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>FarCry Install Help</title>
	<link rel="STYLESHEET" type="text/css" href="installer.css">
</head>

<body onBlur="window.close();">

<cfswitch expression="#url.topic#">
	<cfcase value="siteName">
		<strong>Site Name</strong><p></p>
		This is the name of your new FarCry application.<p></p>
		Your entry here will be set in the &lt;application&gt; tag and will also be the physical directory name of your new application.<p></p>
		Your web server mappings will/should point to this directory.<p></p>
		Do not use farcry_aura as your site name.
	</cfcase>

	<cfcase value="dsn">
		<strong>Installation DSN</strong><p></p>
		This is the name of your datasource created in the ColdFusion administrator.<p></p>
		This needs to be a blank database which will then be populated by this install process.
	</cfcase>

	<cfcase value="dbType">
		<strong>DB Type</strong><p></p>
		This is the type of database you are using. Options available are:
		<ul>
			<li>Microsoft SQL Server</li>
			<li>MySQL</li>
			<li>Oracle 8i+</li>
			<li>PostgreSQL</li>
		</ul>
		This is required so the correct creation scripts are used.
	</cfcase>

	<cfcase value="dbOwner">
		<strong>DB Owner</strong><p></p>
		Owner of the database tables to be created. Often used values:
		<ul>
			<li>Microsoft SQL Server - dbo.</li>
			<li>MySQL - blank</li>
			<li>Oracle 8i+ - username.</li>
			<li>PostgreSQL - blank</li>
		</ul>
	</cfcase>

	<cfcase value="appMapping">
		<strong>Application Mapping</strong><p></p>
		This is the relative path to your FarCry application.<p></p>
		If you have set up your FarCry site to run from the home directory of your webserver, the entry will be "/". <p></p>
		Otherwise it will be the name of your mapping eg "/farcry_test"<p></p>
		Read <a href="http://farcry.daemon.com.au/index.cfm?objectid=8FC207CA-D0B7-4CD6-F98CB22FF2DA0952" target="_blank">tech note</a> about setting up FarCry to run alongside your existing applications.
	</cfcase>

	<cfcase value="farcryMapping">
		<strong>FarCry Mapping</strong><p></p>
		This is the relative path to your FarCry administration site.<p></p>
		Use the name set in your webserver mappings that pointed to farcry_core/admin.<p></p>
		By default this will be /farcry
	</cfcase>

	<cfcase value="domain">
		<strong>Domain</strong><p></p>
		The domain name used by your site.<p></p>
		eg. www.daemon.com.au<p></p>
		Defaults to localhost and you may not need to change it.<p></p>
		<p>No need for port numbers here.</p>
		<P>
		If you are installing multiple instances of FarCry you can set the
		domain (or sub-domain) here.
		</P>
	</cfcase>

	<cfcase value="dbOnly">
		<strong>Install Database Only</strong><p></p>
		This is used when you already have your site set up and config set.<p></p>
		Only database install operations will be run. No config changes.<p></p>
	</cfcase>

	<cfcase value="IIS">
		<strong>Setup IIS Mappings</strong><p></p>
		If you are running IIS 5 in a Win 2K environment, check this option to creat your web server mappings automatically.<p></p>
		Not using IIS? Your mappings should have already been created but check out this <a href="http://farcry.daemon.com.au/index.cfm?objectid=52589707-D0B7-4CD6-F94813CD428BEE67" target="_blank">tech note</a> for example mappings
	</cfcase>

	<cfcase value="OSType">
		<strong>Windows OS Type</strong><p></p>
		What version of windows you are running. Server or workstation.
	</cfcase>

	<cfcase value="hostHeader">
		<strong>Host Header Name</strong><p></p>
		Domain name to associate with the web server mapping <p></p>
		eg. www.daemon.com.au<p></p>
		This is an optional attribute.
	</cfcase>

	<cfcase value="IISScripts">
		<strong>IIS Admin Scripts Path</strong><p></p>
		Domain name to associate with the web server mapping <p></p>
		eg. www.daemon.com.au<p></p>
		This is an optional attributes.
	</cfcase>

	<cfcase value="deleteApp">
		<strong>Delete farcry_aura on completion</strong><p></p>
		When selected, the farcry_aura directory will be deleted at the end of the install process. Leave unchecked if you wish to perform multiple installs.<p></p>
	</cfcase>
</cfswitch>


</body>
</html>
