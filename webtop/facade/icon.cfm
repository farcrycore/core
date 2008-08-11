<cfparam name="url.type" default="" />
<cfparam name="url.icon" default="" />
<cfparam name="url.usecustom" default="true" />
<cfparam name="url.size" default="48" />

<cfif not len(url.type) and not len(url.icon)>
	<cfthrow message="The icon facade requires either type or icon to be passed in">
</cfif>

<cfif not len(url.icon)>
	<cfset url.icon = url.type />
</cfif>

<cfif url.usecustom>
	<cfset defaulticon = "farcrycore.png" />
<cfelse>
	<cfset defaulticon = "blank.png" />
</cfif>

<cfcontent file="#expandpath(application.factory.oAlterType.getIconPath(iconname=url.icon,size=url.size,default=defaulticon))#" />