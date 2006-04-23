<!--- 

 FriendlyURL Management Component

 Created: Thu May 1  14:19:20 2003
 $Revision 0.2$
 Modified: $Date: 2003/07/21 09:32:23 $

 Author: Spike
 E-mail: spike@spike@spike.org.uk

 Description: The purpose of this component is to allow for simple management
 							of urls provided by the FriendlyURL servlet. This functionality 
							has been put into a component rather than the servlet itself so
							as to simplify integration into existing ColdFusion applications,
							to limit the security implications of having the management
							functionality in the servlet itself, and to help keep the servlet
							as lightweight as possible.
							
							Use the ColdFusion Component browser to view the methods provided
							by the component.
							
							It is not necessary to restart any part of ColdFusion after making
							changes to the mappings.
--->

<cfcomponent displayname="FriendlyURL" hint="FriendlyURLs manager">
	
	<cfset init()>
	
	<cffunction name="init" hint="Initializes the component.">
		<cfset instance = structNew()>	
		<cfset dataClass = createObject("java", "FriendlyURLData")>
      	<cfset dataObject = dataClass.getInstance()>
	</cffunction>
	   
	<cffunction name="getErrorTemplate" access="public" returntype="string" hint="Returns the value currently used for the error template." output="No">
		<cfreturn dataObject.getErrorURL()>
	</cffunction>

	<cffunction name="setErrorTemplate" access="public" returntype="boolean" hint="Sets the value for the error template and writes the map file to disk." output="No">
		<cfargument name="errorTemplate" type="string" required="Yes">
		<cfset dataObject.setErrorURL(arguments.errorTemplate)>
		<cfreturn true>
	</cffunction>		
	
	<cffunction name="getURLVar" access="public" returntype="string" hint="Retrieves the name of the url variable that contains the friendly url." output="No">
		<cfreturn dataObject.getURLVar()>
	</cffunction>

	<cffunction name="setURLVar" access="public" returntype="boolean" hint="Sets the name for the url variable and writes the map file to disk" output="No">
		<cfargument name="URLVar" type="string" required="Yes">
		<cfset dataObject.setURLVar(arguments.URLVar)>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="setMapping" access="public" returntype="boolean" hint="Sets the value for a mapping and writes the mapfile to disk. This can be a new or existing mapping." output="No">
		<cfargument name="alias" required="yes" type="string">
		<cfargument name="mapping" required="yes" type="string">
		
		<cfset dataObject.setMapping(javaCast("string", arguments.alias), javaCast("string", arguments.mapping))>
		<cfreturn true>
	</cffunction>		
	
	<cffunction name="deleteMapping" access="public" returntype="boolean" hint="Deletes a mapping and writes the map file to disk" output="No">
		<cfargument name="alias" required="yes" type="string">
		<cfset dataObject.removeMapping(arguments.alias)>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="getMappings" access="public" returntype="struct" hint="Retrieves all current mappings" output="No">
		<cfreturn dataObject.getMappings()>
	</cffunction>
	
	
	<!--- FarCry Specific Functions --->
	<cffunction name="deleteAll" access="public" returntype="boolean" hint="Deletes all mappings and writes the map file to disk" output="No">
		<cfset mappings= getMappings()>
		<!--- loop over all entries and delete those that match domain --->
		<cfloop collection="#mappings#" item="i">
			<cfif reFind('^#application.config.fusettings.domains##application.config.fusettings.urlpattern#',i)>
				<cfset deleteMapping(i)>
			</cfif>
		</cfloop>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="deleteFU" access="public" returntype="boolean" hint="Deletes a mappings and writes the map file to disk" output="No">
		<cfargument name="alias" required="yes" type="string" hint="old alias of object to delete">
		
		<cfset mappings= getMappings()>
		<!--- loop over all domains --->
		<cfloop list="#application.config.fusettings.domains#" index="dom">
			<!--- loop over all entries and delete those that match domain and old alias --->
			<cfloop collection="#mappings#" item="i">
				<cfif i eq "#dom##arguments.alias#">
					<cfset deleteMapping(i)>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn true>
	</cffunction>
	
	<cffunction name="createAll" access="public" returntype="boolean" hint="Deletes old mappings and creates new entries for entire tree, and writes the map file to disk" output="No">
				
		<!--- remove existing fu's --->
		<cfset deleteALL()>
		<!--- set error template --->		
		<cfset setErrorTemplate("#application.url.webroot#")>
		<!--- set nav variable --->
		<cfset setURLVar("nav")>
		<!--- get nav tree --->
		<cfobject component="#application.packagepath#.farcry.tree" name="o">
		<cfset qNav = o.getDescendants(objectid=application.navid.home, depth=50)>
		<!--- loop over nav tree and create friendly urls --->
		<cfloop query="qNav">
			<!--- get ancestors of object --->
			<cfset qAncestors = o.getAncestors(objectid=objectid,bIncludeSelf=true)>
			<!--- remove root & home --->
			<cfquery dbtype="query" name="qCrumb">
				SELECT objectName FROM qAncestors
				WHERE nLevel >= 2
				ORDER BY nLevel
			</cfquery>
			<!--- join titles together --->
			<cfset breadCrumb = lcase(valueList(qCrumb.objectname))>
			<!--- change delimiter --->
			<cfset breadCrumb = listChangeDelims(breadCrumb,"/",",")>
			<!--- remove spaces --->
			<cfset breadCrumb = replace(breadCrumb,' ','-',"all")>
			
			<!--- create fu --->
			<cfset setFU(objectid=objectid,alias=application.config.fusettings.urlpattern&breadcrumb)>
		</cfloop>
		<!--- create fu for home--->
		<cfset setFU(objectid=application.navid.home,alias=application.config.fusettings.urlpattern)>
		
		<cfreturn true>
	</cffunction>
	
	<cffunction name="setFU" access="public" returntype="string" hint="Sets an fu" output="No">
		<cfargument name="objectid" required="yes" type="UUID" hint="objectid of object to link to">
		<cfargument name="alias" required="yes" type="string" hint="alias of object to link to">
				
		<!--- replace spaces in title --->
		<cfset newAlias = replace(arguments.alias,' ','-',"all")>
		<!--- remove illegal characters in titles --->
		<cfset newAlias = reReplaceNoCase(newAlias,'[:\?]','',"all")>
		<!--- change & to "and" in title --->
		<cfset newAlias = reReplaceNoCase(newAlias,'[&]','and',"all")>
				
		<!--- loop over domains and set fu ---> 
		<cfloop list="#application.config.fusettings.domains#" index="dom">
			<cfset setMapping(alias=dom&newAlias,mapping="#application.url.conjurer#?objectid=#arguments.objectid#")>
		</cfloop>
	</cffunction>
	
	<cffunction name="getFU" access="public" returntype="string" hint="Retrieves fu for a real url, returns original ufu if non existent." output="No">
		<cfargument name="objectid" required="yes" type="UUID" hint="objectid of object to link to">
		<cfargument name="dom" required="yes" type="string" default="#cgi.server_name#">
		<cfset fullUFU = application.url.conjurer & "?objectid=" & arguments.objectid>
		<cfset mappings = getMappings()>
		<cfset fuURL = "">
		<cfloop collection="#mappings#" item="i">
			<cfif listFirst(i,'/') eq arguments.dom and mappings[i] eq fullUFU>
				<cfset fuURL = "/" & listRest(i,'/')>
			</cfif>	
		</cfloop>
		
		<cfif not len(fuURL)>
			<cfset fuURL = application.url.conjurer & "?objectid=" & arguments.objectid>
		</cfif>
		
		<cfreturn fuURL>
	</cffunction>

</cfcomponent>