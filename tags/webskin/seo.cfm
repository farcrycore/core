<cfsetting enablecfoutputonly="true">
<cfsilent>
<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
<!--- @@hint: Outputs open graph metadata tags for SEO fields --->
<!--- 
TODO
 - add og:image -- needs to accommodate CDN src path
 --->

<!--- import tag library --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- allow developers to close custom tag by exiting on end --->
<cfif thistag.ExecutionMode eq "end">
	<cfsetting enablecfoutputonly="false" />
	<cfexit method="exittag" />
</cfif>

<!--- 
 // tag attributes 
--------------------------------------------------------------------------------->
<cfparam name="attributes.stobject" type="struct"><!--- content object of page --->

<!--- property names for the stobject --->
<cfparam name="attributes.title" default=""><!--- og:title seo title for the page--->
<cfparam name="attributes.image" default=""><!--- og:image image thumb for content (optional) --->
<cfparam name="attributes.description" default=""><!--- description; google search prefers 170 chars but other services may be happy with more --->

<!--- these fields are not derived from stobject --->
<cfparam name="attributes.type" default="article"><!--- og:type defaults to article --->
<cfparam name="attributes.url" default=""><!--- og:url is the fully qualified URL to the content --->

<!--- 
 // derive values for og tags; first property that exists & is populated 
--------------------------------------------------------------------------------->
<cfset stSEO = structNew()>
<!--- title --->
<cfif len(attributes.title)>
	<cfset stSEO.title = application.fc.lib.seo.getTitle(stobject=attributes.stobject, lproperties=attributes.title)>
<cfelse>
	<cfset stSEO.title = application.fc.lib.seo.getTitle(stobject=attributes.stobject)>
</cfif>
<!--- description --->
<cfif len(attributes.description)>
	<cfset stSEO.description = application.fc.lib.seo.getDescription(stobject=attributes.stobject, lproperties=attributes.description)>
<cfelse>
	<cfset stSEO.description = application.fc.lib.seo.getDescription(stobject=attributes.stobject)>
</cfif>
<!--- url --->
<cfif len(attributes.url)>
	<cfset stSEO.url = attributes.url>
<cfelse>
	<cfset stSEO.url = application.fc.lib.seo.getCanonicalFU(stObject=attributes.stObject)>
</cfif>

<!--- 
 // output meta tags 
--------------------------------------------------------------------------------->
<skin:htmlHead id="opengraph-seo">
<cfoutput>
<meta property="og:title" content="#stSEO.title#">
<meta property="og:type" content="#attributes.type#">
<meta property="og:url" content="#stSEO.url#">
<!--- <meta property="og:image" content=""> --->
<meta property="og:description" content="#stSEO.description#">
</cfoutput>
</skin:htmlHead>

</cfsilent>
<cfsetting enablecfoutputonly="false">