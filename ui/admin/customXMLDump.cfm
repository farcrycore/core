<cfsetting enablecfoutputonly="yes">

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<body>

<span class="formHeader">Custom XML Dump</span>
		<cfif isXMLDoc(application.customAdminXML)>
			<cfdump var="#application.customAdminXML#" label="application.customAdminXML"><cfoutput><p>&nbsp;</p></cfoutput>
		<cfelse>
			<cfoutput><h3>No VALID Custom Admin XML schema defined </h3></cfoutput>	
		</cfif>
			
	

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">