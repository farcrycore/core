<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Output FarCry icon --->

<cfparam name="attributes.icon" default="" /><!--- The icon file you wish to render. --->
<cfparam name="attributes.size" default="48" /><!--- The size of the icon you wish to render (16, 32,48,64,128) --->
<cfparam name="attributes.default" default="farcrycore" /><!--- If the icon does not exist, the fallback icon --->

<cfparam name="attributes.id" default="" /><!--- id to add to the img tag --->
<cfparam name="attributes.class" default="" /><!--- class to add to the img tag --->
<cfparam name="attributes.style" default="" /><!--- style to add to the img tag --->
<cfparam name="attributes.alt" default="" /><!--- alt to add to the img tag --->
<cfparam name="attributes.title" default="#attributes.alt#" /><!--- title to add to the img tag --->


<cfif thistag.ExecutionMode eq "start">
	<cfset iconURL = application.fapi.getIconURL(icon=attributes.icon, size=attributes.size,default=attributes.default) />
	<cfoutput><img src="#iconURL#" <cfif len(attributes.id)> id="#attributes.id#"</cfif><cfif len(attributes.class)> class="#attributes.class#"</cfif><cfif len(attributes.style)> style="#attributes.style#"</cfif> alt="#attributes.alt#" title="#attributes.title#" /></cfoutput>
	
</cfif>

<cfsetting enablecfoutputonly="false" />