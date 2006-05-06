<cfcomponent name="library" displayname="library" hint="Used by the Library for the ajax callbacks" output="false" > 

<cffunction name="ajaxUpdateArray" access="remote" output="true" returntype="void">
 	<cfargument name="PrimaryObjectID" required="yes" type="UUID">
	<cfargument name="PrimaryTypename" required="yes" type="string">
 	<cfargument name="PrimaryFieldName" required="yes" type="string">
	<cfargument name="DataObjectID" required="yes" type="UUID">
	<cfargument name="DataTypename" required="yes" type="string">
	
	<cfset tPrimary = createObject("component",application.types[arguments.PrimaryTypename].typepath)>
	<cfset stobj = tPrimary.getData(objectid=arguments.PrimaryObjectID)>
	
	
	<cfset tData = createObject("component",application.types[arguments.DataTypename].typepath)>
	<cfset stdata = tData.getData(objectid=arguments.DataObjectID)>
	
	
	<cfset arrayAppend(stobj[arguments.PrimaryFieldname],arguments.DataObjectID)>
	
	<cfif isdefined("session.dmSec.authentication.userlogin")>
		<cfset userlogin = session.dmSec.authentication.userlogin>
	<cfelse>
		<cfset userlogin = "annonymous">
	</cfif>
	
	<cfset tPrimary.setData(objectID=stobj.ObjectID,stProperties="#stObj#",user=userlogin)>
	
	<cfset st = tPrimary.getData(objectid=stObj.ObjectID)>
	
	<cfoutput>
	<ul style="margin: 1em 0;_margin-top:0;_height:1%;overflow:auto;_overflow:visible;">
		<cfloop list="#arrayToList(st[arguments.PrimaryFieldname])#" index="i">
			<li style="float:left;background:transparent;">#tData.ftBasket(objectID=i)#</li>
		</cfloop>
	</ul>
	</cfoutput>
	

	
		<!--- <cfdump var="#arguments#"> --->
	<!--- 	<cfoutput>
			<p>arguments: #structKeyList(arguments)#</p>
			<p>form: #structKeyList(form)#</p>
			<p>url: #structKeyList(url)#</p>
		</cfoutput>
 --->
</cffunction>


</cfcomponent> 