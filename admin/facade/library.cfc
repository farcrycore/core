<cfcomponent name="library" displayname="library" hint="Used by the Library for the ajax callbacks" output="false" > 

<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >

<cffunction name="ajaxUpdateArray" access="remote" output="true" returntype="void">
 	<cfargument name="LibraryType" required="yes" type="string" hint="Can be Array or UUID. If UUID, only 1 value can be stored.">
 	<cfargument name="PrimaryObjectID" required="yes" type="UUID">
	<cfargument name="PrimaryTypename" required="yes" type="string">
 	<cfargument name="PrimaryFieldName" required="yes" type="string">
 	<cfargument name="PrimaryFormFieldName" required="yes" type="string">
	<cfargument name="DataObjectID" required="yes" type="string" hint="this could be a UUID to be added or a list of UUID's if we are re-sorting">
	<cfargument name="DataTypename" required="yes" type="string">
 	<cfargument name="WizzardID" required="no" type="string" default="">
 	<cfargument name="Action" required="no" type="string" default="Add" hint="Value can be [Add] or [Remove] or [Sort]">


	<cfargument name="ftLibrarySelectedWebskin" type="string" default="selected"><!--- Webskin Display method to Display Selected Objects --->
	<cfargument name="ftLibrarySelectedWebskinListClass" type="string" default="selected">
	<cfargument name="ftLibrarySelectedWebskinListStyle" type="string" default="">

	<cfset oPrimary = createObject("component",application.types[arguments.PrimaryTypename].typepath)>
	<cfset stPrimary = oPrimary.getData(objectid=arguments.PrimaryObjectID)>
	
	<cfset oData = createObject("component",application.types[arguments.DataTypename].typepath)>
	
	

	<cfif arguments.Action NEQ "Refresh">
	
		<cfif len(arguments.wizzardID)>
			
			
			<cfset oWizzard = createObject("component",application.types['dmWizzard'].typepath)>
			
			<cfset stWizzard = oWizzard.Read(wizzardID=arguments.WizzardID)>
			
			<cfif arguments.LibraryType EQ "UUID">
				<cfif arguments.Action EQ "Add">
					<cfset stWizzard.Data[PrimaryObjectID][arguments.PrimaryFieldname] = arguments.DataObjectID>
				<cfelse>
					<cfset stWizzard.Data[PrimaryObjectID][arguments.PrimaryFieldname] = "">
				</cfif>			
			<cfelse><!--- Array --->
				<cfif arguments.Action EQ "Add">
					<cfset arrayAppend(stWizzard.Data[PrimaryObjectID][arguments.PrimaryFieldname],arguments.DataObjectID)>
				<cfelseif arguments.Action EQ "Sort">
					<cfset stWizzard.Data[PrimaryObjectID][arguments.PrimaryFieldname] = ArrayNew(1)>
					<cfloop list="#arguments.DataObjectID#" index="i">
						<cfset arrayAppend(stWizzard.Data[PrimaryObjectID][arguments.PrimaryFieldname],i)>
					</cfloop>
				<cfelse>
					<cfset pos = ListFindNoCase(ArrayToList(stWizzard.Data[PrimaryObjectID][arguments.PrimaryFieldname]), arguments.DataObjectID)>
					<cfif pos GT 0>
						<cfset ArrayDeleteAt(stWizzard.Data[PrimaryObjectID][arguments.PrimaryFieldname],pos)>
					</cfif>
				</cfif>			
				<cfset variables.tableMetadata = createobject('component','farcry.fourq.TableMetadata').init() />
				<cfset tableMetadata.parseMetadata(md=getMetadata(oPrimary)) />		
				<cfset stFields = variables.tableMetadata.getTableDefinition() />
				
				<cfset o = createObject("component","farcry.fourq.gateway.dbGateway").init(dsn=application.dsn,dbowner="")>
				<cfset aProps = o.createArrayTableData(tableName=PrimaryTypename & "_" & PrimaryFieldName,objectid=arguments.PrimaryObjectID,tabledef=stFields[PrimaryFieldName].Fields,aprops=stWizzard.Data[PrimaryObjectID][arguments.PrimaryFieldname])>
		
				<cfset stWizzard.Data[PrimaryObjectID][arguments.PrimaryFieldname] = aProps>
			</cfif>
			
			<cfset stWizzard = oWizzard.Write(ObjectID=arguments.wizzardID,Data=stWizzard.Data)>
			
			<cfset st = stWizzard.Data[PrimaryObjectID]>
		<cfelse>
		
			
			<cfif arguments.LibraryType EQ "UUID">
				<cfif arguments.Action EQ "Add">
					<cfset stPrimary[arguments.PrimaryFieldname] = arguments.DataObjectID>
				<cfelse>
					<cfset stPrimary[arguments.PrimaryFieldname] = "">
				</cfif>			
			<cfelse><!--- Array --->
				<cfif arguments.Action EQ "Add">
					<cfset arrayAppend(stPrimary[arguments.PrimaryFieldname],arguments.DataObjectID)>
				<cfelseif arguments.Action EQ "Sort">
					<cfset stPrimary[arguments.PrimaryFieldname] = ArrayNew(1)>
					<cfloop list="#arguments.DataObjectID#" index="i">
						<cfset arrayAppend(stPrimary[arguments.PrimaryFieldname],i)>
					</cfloop>
				<cfelse>
					<cfset pos = ListFindNoCase(ArrayToList(stPrimary[arguments.PrimaryFieldname]), arguments.DataObjectID)>
					<cfif pos GT 0>
						<cfset ArrayDeleteAt(stPrimary[arguments.PrimaryFieldname],pos)>
					</cfif>
								
				</cfif>			
			</cfif>
		
			
			
			<cfparam name="session.dmSec.authentication.userlogin" default="anonymous" />
			<cfset st = oPrimary.setData(objectID=stPrimary.ObjectID,stProperties="#stPrimary#",user="#session.dmSec.authentication.userlogin#")>
		</cfif>
	</cfif>
	
	
	<ft:object objectID="#arguments.PrimaryObjectID#" WizzardID="#arguments.WizzardID#" lFields="#arguments.PrimaryFieldName#" inTable=0 IncludeLabel=0 IncludeFieldSet=0 r_stFields="stFields" />
		
	<cfoutput>
		#stFields[arguments.PrimaryFieldName].HTML#
	</cfoutput>

</cffunction>


</cfcomponent> 

