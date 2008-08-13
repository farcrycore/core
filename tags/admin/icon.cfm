<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Output FarCry icon --->

<cfparam name="attributes.icon" />
<cfparam name="attributes.size" default="48" />
<cfparam name="attributes.usecustom" default="false" />

<cfparam name="attributes.id" default="" />
<cfparam name="attributes.class" default="" />
<cfparam name="attributes.style" default="" />

<cfif thistag.ExecutionMode eq "start">
	<cfoutput><img src="#application.url.webtop#/facade/icon.cfm?icon=#attributes.icon#&size=#attributes.size#&usecustom=#attributes.usecustom#"<cfif len(attributes.id)> id="#attributes.id#"</cfif><cfif len(attributes.class)> id="#attributes.class#"</cfif><cfif len(attributes.style)> id="#attributes.style#"</cfif> alt="" /></cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false" />