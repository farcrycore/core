<!--- 
listTemplates
 - list templates from webskin

attributes
-> typename
-> prefix
-> path
 --->
<!--- 
TODO
Need to work out a way of generating a suitable displayname.  Perhaps 
this could be a special comment in the template itself picked up
by a regular expression match here???
 --->

<cfprocessingDirective pageencoding="utf-8">

<cfparam name="attributes.typename">
<cfparam name="attributes.prefix" default="display">
<cfparam name="attributes.path" default="">
<cfparam name="attributes.r_qMethods" default="r_qMethods">

<cfset qTemplates = queryNew("blah") />


<!--- if we send in a path then only get templates from that path --->
<cfif len(attributes.path)>

	<cfdirectory action="LIST" filter="*.cfm" name="qTemplates" directory="#attributes.path#">

<!---
OTHERWISE WE NEED TO LOOP THROUGH ALL THE LIBRARIES AND GET ALL RELEVENT TEMPLATES
 --->
<cfelse>
	
		
	<cfif structKeyExists(application.stcoapi, attributes.typename)>		
			
		<cfset qTemplates = createObject("component", application.stcoapi[attributes.typename].packagepath).getWebskins(typename="#attributes.typename#", prefix="#attributes.prefix#") />
		<cfset caller[attributes.r_qMethods] = qTemplates>
	<cfelse>
		<cfset caller[attributes.r_qMethods] = queryNew("name,directory,size,type,datelastmodified,attributes,mode,displayname,methodname") />
			
	</cfif>

<!--- 	<cfdirectory action="LIST" filter="*.cfm" name="qTemplates" directory="#application.path.webskin#/#attributes.typename#">
	
	<cfset stLibraryTemplates = structNew() />
	
	<cfif structKeyExists(application, "plugins") and listLen(application.plugins)>
	
		<cfloop list="#application.plugins#" index="library">
			
			<cfif directoryExists("#application.path.library#/#library#/webskin/#attributes.typename#")>
				<cfdirectory directory="#application.path.library#/#library#/webskin/#attributes.typename#" name="stLibraryTemplates.#library#.qTemplates" filter="*.cfm" sort="name">
			
			</cfif>
		</cfloop>
	</cfif> --->
	
	
</cfif>


