<cfcomponent displayname="Security Configuration" extends="farcry.core.packages.forms.forms" key="security"
	hint="Security configuration settings for the web application." output="false">

	<!--- Directories and storage --->
	
	<cfproperty name="defaultUserDirectory" type="string" ftType="list" ftListData="listUserDirectories"
		ftSeq="1" ftFieldset="Directories and Storage" ftLabel="Default user directory"
		ftHint="" hint="User directory selected by default when multiple are available">

	<cfproperty name="passwordHashAlgorithm" type="string" default="bcrypt" ftType="list" ftListData="listHashAlgorithms"
		ftSeq="2" ftFieldset="Directories and Storage" ftLabel="Password hashing algorithm"
		ftHint="" hint="Algorithm used to encrypt passwords in the database">

	<!--- Password policy --->
	
	<cfproperty name="passwordMinLength" type="integer" ftType="integer" default="6" ftValidation="required"
		ftSeq="10" ftFieldset="Password Policy" ftLabel="Minimum Password Length"
		ftHint="Set the minimum number of number characters required for a password. Choose 0 for no minimum length.">

	<cfproperty name="bIncludeLetters" type="boolean" ftType="boolean" default="0" 
		ftSeq="11" ftFieldset="Password Policy" ftLabel="Must include alphabetic characters"
		ftHint="">

	<cfproperty name="bIncludeMixedCase" type="boolean" ftType="boolean" default="0" 
		ftSeq="12" ftFieldset="Password Policy" ftLabel="Must include mix of UPPER and lower case letters"
		ftHint="">

	<cfproperty name="bIncludeNumeric" type="boolean" ftType="boolean" default="0" 
		ftSeq="13" ftFieldset="Password Policy" ftLabel="Must include Numeric characters"
		ftHint="">

	<cfproperty name="bIncludeSymbol" type="boolean" ftType="boolean" default="0" 
		ftSeq="14" ftFieldset="Password Policy" ftLabel="Must include Punctuation or Symbol characters"
		ftHint="">

	<cfproperty name="passwordPolicyHint" type="string" ftType="longchar" default="Minimum password length of 6 characters." 
		ftSeq="30" ftFieldset="Password Policy" ftLabel="Password Policy Help Text" ftLimit="250"
		ftHint="Provide a short description of the password policy defined above.">


	<!--- Directories and storage methods --->
	
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
		<cfset var aPwdHashes = application.security.cryptlib.getOrderedHashArray() />
		<cfset var pwdHashCount = arrayLen(aPwdHashes) />
		<cfset var i = "" />
		<cfset var oPwdHash = "" />
		
		<cfloop index="i" from="1" to="#pwdHashCount#">
			<cfset oPwdHash = aPwdHashes[i] />
			<cfset queryaddrow(qPwdHash) />
			<cfset querysetcell(qPwdHash,"value",oPwdHash.alias) />
			<cfset querysetcell(qPwdHash,"name",oPwdHash.title) />
		</cfloop>
		
		<cfreturn qPwdHash />
	</cffunction>

	<!--- Password policy methods --->
	
	<cffunction name="getPasswordPolicyRegex" returntype="string"
		hint="Returns a regular expression which can be used to test a password for meeting the required password policy">

		<cfset var regex = "^.*">

		<cfif int(application.fapi.getConfig("security","passwordMinLength")) gt 0>
			<cfset regex = regex & "(?=.{#application.fapi.getConfig("security","passwordMinLength")#})">
		</cfif>
		<cfif application.fapi.getConfig("security","bIncludeLetters")>
			<cfset regex = regex & "(?=.*[[:alpha:]])">
		</cfif>
		<cfif application.fapi.getConfig("security","bIncludeMixedCase")>
			<cfset regex = regex & "(?=.*[a-z])(?=.*[A-Z])">
		</cfif>
		<cfif application.fapi.getConfig("security","bIncludeNumeric")>
			<cfset regex = regex & "(?=.*[0-9])">
		</cfif>
		<cfif application.fapi.getConfig("security","bIncludeSymbol")>
			<cfset regex = regex & "(?=.*[^a-zA-Z-0-9])">
		</cfif>

		<cfset regex = regex & ".*$">
		
		<cfreturn regex>
	</cffunction>

</cfcomponent>