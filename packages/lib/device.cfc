<cfcomponent output="false">
	
	<!--- DEVICE TYPE DETECTION ///////////////////////////////////////////// --->

	<!--- @@examples:
		<p>Check if device detection is enabled:</p>
		<code>
			<cfoutput>#application.fapi.isDeviceDetectionEnabled()#</cfoutput>
		</code>
	 --->
	<cffunction name="isDeviceDetectionEnabled" access="public" output="false" returntype="boolean" hint="Returns true if device detection is enabled" bDocument="true">

		<cfparam name="application.bUseDeviceDetection" default="false">

		<cfreturn application.bUseDeviceDetection>
	</cffunction>

	<!--- @@examples:
		<p>Check if mobile webskins are enabled:</p>
		<code>
			<cfoutput>#application.fapi.isMobileWebskinsEnabled()#</cfoutput>
		</code>
	 --->
	<cffunction name="isMobileWebskinsEnabled" access="public" output="false" returntype="boolean" hint="Returns true if mobile webskins are enabled" bDocument="true">

		<cfparam name="application.bUseMobileWebskins" default="false">

		<cfreturn application.bUseMobileWebskins>
	</cffunction>

	<!--- @@examples:
		<p>Check if tablet webskins are enabled:</p>
		<code>
			<cfoutput>#application.fapi.isTabletWebskinsEnabled()#</cfoutput>
		</code>
	 --->
	<cffunction name="isTabletWebskinsEnabled" access="public" output="false" returntype="boolean" hint="Returns true if tablet webskins are enabled" bDocument="true">

		<cfparam name="application.bUseTabletWebskins" default="false">

		<cfreturn application.bUseTabletWebskins>
	</cffunction>

	<!--- @@examples:
		<p>Check if the given device types webskins are enabled:</p>
		<code>
			<cfoutput>#application.fapi.isDeviceWebskinsEnabled("tablet")#</cfoutput>
		</code>
	 --->
	<cffunction name="isDeviceWebskinsEnabled" access="public" output="false" returntype="boolean" hint="Returns true if the given device types webskins are enabled" bDocument="true">
		<cfargument name="deviceType" required="true">

		<cfif arguments.devicetype eq "desktop">
			<cfreturn true>
		<cfelseif arguments.devicetype eq "mobile">
			<cfreturn isMobileWebskinsEnabled()>
		<cfelseif arguments.devicetype eq "tablet">
			<cfreturn isTabletWebskinsEnabled()>
		</cfif>

		<cfreturn false>
	</cffunction>

	<!--- @@examples:
		<p>Get the device type string from the user agent:</p>
		<code>
			<cfoutput>#application.fapi.getUserAgentDeviceType()#</cfoutput>
		</code>
	 --->
	<cffunction name="getUserAgentDeviceType" access="public" output="false" returntype="string" hint="Returns the device type string based on the user agent" bDocument="true">
		<cfargument name="userAgent" type="string" required="false" default="#cgi.user_agent#">

		<cfset var deviceType = "desktop">

		<!--- iOS Devices --->
		<cfif reFindNoCase("(iPod|iPhone)", arguments.userAgent)>
			<cfset deviceType = "mobile">
		<cfelseif reFindNoCase("iPad", arguments.userAgent)>
			<cfset deviceType = "tablet">

		<!--- Android Devices --->
		<cfelseif reFindNoCase("(Android).*(?=Mobile)", arguments.userAgent)>
			<cfset deviceType = "mobile">
		<cfelseif reFindNoCase("Android", arguments.userAgent)>
			<cfset deviceType = "tablet">

		<!--- Windows Phone --->
		<cfelseif reFindNoCase("(Windows Phone).*(?=IEMobile)", arguments.userAgent)>
			<cfset deviceType = "mobile">

		<!--- Other Mobile Devices --->
		<cfelseif reFindNoCase("(Blackberry|webOS|Opera Mini|Opera Mobi)", arguments.userAgent)>
			<cfset deviceType = "mobile">

		</cfif>
		
		<cfreturn deviceType>
	</cffunction>

	<!--- @@examples:
		<p>Get the device type string:</p>
		<code>
			<cfoutput>#application.fapi.getDeviceType()#</cfoutput>
		</code>
	 --->
	<cffunction name="getDeviceType" access="public" output="false" returntype="string" hint="Returns the device type string" bDocument="true">

		<cfparam name="cookie.farcrydevicetype" default="#getUserAgentDeviceType()#">

		<cfreturn cookie.farcrydevicetype>
	</cffunction>

	<!--- @@examples:
		<p>Check for a mobile device:</p>
		<code>
			<cfoutput>#application.fapi.isMobileDevice()#</cfoutput>
		</code>
	 --->
	<cffunction name="isMobileDevice" access="public" output="false" returntype="boolean" hint="Returns true if the device type is mobile" bDocument="true">
		<cfargument name="deviceType" type="string" required="false" default="#getDeviceType()#">

		<cfreturn arguments.deviceType eq "mobile">
	</cffunction>

	<!--- @@examples:
		<p>Check for a tablet device:</p>
		<code>
			<cfoutput>#application.fapi.isTabletDevice()#</cfoutput>
		</code>
	 --->
	<cffunction name="isTabletDevice" access="public" output="false" returntype="boolean" hint="Returns true if the device type is tablet" bDocument="true">
		<cfargument name="deviceType" type="string" required="false" default="#getDeviceType()#">

		<cfreturn arguments.deviceType eq "tablet">
	</cffunction>

	<!--- @@examples:
		<p>Check for a desktop device:</p>
		<code>
			<cfoutput>#application.fapi.isDesktopDevice()#</cfoutput>
		</code>
	 --->
	<cffunction name="isDesktopDevice" access="public" output="false" returntype="boolean" hint="Returns true if the device type is desktop" bDocument="true">
		<cfargument name="deviceType" type="string" required="false" default="#getDeviceType()#">

		<cfreturn arguments.deviceType eq "desktop">
	</cffunction>

	<!--- @@examples:
		<p>Set the device type string:</p>
		<code>
			<cfoutput>#application.fapi.setDeviceType("mobile")#</cfoutput>
		</code>
	 --->
	<cffunction name="setDeviceType" access="public" output="false" hint="Sets the device type string" bDocument="true">
		<cfargument name="deviceType" type="string" required="true">

		<cfset cookie.farcrydevicetype = arguments.deviceType>

	</cffunction>

	<!--- @@examples:
		<p>Check if device redirection to a particular domain is enabled:</p>
		<code>
			<cfoutput>#application.fapi.isDeviceRedirectionEnabled()#</cfoutput>
		</code>
	 --->
	<cffunction name="isDeviceRedirectionEnabled" access="public" output="false" returntype="boolean" hint="Returns true if device redirection between device specific domains is enabled" bDocument="true">

		<!--- TODO: implement domain config to allow for redirection of devices to specific domains --->
		<cfreturn false>

	</cffunction>

	<!--- @@examples:
		<p>Get the device type for the current domain:</p>
		<code>
			<cfoutput>#application.fapi.getDomainDeviceType()#</cfoutput>
		</code>
	 --->
	<cffunction name="getDomainDeviceType" access="public" output="false" returntype="string" hint="Returns the device type for the current domain" bDocument="true">
		<cfargument name="domain" type="string" required="false" default="">

		<!--- TODO: implement domain config to allow for redirection of devices to specific domains --->
		<cfreturn "desktop">

	</cffunction>

	<!--- @@examples:
		<p>Get the device specific webskin for the given typename and display method webskin:</p>
		<code>
			<cfoutput>#application.fapi.getDeviceWebskin("dmHTML", "displayPageHome")#</cfoutput>
		</code>
	 --->
	<cffunction name="getDeviceWebskin" access="public" output="false" returntype="string" hint="Returns the device specific webskin for the given typename and display method and optionally allows the device type to be specified instead of being automatically detected" bDocument="true">
		<cfargument name="typename" type="string" required="true">
		<cfargument name="webskin" type="string" required="true">
		<cfargument name="deviceType" type="string" required="false" default="#getDeviceType()#">
		<cfargument name="bIgnoreDeviceDetection" type="string" required="false" default="false">

		<cfset var result = arguments.webskin>
		<cfset var deviceDisplayMethod = "">

		<!--- if device detection is enabled (or ignored), check for a device specific version of the display method webskin --->
		<cfif (isDeviceDetectionEnabled() OR arguments.bIgnoreDeviceDetection) AND isDeviceWebskinsEnabled(arguments.deviceType) AND arguments.deviceType neq "desktop">
			<cfset deviceDisplayMethod = reReplaceNoCase(arguments.webskin, "^display", arguments.deviceType)>
			<cfif application.fapi.hasWebskin(typename=arguments.typename, webskin=deviceDisplayMethod)>
				<cfset result = deviceDisplayMethod>
			</cfif>
		</cfif>

		<cfreturn result>
	</cffunction>

	<!--- @@examples:
		<p>Get the standard webskin names used by a certain device type:</p>
		<code>
			<cfoutput>#application.fapi.getDeviceWebskinNames("mobile")#</cfoutput>
		</code>
	 --->
	<cffunction name="getDeviceWebskinNames" access="public" output="false" returntype="struct" hint="Returns a struct of the standard webskin names to be used for the given device type" bDocument="true">
		<cfargument name="deviceType" type="string" required="false" default="#getDeviceType()#">
		<cfargument name="bIgnoreDeviceDetection" type="string" required="false" default="false">

		<cfset var stResult = structNew()>

		<!--- standard webskins --->
		<cfset stResult.body = "displayBody">
		<cfset stResult.page = "displayPageStandard">
		<cfset stResult.typeBody = "displayTypeBody">

		<!--- device detection --->
		<cfif isDeviceDetectionEnabled() OR arguments.bIgnoreDeviceDetection>
			<cfif isMobileDevice(arguments.deviceType) AND isMobileWebskinsEnabled()>
				<!--- mobile webskins --->
				<cfset stResult.body = "mobileBody">
				<cfset stResult.page = "mobilePageStandard">
				<cfset stResult.typeBody = "mobileTypeBody">
			<cfelseif isTabletDevice(arguments.deviceType) AND isTabletWebskinsEnabled()>
				<!--- tablet webskins --->
				<cfset stResult.body = "tabletBody">
				<cfset stResult.page = "tabletPageStandard">
				<cfset stResult.typeBody = "tabletTypeBody">
			</cfif>
		</cfif>

		<cfreturn stResult>
	</cffunction>

	<!--- @@examples:
		<p>Redirect to the appropriate domain for the current device type:</p>
		<code>
			<cfset application.fapi.redirectDevice()>
		</code>
	 --->
	<cffunction name="redirectDevice" access="public" output="false" hint="Redirects to the appropriate domain for the current device type" bDocument="true">

		<cfif isDeviceRedirectionEnabled()>
		<!--- TODO: implement domain config to allow for redirection of devices to specific domains --->
			<!--- get domain for the current device type --->
			<!--- redirect --->
		</cfif>

	</cffunction>

	
</cfcomponent>