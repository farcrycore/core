

<cfsetting enablecfoutputonly="true">

<!--- @@displayname: Embedded View Tag --->
<!--- @@description: 
	This tag will run the view on an object with the same objectid until it is saved to the database.
 --->
<!--- @@author:  Mat Bryant (mat@daemon.com.au) --->



<cfif thistag.executionMode eq "Start">
	<cfif not structKeyExists(attributes, "typename") or not structKeyExists(application.stCoapi, attributes.typename)>
		<cfabort showerror="invalid typename passed" />
	</cfif>	
	<cfparam name="attributes.stObject" default="#structNew()#">
	<cfparam name="attributes.objectid" default="">
	<cfparam name="attributes.key" default="">
	<cfparam name="attributes.template" default=""><!--- can be used as an alternative to webskin. Best practice is to use webskin. --->
	<cfparam name="attributes.webskin" default=""><!--- the webskin to be called with the object --->
	<cfparam name="attributes.r_stProperties" default="stproperties">

	<cfif not len(attributes.objectid) and not len(attributes.key) and structIsEmpty(attributes.stObject)>
		<cfabort showerror="Requires an objectid, key or stobject" />
	</cfif>

	<!--- use template if its passed otherwise webskin. --->
	<cfif len(attributes.template)>
		<cfset attributes.webskin = attributes.template />
	</cfif>
	
	
	<cfset o = createObject("component", application.stcoapi["#attributes.typename#"].packagePath) />


	<cfif structKeyExists(attributes.stObject, objectid) and len(attributes.stObject.objectid)>
		<cfset st = attributes.stObject />	
	<cfelse>
			
		<cfparam name="session.stTempObjectStoreKeys" default="#structNew()#" />
		<cfparam name="session.stTempObjectStoreKeys[attributes.typename]" default="#structNew()#" />
		
		<cfif len(attributes.key)>
			<cfif structKeyExists(session.stTempObjectStoreKeys[attributes.typename], attributes.key)>
				<cfif structKeyExists(Session.TempObjectStore, session.stTempObjectStoreKeys[attributes.typename][attributes.key])>
					<cfset attributes.objectid = session.stTempObjectStoreKeys[attributes.typename][attributes.key] />
				</cfif>
			</cfif>		
			<cfif not len(attributes.objectid)>
				<cfset attributes.objectid = createUUID() />
				<cfset session.stTempObjectStoreKeys[attributes.typename][attributes.key] = attributes.objectid>
			</cfif>
		<cfelse>			
			<cfif not len(attributes.objectid)>
				<cfset attributes.objectid = createUUID() />
			</cfif>
		</cfif>
		
		<!--- Go get a default object --->
		<cfset st = o.getData(objectID = attributes.objectid) />	
	</cfif>
	
					
	
	<cfset caller[attributes.r_stProperties] = st />
	

</cfif>

<cfif thistag.executionMode eq "End">

	<cfset stResult = o.setData(stProperties=caller[attributes.r_stProperties], bSessionOnly=true) />
	
	<cfset html = o.getView(objectid=caller[attributes.r_stProperties].objectid, template="#attributes.webskin#")>	
	
	<cfoutput>#html#</cfoutput>	
</cfif>



<cfsetting enablecfoutputonly="false">