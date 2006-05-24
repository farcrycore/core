<cfcomponent name="library" displayname="library" hint="Used by the Library for the ajax callbacks" output="false" > 

<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >

<cffunction name="ajaxUpdateArray" access="remote" output="true" returntype="void">
 	<cfargument name="PrimaryObjectID" required="yes" type="UUID">
	<cfargument name="PrimaryTypename" required="yes" type="string">
 	<cfargument name="PrimaryFieldName" required="yes" type="string">
 	<cfargument name="PrimaryFormFieldName" required="yes" type="string">
	<cfargument name="DataObjectID" required="yes" type="UUID">
	<cfargument name="DataTypename" required="yes" type="string">
 	<cfargument name="WizzardID" required="no" type="string" default="">


	<cfargument name="ftLibrarySelectedMethod" type="string" default="selected"><!--- Webskin Display method to Display Selected Objects --->
	<cfargument name="ftLibrarySelectedMethodListClass" type="string" default="selected">
	<cfargument name="ftLibrarySelectedMethodListStyle" type="string" default="">
	
	<cfset oPrimary = createObject("component",application.types[arguments.PrimaryTypename].typepath)>
	<cfset stPrimary = oPrimary.getData(objectid=arguments.PrimaryObjectID)>
	
	<cfset oData = createObject("component",application.types[arguments.DataTypename].typepath)>
	
	<cfset o = createObject("component","farcry.fourq.gateway.dbGateway").init(dsn=application.dsn,dbowner="")>

	<cfif len(arguments.wizzardID)>
		<cfset oWizzard = createObject("component",application.types['dmWizzard'].typepath)>
		
		<cfset stWizzard = oWizzard.Read(wizzardID=arguments.WizzardID)>
		
		<cfset arrayAppend(stWizzard.Data[PrimaryObjectID][arguments.PrimaryFieldname],arguments.DataObjectID)>
		
		
	
		<cfset variables.tableMetadata = createobject('component','farcry.fourq.TableMetadata').init() />
		<cfset tableMetadata.parseMetadata(md=getMetadata(oPrimary)) />		
		<cfset stFields = variables.tableMetadata.getTableDefinition() />
		
		<cfset aProps = o.createArrayTableData(tableName=PrimaryTypename & "_" & PrimaryFieldName,objectid=arguments.PrimaryObjectID,tabledef=stFields[PrimaryFieldName].Fields,aprops=stWizzard.Data[PrimaryObjectID][arguments.PrimaryFieldname])>

		<cfset stWizzard.Data[PrimaryObjectID][arguments.PrimaryFieldname] = aProps>
		
		
		<cfset stWizzard = oWizzard.Write(ObjectID=arguments.wizzardID,Data=stWizzard.Data)>
		
		<cfset st = stWizzard.Data[PrimaryObjectID]>
	<cfelse>
	
		<cfset arrayAppend(stPrimary[arguments.PrimaryFieldname],arguments.DataObjectID)>
	
		<cfset oPrimary.setData(objectID=stPrimary.ObjectID,stProperties="#stPrimary#",user="#session.dmSec.authentication.userlogin#")>
		<cfset st = oPrimary.getData(objectid=stPrimary.ObjectID)>
	</cfif>
	
	
	
	<cfoutput>
		<ft:form>
			<ft:object objectID="#arguments.PrimaryObjectID#" WizzardID="#arguments.WizzardID#" lFields="#arguments.PrimaryFieldName#" inTable=0 IncludeLabel=0 />
		</ft:form>
	</cfoutput>

</cffunction>


</cfcomponent> 

