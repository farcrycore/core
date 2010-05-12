<cfcomponent name="library" displayname="library" hint="Used by the Library for the ajax callbacks" output="false" > 

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
<cfimport taglib="/farcry/core/tags/wizard/" prefix="wiz" >

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


	
	<cfset var PrimaryPackage = application.stcoapi[arguments.primaryTypeName] />
	<cfset var PrimaryPackagePath = application.stcoapi[arguments.primaryTypeName].packagePath />
	<cfset var oPrimary = createObject("component",PrimaryPackagePath)>
	<cfset var stPrimary = oPrimary.getData(objectid=arguments.PrimaryObjectID)>
	<cfset var oData = createObject("component",application.stcoapi[arguments.DataTypename].packagepath)>
	<cfset var oWizard = "" />
	<cfset var stwizard = structNew() />


	<cfset session.ajaxUpdatingArray = true />
	
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
				<cfset application.fc.lib.db.setArrayData(typename=primarytypename,propertyname=primaryfieldname,objectid=arguments.primaryObjectID,aProperties=stwizard.Data[PrimaryObjectID][arguments.PrimaryFieldname],dsn=application.dsn) />
				
				<cfset stwizard.Data[PrimaryObjectID][arguments.PrimaryFieldname] = aProps>
			</cfif>
			
			<cfset stResult = owizard.Write(ObjectID=arguments.wizardID,Data=stwizard.Data)>
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
	
			<cfset stResult = oPrimary.setData(stProperties="#stPrimary#",user="#application.security.getCurrentUserID()#")>


		</cfif>
	</cfif>
	
	<cfset stPropMetadata = structNew() />
	<cfset stPropMetadata[arguments.PrimaryFieldName] = structNew() />
	<cfset stPropMetadata[arguments.PrimaryFieldName].ftEditMethod = "libraryCallback" >


	<cfif len(arguments.wizardID)>
		<wiz:object objectID="#arguments.PrimaryObjectID#" wizardID="#arguments.wizardID#" lFields="#arguments.PrimaryFieldName#" stPropMetadata="#stPropMetadata#" inTable=0 IncludeLabel=0 IncludeFieldSet=0 r_stFields="stFields" IncludeLibraryWrapper="false" packageType="#arguments.packageType#" />
	<cfelse>
		<ft:object objectID="#arguments.PrimaryObjectID#" lFields="#arguments.PrimaryFieldName#" stPropMetadata="#stPropMetadata#" inTable=0 IncludeLabel=0 IncludeFieldSet=0 r_stFields="stFields" IncludeLibraryWrapper="false" packageType="#arguments.packageType#" />
	</cfif>	
	
	<cfset session.ajaxUpdatingArray = false />

	<cfoutput>
	#stFields[arguments.PrimaryFieldName].HTML#
	</cfoutput>

</cffunction>


</cfcomponent> 

