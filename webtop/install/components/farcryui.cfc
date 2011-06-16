<cfcomponent displayname="FarCry UI" hint="UI interface for native installer" output="false">
	
	<cffunction name="init" returntype="farcryui" output="false" access="public" hint="Initialises the UI">
		<cfargument name="config" type="struct" required="true" hint="" />
		
		<cfset this.error = structnew() />
		<cfset this.progress = 0 />
		<cfset this.progressmessage = "" />
		
		<cfset this.bComplete = false />
		<cfset this.currentStep = "1" />
		<cfset this.lCompletedSteps = "" />
		<cfset this.stConfig = "#structNew()#" />
		<cfset this.stConfig.bInstallDBOnly = false />	
		<cfset this.stConfig.applicationName = "" />
		<cfset this.stConfig.displayName = "" />
		<cfset this.stConfig.locales = "en_AU,en_US" />
		<cfset this.stConfig.DSN = "" />
		<cfset this.stConfig.DBType = "" />
		<cfset this.stConfig.DBOwner = "" />
		<cfset this.stConfig.skeleton = "" />
		<cfset this.stConfig.plugins = "" />
		<cfset this.stConfig.projectInstallType = "subDirectory" />
		<cfset this.stConfig.webtopInstallType = "project" />
		<cfset this.stConfig.adminPassword = "#right(createUUID(),6)#" />
		<cfset this.stConfig.updateappKey = "#right(createUUID(),4)#" />\
		
		<cfreturn this />
	</cffunction>
	
	
	<cffunction name="setError" returntype="void" output="true" access="public" hint="Notifies the UI of an installation error">
		<cfargument name="error" type="struct" required="true" hint="CFCatch struct" />
		
		<cfdump var="#arguments.error#"><cfabort>
	</cffunction>
	
	<cffunction name="setProgress" returntype="void" output="true" access="public" hint="Notifies the UI of installation progress">
		<cfargument name="progressmessage" type="string" required="true" hint="Description of progress" />
		<cfargument name="progress" type="numeric" required="true" hint="Progress of installation as a number between 0 and 1" />
		
		<cfset this.progressmessage = arguments.progressmessage />
		<cfset this.progress = arguments.progress />
		
		<cfset writeOutput("<script type='text/javascript'>updateProgressBar(#numberformat(this.progress,'0.00')#, '#this.progressmessage#');</script>") />
		<cfflush />
	</cffunction>
	
	<cffunction name="getDBTypes" returntype="query" output="false" access="public" hint="Returns the key, label, and dbowner usage of all available database types">
		<cfset var stTypes = structnew() />
		<cfset var thistype = "" />
		<cfset var thisitem = "" />
		<cfset var qDBTypes = querynew("key,label,usesDBOwner","varchar,varchar,bit") />
		<cfset var stMD = "" />
		<cfset var tmpType="" />
		
		<cfset stTypes = createobject("component","farcry.core.packages.lib.db").getDBTypes() />
		
		<cfloop collection="#stTypes#" item="thistype">
			<cfset tmpType=sttypes[thistype]>
			<cfset tmpType=tmpType[1]>
			<cfset stMD = getMetadata(createobject("component",tmpType)) />
			
			<cfif structkeyexists(stMD,"dbType") and len(stMD.dbType)>
				<cfloop list="#stMD.dbType#" index="thisitem">
					<cfif listfirst(thisitem,":") eq thistype>
						<cfset queryaddrow(qDBTypes) />
						<cfset querysetcell(qDBTypes,"label",listlast(thisitem,":")) />
					</cfif>
				</cfloop>
				<cfset querysetcell(qDBTypes,"key",thistype) />
				<cfset querysetcell(qDBTypes,"usesDBOwner",stMD.usesDBOwner) />
			</cfif>
		</cfloop>
		
		<cfreturn qDBTypes />
	</cffunction>
	
</cfcomponent>