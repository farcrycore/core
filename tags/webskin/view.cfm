<cfsetting enablecfoutputonly="true">
<cfsilent>
<!--- @@displayname: Embedded View Tag --->
<!--- @@description: 
	This tag will run the view on an object with the same objectid until it is saved to the database.
 --->
<!--- @@author:  Mat Bryant (mat@daemon.com.au) --->
</cfsilent>
<cfif thistag.executionMode eq "Start">
	<cfsilent>
	<cfparam name="attributes.stObject" default="#structNew()#"><!--- use to get an existing object that has already been fetched by the calling page. --->
	<cfparam name="attributes.typename" default=""><!--- typename of the object. --->
	<cfparam name="attributes.objectid" default=""><!--- used to get an existing object --->
	<cfparam name="attributes.key" default=""><!--- use to generate a new object --->
	<cfparam name="attributes.template" default=""><!--- can be used as an alternative to webskin. Best practice is to use webskin. --->
	<cfparam name="attributes.webskin" default=""><!--- the webskin to be called with the object --->
	<cfparam name="attributes.stProps" default="#structNew()#">
	<cfparam name="attributes.stParam" default="#structNew()#">
	<cfparam name="attributes.r_html" default=""><!--- Empty will render the html inline --->

	<cfset lAttributes = "stobject,typename,objectid,key,template,webskin,stprops,stparam,r_html,r_objectid" />
	<cfset attrib = "" />
	
	<!--- Setup custom attributes passed into view in stParam structure --->
	<cfloop collection="#attributes#" item="attrib">
		<cfif not listFindNoCase(lAttributes, attrib)>
			<cfset attributes.stParam[attrib] = attributes[attrib] />
		</cfif>
	</cfloop>
	
	<cfparam name="session.tempObjectStore" default="#structNew()#">
	
	<cfif not len(attributes.typename)>
		<cfif structKeyExists(attributes.stObject, "typename")>
			<cfset attributes.typename = attributes.stobject.typename />
		<cfelseif len(attributes.objectid)>
			<cfset attributes.typename = application.coapi.coapiUtilities.findType(objectid=attributes.objectid) />
		</cfif>
	</cfif>
	
	<cfif not len(attributes.typename) or not structKeyExists(application.stCoapi, attributes.typename)>
		<cfabort showerror="invalid typename passed" />
	</cfif>	
	
	<!--- use template if its passed otherwise webskin. --->
	<cfif len(attributes.template)>
		<cfset attributes.webskin = attributes.template />
	</cfif>
	
	
	<!--- Initialise variables --->
	<cfset st = structNew() />
	<cfset o = createObject("component", application.stcoapi["#attributes.typename#"].packagePath) />

	<cfif structKeyExists(attributes.stObject, "objectid") and len(attributes.stObject.objectid)>
		<cfset st = attributes.stObject />	
	<cfelse>
			
		<cfif not len(attributes.objectID)>
			<cfparam name="session.stTempObjectStoreKeys" default="#structNew()#" />
			<cfparam name="session.stTempObjectStoreKeys[attributes.typename]" default="#structNew()#" />
			
			<cfif not len(attributes.key)>
				<cfset attributes.key = attributes.typename />
			</cfif>
			
			<cfif structKeyExists(session.stTempObjectStoreKeys[attributes.typename], attributes.key)>
				<cfif structKeyExists(Session.TempObjectStore, session.stTempObjectStoreKeys[attributes.typename][attributes.key])>
					<cfset attributes.objectid = session.stTempObjectStoreKeys[attributes.typename][attributes.key] />
				</cfif>
			</cfif>		
			<cfif not len(attributes.objectid)>
				<cfset attributes.objectid = createUUID() />
				<cfset session.stTempObjectStoreKeys[attributes.typename][attributes.key] = attributes.objectid>
				<cfset st = o.getData(objectID = attributes.objectid) />
				<cfset stResult = o.setData(stProperties=st, bSessionOnly="true") />
			</cfif>
		</cfif>
		
		<cfif structIsEmpty(st)>
			<!--- Go get a default object --->
			<cfset st = o.getData(objectID = attributes.objectid) />
		</cfif>	
	</cfif>
	
						
	
	<cfif not structIsEmpty(attributes.stProps)>
		
		<cfif structKeyExists(attributes.stProps, "objectid") or structKeyExists(attributes.stProps, "typename")>
			<cfthrow type="application" message="You can not override the objectid or typename with attributes.stProps" />
		</cfif>
		<!--- If attributes.stProps has been passed in, then append them to the struct --->
		<cfset StructAppend(attributes.stProps, st, false)>
		
		<cfset stResult = o.setData(stProperties=attributes.stProps, bSessionOnly=true) />
	</cfif>
	
	<!--- Developer can pass in alternate HTML to render if the webskin does not exist --->
	<cfif structKeyExists(attributes, "alternateHTML")>
		<cfset html = o.getView(objectid=st.objectid, template="#attributes.webskin#", alternateHTML="#attributes.alternateHTML#",stParam=attributes.stParam)>
	<cfelse>
		<cfset html = o.getView(objectid=st.objectid, template="#attributes.webskin#",stParam=attributes.stParam)>
	</cfif>		
	</cfsilent>
	
	<cfif len(attributes.r_html)>
		<cfset caller[attributes.r_html] = html />
	<cfelse>
		<cfoutput>#html#</cfoutput>	
	</cfif>
</cfif>

<cfif thistag.executionMode eq "End"><!--- DO NOTHING ---></cfif>

<cfsetting enablecfoutputonly="false">