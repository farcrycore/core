
<cfcomponent displayname="Handpicked Rule" extends="rules" hint="">

<cfproperty name="aObjects" type="array" hint="Array of WDDX Packets containing an stParams stucture.stParams has objectID and method specified as well as any other keys for use with the selected method " required="yes" default="">
	
	<cffunction access="public" name="update" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="label" required="no" type="string" default="">
		<cfimport taglib="/fourq/tags/" prefix="q4">

		<cfset stObj = this.getData(arguments.objectid)> 
		<!--- Handpicking an object is a multistep process - sticking it in a PLP --->
		<cfparam name="URL.killplp" default="0">
		<q4:plp 
			owner="#session.dmSec.authentication.userlogin#_#stObj.objectID#"
			stepDir="#application.fourq.plppath#/ruleHandpicked"
			iTimeout="15"
			stInput="#stObj#"
			bDebug="0"
			bForceNewInstance="#url.killplp#"
			r_stOutput="stOutput"
			storage="file"
			storagedir="#application.fourq.plpstorage#"
			redirection="server"
			r_bPLPIsComplete="bComplete">

			<q4:plpstep name="step1" template="step1.cfm">
			<q4:plpstep name="step2" template="step3.cfm">
			<q4:plpstep name="step3" template="step3.cfm">
		</q4:plp>


		<cfif isDefined("bComplete") and bComplete>
			<span class="FormTitle">PLP Complete - Object Updated</span>
		<cfscript>
			stProperties = Duplicate(stOutput);
			stProperties.label = stproperties.title;
			// stProperties.aObjectIDs = arrayNew(1);
			// arrayAppend(stProperties.aObjectIDs, form.aObjectIDs);
			stProperties.datetimelastupdated = Now();
			stProperties.lastupdatedby = getAuthUser();
		</cfscript>
		<q4:contentobjectdata
			 typename="#application.packagepath#.rules.ruleHandpicked"
			 stProperties="#stProperties#"
			 objectid="#stObj.ObjectID#"
		>

	</cfif>
		
	</cffunction> 
	
	<cffunction name="getDefaultProperties" returntype="struct" access="public">
		<cfscript>
			stProps=structNew();
			stProps.objectid = createUUID();
			stProps.label = '';
			stProps.displayMethod = 'displayteaserbullet';
			stProps.numPages = 1;
			stProps.numItems = 5;
			stProps.bArchive = 0;
			stProps.bMatchAllKeywords = 0;
			stProps.metadata = '';
		</cfscript>	
		<cfreturn stProps>
	</cffunction>  

	<cffunction access="public" name="execute" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="dsn" required="false" type="string" default="#application.dsn#">
		
		<cfset stObj = this.getData(arguments.objectid)> 
		<cfscript>
			sql = 'SELECT TOP ' & stObj.numItems & ' * FROM dmNews';
		</cfscript>

		<cfquery datasource="#arguments.dsn#" name="qGetNews">
			#preserveSingleQuotes(sql)#
		</cfquery> 
		
		<cfif NOT stObj.bArchive>
			<cfoutput query="qGetNews">
				<cfscript>
				 	stInvoke = structNew();
					stInvoke.objectID = qGetNews.objectID;
					stInvoke.typename = "#application.packagepath#.types.dmNews";
					stInvoke.method = stObj.displayMethod;
					arrayAppend(request.aInvocations,stInvoke);
				</cfscript>
			</cfoutput>
		</cfif>
		
	</cffunction> 

</cfcomponent>