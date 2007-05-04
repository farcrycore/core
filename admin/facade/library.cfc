<cfcomponent name="library" displayname="library" hint="Used by the Library for the ajax callbacks" output="false" > 

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >

<cffunction name="ajaxGetView" access="remote" output="true" returntype="void">
 	<cfargument name="objectid" required="yes" type="uuid" hint="ObjectID of the object to be rendered.">
 	<cfargument name="typename" required="no" default="" type="string" hint="typename of the object to be rendered.">
 	<cfargument name="webskin" required="yes" type="string">

	<cfset var q4 = "" />
	<cfset var o = "" />

	<cfif not len(arguments.typename)>
		<cfset q4 = createObject("component", "farcry.core.packages.fourq.fourq")>
		<cfset arguments.typename = q4.findType(objectid=arguments.objectid)>
	</cfif>	
	
	<cfset o = createObject("component", application.stcoapi[arguments.typename].packagepath) />
	<cfset HTML = o.getView(objectid=arguments.objectid, template=arguments.webskin, alternateHTML="webskin not available") />	
	
	<cfoutput>#HTML#</cfoutput>


</cffunction>

<cffunction name="ajaxGetValue" access="remote" output="true" returntype="void">
 	<cfargument name="objectid" required="yes" type="string" hint="ObjectID of the object to be rendered.">
 	<cfargument name="typename" required="no" default="" type="string" hint="typename of the object to be rendered.">
 	<cfargument name="fieldname" required="yes" type="string">

 	<cfset var q4 = "" />
	<cfset var o = "" />
	<cfset var st = structNew() />

	<cfif len(arguments.objectid)>
		<cfif not len(arguments.typename)>
			<cfset q4 = createObject("component", "farcry.core.packages.fourq.fourq")>
			<cfset arguments.typename = q4.findType(objectid=arguments.objectid)>
		</cfif>	
		
		<cfset o = createObject("component", application.stcoapi[arguments.typename].packagepath) />
		<cfset st = o.getData(objectid=arguments.objectid) />	
		
		<cfoutput>#st[arguments.fieldname]#</cfoutput>
	</cfif>
	
</cffunction>


<cffunction name="ajaxUpdateArray" access="remote" output="true" returntype="void">
 	<cfargument name="LibraryType" required="yes" type="string" hint="Can be Array or UUID. If UUID, only 1 value can be stored.">
 	<cfargument name="PrimaryObjectID" required="yes" type="UUID">
	<cfargument name="PrimaryTypename" required="yes" type="string">
 	<cfargument name="PrimaryFieldName" required="yes" type="string">
 	<cfargument name="PrimaryFormFieldName" required="yes" type="string">
	<cfargument name="DataObjectID" required="yes" type="string" hint="this could be a UUID to be added or a list of UUID's if we are re-sorting">
	<cfargument name="DataTypename" required="yes" type="string">
 	<cfargument name="wizardID" required="no" type="string" default="">
 	<cfargument name="Action" required="no" type="string" default="Add" hint="Value can be [Add] or [Remove] or [Sort]">


	<cfargument name="ftLibrarySelectedWebskin" type="string" default="selected"><!--- Webskin Display method to Display Selected Objects --->
	<cfargument name="ftLibrarySelectedWebskinListClass" type="string" default="selected">
	<cfargument name="ftLibrarySelectedWebskinListStyle" type="string" default="">
	
	<cfargument name="packageType" type="string" default="types">


	
	<cfset PrimaryPackage = application.stcoapi[arguments.primaryTypeName] />
	<cfset PrimaryPackagePath = application.stcoapi[arguments.primaryTypeName].packagePath />	



	<cfset oPrimary = createObject("component",PrimaryPackagePath)>
	<cfset stPrimary = oPrimary.getData(objectid=arguments.PrimaryObjectID)>

	<cfset oData = createObject("component",application.stcoapi[arguments.DataTypename].packagepath)>


	<cfif arguments.Action NEQ "Refresh">
	
		<cfif len(arguments.wizardID)>
			
			
			<cfset owizard = createObject("component",application.stcoapi['dmWizard'].packagepath)>
			
			<cfset stwizard = owizard.Read(wizardID=arguments.wizardID)>
			
			<cfif arguments.LibraryType EQ "UUID">
				<cfif arguments.Action EQ "Add">
					<cfset stwizard.Data[PrimaryObjectID][arguments.PrimaryFieldname] = arguments.DataObjectID>
				<cfelse>
					<cfset stwizard.Data[PrimaryObjectID][arguments.PrimaryFieldname] = "">
				</cfif>			
			<cfelse><!--- Array --->
				<cfif arguments.Action EQ "Add">
					<cfset arrayAppend(stwizard.Data[PrimaryObjectID][arguments.PrimaryFieldname],arguments.DataObjectID)>
				<cfelseif arguments.Action EQ "Sort">
					<cfset stwizard.Data[PrimaryObjectID][arguments.PrimaryFieldname] = ArrayNew(1)>
					<cfloop list="#arguments.DataObjectID#" index="i">
						<cfset arrayAppend(stwizard.Data[PrimaryObjectID][arguments.PrimaryFieldname],i)>
					</cfloop>
				<cfelse>
					<cfset pos = ListFindNoCase(ArrayToList(stwizard.Data[PrimaryObjectID][arguments.PrimaryFieldname]), arguments.DataObjectID)>
					<cfif pos GT 0>
						<cfset ArrayDeleteAt(stwizard.Data[PrimaryObjectID][arguments.PrimaryFieldname],pos)>
					</cfif>
				</cfif>			
				<cfset stFields = application.stcoapi[PrimaryTypename].tableDefinition />				
				<cfset o = createObject("component","farcry.core.packages.fourq.gateway.dbGateway").init(dsn=application.dsn,dbowner="")>
				<cfset aProps = o.createArrayTableData(tableName=PrimaryTypename & "_" & PrimaryFieldName,objectid=arguments.PrimaryObjectID,tabledef=stFields[PrimaryFieldName].Fields,aprops=stwizard.Data[PrimaryObjectID][arguments.PrimaryFieldname])>
		
				<cfset stwizard.Data[PrimaryObjectID][arguments.PrimaryFieldname] = aProps>
			</cfif>
			
			<cfset stwizard = owizard.Write(ObjectID=arguments.wizardID,Data=stwizard.Data)>
			
			<cfset st = stwizard.Data[PrimaryObjectID]>
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
			<cfset st = oPrimary.setData(stProperties="#stPrimary#",user="#session.dmSec.authentication.userlogin#")>
			
						

			<cfset st = oPrimary.getData(objectid="#stPrimary.objectid#")>
			


		</cfif>
	</cfif>
	
	<cfset stPropMetadata = structNew() />
	<cfset stPropMetadata[arguments.PrimaryFieldName] = structNew() />
	<cfset stPropMetadata[arguments.PrimaryFieldName].ftEditMethod = "libraryCallback" >



	<ft:object objectID="#arguments.PrimaryObjectID#" wizardID="#arguments.wizardID#" lFields="#arguments.PrimaryFieldName#" stPropMetadata="#stPropMetadata#" inTable=0 IncludeLabel=0 IncludeFieldSet=0 r_stFields="stFields" IncludeLibraryWrapper="false" packageType="#arguments.packageType#" />
		


	<cfoutput>
	#stFields[arguments.PrimaryFieldName].HTML#
	</cfoutput>

</cffunction>


</cfcomponent> 

