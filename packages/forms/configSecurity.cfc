<cfcomponent displayname="Security Config" extends="farcry.core.packages.forms.forms" key="security"
	hint="Security configuration settings for the web application." output="false">

	<cfproperty name="defaultUserDirectory" type="string" ftType="list" ftListData="listUserDirectories"
		ftSeq="1" ftFieldset="Directories and Storage" ftLabel="Default user directory"
		ftHint="" hint="User directory selected by default when multiple are available">

	<cfproperty name="passwordHashAlgorithm" type="string" ftType="list" ftListData="listHashAlgorithms"
		ftSeq="2" ftFieldset="Directories and Storage" ftLabel="Password hashing algorithm"
		ftHint="" hint="Algorithm used to encrypt passwords in the database">


	<cffunction name="listUserDirectories" access="public" returntype="query" description="Returns the available user directories" output="false">
		<cfset var qUD = querynew("name,value") />
		<cfset var thisud = "" />
		
		<cfset queryaddrow(qUD) />
		<cfset querysetcell(qUD,"value","") />
		<cfset querysetcell(qUD,"name","First Enabled Directory") />
		
		<cfloop list="#application.security.getAllUD()#" index="thisud">
			<cfset queryaddrow(qUD) />
			<cfset querysetcell(qUD,"value",thisud) />
			<cfset querysetcell(qUD,"name",application.security.userdirectories[thisud].title) />
		</cfloop>
		
		<cfreturn qUD />
	</cffunction>

	<cffunction name="listHashAlgorithms" access="public" returntype="query" description="Returns the available password hash algorithms" output="false">
		<cfset var qPwdHash = querynew("name,value") />
		<cfset var aPwdHashes = application.security.userdirectories.CLIENTUD.getOrderedHashArray() />
		<cfset var pwdHashCount = arrayLen(aPwdHashes) />
		<cfset var i = "" />
		<cfset var oPwdHash = "" />
		
		<cfset queryaddrow(qPwdHash) />
		<cfset querysetcell(qPwdHash,"value","") />
		<cfset querysetcell(qPwdHash,"name","System default") />
		
		<cfloop index="i" from="1" to="#pwdHashCount#">
			<cfset oPwdHash = aPwdHashes[i] />
			<cfset queryaddrow(qPwdHash) />
			<cfset querysetcell(qPwdHash,"value",oPwdHash.key) />
			<cfset querysetcell(qPwdHash,"name",oPwdHash.title) />
		</cfloop>
		
		<cfreturn qPwdHash />
	</cffunction>

</cfcomponent>