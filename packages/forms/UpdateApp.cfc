<cfcomponent displayname="Update App" hint="Provides a granular way to update parts of the application state" extends="forms" output="false">
	<cfproperty name="webtop" type="boolean" default="0" hint="Reload webtop data" ftSeq="1" ftFieldset="Data" ftLabel="Webtop" ftType="boolean" />
	<cfproperty name="friendlyurls" type="boolean" default="0" hint="Reload friendly urls" ftSeq="2" ftFieldset="Data" ftLabel="Friendly URLs" ftType="boolean" />
	
	<cfproperty name="typemetadata" type="boolean" default="0" hint="Reload type metadata" ftSeq="11" ftFieldset="COAPI" ftLabel="Type metadata" ftType="boolean" />
	
	<cffunction name="process" access="public" output="true" returntype="struct" hint="Performs application refresh according to options selected">
		<cfargument name="fields" type="struct" required="true" hint="The fields submitted" />
		
		<!--- Webtop reload --->
		<cfif structkeyexists(arguments.fields,"webtop") and arguments.fields.webtop>
			<cfset application.factory.oWebtop = createobject("component","#application.packagepath#.farcry.webtop").init() />
		</cfif>
		
		<!--- Friendly URLs --->
		<cfif structkeyexists(arguments.fields,"friendlyurls") and arguments.fields.friendlyurls>
			<cfset createObject("component","#application.packagepath#.farcry.fu").refreshApplicationScope() />
		</cfif>
		
		<!--- Type metadata --->
		<cfif structkeyexists(arguments.fields,"typemetadata") and arguments.fields.typemetadata>
			<cfset createObject("component", "#application.packagepath#.farcry.alterType").refreshAllCFCAppData() />
		</cfif>
		
		<cfreturn arguments.fields />
	</cffunction>
</cfcomponent>