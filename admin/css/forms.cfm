<!--- allow output only from cfoutput tags --->
<cfsetting enablecfoutputonly="yes" />

	<!--- set content type of cfm to css to enable output to be parsed as css by all browsers --->
	<cfcontent type="text/css; charset=UTF-8">

	<!--- include layout css --->
	<cfinclude template="forms/layout.cfm"/>

	<!--- include webskin css --->
	<cfinclude template="forms/webskin.cfm"/>

	<!--- include formatting css --->
	<cfinclude template="forms/formatting.cfm"/>
	
	<!--- include farcryButton css --->
	<cfinclude template="forms/farcryButton.cfm"/>

<!--- end allow output only from cfoutput tags --->
<cfsetting enablecfoutputonly="no" />
