<cfcomponent displayname="Plugins" hint="Plugin management" output="false">
		
	
	<cffunction name="getPlugins" access="public" output="false" returntype="query" hint="Returns information about the available plugins">
		<cfset var qPlugins = querynew("id,name,type,description,icon,version,releaseDate,requiredPlugins,requiredCoreVersions,homeURL,docURL,bugURL,license,status","varchar,varchar,varchar,varchar,varchar,varchar,date,varchar,varchar,varchar,varchar,varchar,varchar,varchar") />
		<cfset var qDir = "" />
		<cfset var oManifest = "" />
		<cfset var version  ="" />
		<cfset var lVersions = "" />
		
		<cfdirectory action="list" directory="#expandpath('/farcry/plugins')#" recurse="false" name="qDir" />
		
		<cfloop query="qDir">
			<cfif qDir.type eq "dir" and left(qDir.name,4) neq "bak_">
				<cfset queryaddrow(qPlugins) />
				<cfset querysetcell(qPlugins,"id",qDir.name) />
				
				<cfif fileexists("#qDir.directory#/#qDir.name#/install/manifest.cfc")>
					<cfset oManifest = createobject("component","farcry.plugins.#qDir.name#.install.manifest") />
					
					<cfif structkeyexists(oManifest,"name")>
						<cfset querysetcell(qPlugins,"name",oManifest.name) />
					<cfelse>
						<cfset querysetcell(qPlugins,"name",qDir.name) />
					</cfif>
					
					<cfif structkeyexists(oManifest,"type")>
						<cfset querysetcell(qPlugins,"type",oManifest.type) />
					<cfelse>
						<cfset querysetcell(qPlugins,"type","general") />
					</cfif>
					
					<cfif structkeyexists(oManifest,"description")>
						<cfset querysetcell(qPlugins,"description",oManifest.description) />
					</cfif>
					
					<cfif structkeyexists(oManifest,"icon")>
						<cfset querysetcell(qPlugins,"icon",oManifest.icon) />
					</cfif>
					
					<cfif structkeyexists(oManifest,"version")>
						<cfset querysetcell(qPlugins,"version",oManifest.version) />
					</cfif>
					
					<cfif structkeyexists(oManifest,"releasedate")>
						<cfset querysetcell(qPlugins,"releasedate",oManifest.releasedate) />
					</cfif>
					
					<cfif structkeyexists(oManifest,"homeurl")>
						<cfset querysetcell(qPlugins,"homeurl",oManifest.homeurl) />
					</cfif>
					
					<cfif structkeyexists(oManifest,"docurl")>
						<cfset querysetcell(qPlugins,"docurl",oManifest.docurl) />
					</cfif>
					
					<cfif structkeyexists(oManifest,"bugurl")>
						<cfset querysetcell(qPlugins,"bugurl",oManifest.bugurl) />
					</cfif>
					
					<cfif structkeyexists(oManifest,"license")>
						<cfset querysetcell(qPlugins,"license",oManifest.license) />
					</cfif>
					
					<cfif structkeyexists(oManifest,"lRequiredPlugins")>
						<cfset querysetcell(qPlugins,"requiredPlugins",oManifest.lRequiredPlugins) />
					</cfif>
					
					<cfif structkeyexists(oManifest,"stSupportedCores")>
						<cfset lVersions = "" />
						<cfloop collection="#oManifest.stSupportedCores#" item="version">
							<cfset lVersions = listappend(lVersions,"#replace(version,'-','.','ALL')#.#oManifest.stSupportedCores[version].patchVersion#") />
						</cfloop>
						<cfset querysetcell(qPlugins,"requiredCoreVersions",lVersions) />
					</cfif>
					
					<cfif listfindnocase(application.plugins,qDir.name)>
						<cfif structkeyexists(oManifest,"getStatus")>
							<cfset querysetcell(qPlugins,"status",oManifest.getStatus()) />
						<cfelse>
							<cfset querysetcell(qPlugins,"status","Unknown") />
						</cfif>
					</cfif>
				<cfelse>
					<cfset querysetcell(qPlugins,"name",qDir.name) />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfquery dbtype="query" name="qPlugins">select *, lower(name) as lowername from qPlugins order by lowername</cfquery>
		
		<cfreturn qPlugins />
	</cffunction>
	
	<cffunction name="orderPlugins" access="public" output="false" returntype="string" hint="Orders plugins so that plugins are listed after those they depend on, and skins are listed last">
		<cfargument name="plugins" type="string" required="true" />
		
		<cfset var thisplugin = "" />
		<cfset var result = "" />
		<cfset var qPlugins = getPlugins() />
		<cfset var q = "" />
		<cfset var requiredplugin = "" />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfloop list="#arguments.plugins#" index="thisplugin">
			<cfquery dbtype="query" name="q">select * from qPlugins where id='#thisplugin#'</cfquery>
			<cfif not q.recordcount>
				<skin:bubble message="'#thisplugin#' is not a valid plugin" tags="orderplugins,error" />
			</cfif>
			<cfif len(q.requiredPlugins)>
				<cfloop list="#q.requiredPlugins#" index="requiredplugin">
					<cfif not listfindnocase(result,requiredplugin) and listfindnocase(arguments.plugins,requiredplugin)>
						<cfset result = listappend(result,requiredplugin) />
					<cfelseif not listfindnocase(result,requiredplugin) and listfindnocase(arguments.plugins,requiredplugin)>
						<skin:bubble message="'#thisplugin#' requires '#requiredplugin#' but has not been selected" tags="orderplugins,error" />
					</cfif>
				</cfloop>
			</cfif>
			<cfif not listfindnocase(result,thisplugin) and q.type neq "skin">
				<cfset result = listappend(result,thisplugin) />
			</cfif>
		</cfloop>
		
		<cfloop list="#arguments.plugins#" index="thisplugin">
			<cfif not listfindnocase(result,thisplugin) and q.type eq "skin">
				<cfset result = listappend(result,thisplugin) />
			</cfif>
		</cfloop>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="writeConstructorXML" access="public" output="false" returntype="void" hint="Updates farcryConstructor.xml with the specified data">
		<cfargument name="plugins" type="string" required="false" />
		
		<cfset var constructorXML = xmlnew() />
		
		<cfset constructorXML.xmlRoot = XmlElemNew(constructorXML,"FarcryConstructor") />
		<cfset constructorXML.FarcryConstructor.XmlChildren[1] = XmlElemNew(constructorXML,"plugins") />
        <cfset constructorXML.FarcryConstructor.XmlChildren[1].XmlText = orderPlugins(arguments.plugins) />
		
		<cffile action="write" file="#application.path.project#/www/farcryConstructor.xml" output="#toString(constructorXML)#" />
	</cffunction>
	
</cfcomponent>