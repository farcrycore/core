<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Log event --->
<!--- @@description: This tag provides an interface for logging events (errors, deprecated code, security, coapi add/edit/delete) to farLog --->

<cfif not thistag.HasEndTag>
	<cfthrow message="Closing tag missing" />
</cfif>

<cfif thistag.HasEndTag>
	<cfparam name="attributes.object" type="string" default="" /><!--- The uuid of the associated object --->
	<cfparam name="attributes.type" type="string" default="" /><!--- The type of the associated object (can be non-coapi, e.g. security) --->
	<cfparam name="attributes.event" type="string" /><!--- The event that is being logged --->
	<cfparam name="attributes.location" type="string" default="#getCurrentTemplatePath()#" /><!--- The location of the event --->
	<cfparam name="attributes.userid" type="string" default="#application.security.getCurrentUserID()#" /><!--- The user associated with the event --->
	<cfparam name="attributes.ipaddress" type="string" default="#cgi.REMOTE_HOST#" /><!--- The ip of user --->
	<cfparam name="attributes.notes" type="string" default="" /><!--- Free text :D --->
	<cfparam name="attributes.note" type="string" default="" /><!--- I wrote the damn thing and I can never remember if was notes or note => so both --->
	
	<cfset stObj = structnew() />
	
	<cfset stObj.objectid = createuuid() />
	<cfset stObj.object = attributes.object />
	<cfset stObj.type = attributes.type />
	<cfset stObj.event = attributes.event />
	<cfset stObj.location = attributes.location />
	<cfset stObj.userid = attributes.userid />
	<cfset stObj.notes = attributes.note & attributes.notes />
	
	<cfset createObject("component", application.stcoapi["farLog"].packagePath).createData(stProperties=stObj) />
</cfif>

<cfsetting enablecfoutputonly="false" />