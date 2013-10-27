<cfsetting enablecfoutputonly="true">

<cfset bUseDeviceDetection = false>
<cfset bUseMobileWebskins = false>
<cfset bUseTabletWebskins = false>

<cfif isDefined("application.bUseDeviceDetection")>
	<cfset bUseDeviceDetection = application.bUseDeviceDetection>
</cfif>
<cfif isDefined("application.bUseMobileWebskins")>
	<cfset bUseMobileWebskins = application.bUseMobileWebskins>
</cfif>
<cfif isDefined("application.bUseTabletWebskins")>
	<cfset bUseTabletWebskins = application.bUseTabletWebskins>
</cfif>

<cfoutput>
	<fieldset class="fieldset" style="">
		<legend>Device Webskins</legend>
		<p>
			Device specific webskins are enabled by configuring the appropriate setting 
			in your  <code>farcryContructor.cfm</code>.
		</p>
		<p>The current device webskin settings for this application are:</p>
<pre>
	this.bUseDeviceDetection = #bUseDeviceDetection#;
	this.bUseMobileWebskins = #bUseMobileWebskins#;
	this.bUseTabletWebskins = #bUseTabletWebskins#;
</pre>
	</fieldset>
</cfoutput>

<cfsetting enablecfoutputonly="false">