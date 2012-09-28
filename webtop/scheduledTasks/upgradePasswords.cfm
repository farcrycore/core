<cfsetting enablecfoutputonly="Yes" requesttimeout="10000">
<!--- @@displayname: Update Password Encryption --->

<cfparam name="url.plain" type="boolean" default="false" >
<cfparam name="url.md5"  type="boolean" default="false" >
<cfparam name="url.timeout" type="numeric" default="3600" >

<cfset url.timeout = url.timeout * 1000 />

<cfset plainUpdateCount = 0>
<cfset md5updateCount = 0>
<cfset timedout = false>

<cfset oBcryptHash = application.security.cryptlib.getHashComponent("bcrypt") />
<cfset oMd5thenbcryptHash = application.security.cryptlib.getHashComponent("md5thenbcrypt") />

<cfquery name="qUsers" datasource="#application.dsn#">
	SELECT objectid,password,datetimelastupdated
	FROM #application.dbowner#farUser
	where password not like '%$%'
</cfquery>

<cfset start = getTickCount() />

<cfloop query="qUsers">
	<cfset oldPasswordHashName = application.security.cryptlib.findHash(qUsers.password).alias />
	<cfif oldPasswordHashName eq "none" and url.plain>
		<cfset newPassword = oBcryptHash.encode(qUsers.password) />
		<cfset plainUpdateCount = plainUpdateCount + 1 />
	<cfelseif oldPasswordHashName eq "md5" and url.md5>
		<cfset newPassword = oMd5thenbcryptHash.bcryptOverMD5(qUsers.password) />
		<cfset md5updateCount = md5updateCount + 1 />
	<cfelse>
		<cfset newPassword = qUsers.password />
	</cfif>
	
	<cfif newPassword neq qUsers.password>
		<cfquery name="qUpdateUser" datasource="#application.dsn#">
			UPDATE 	#application.dbowner#farUser
			SET		password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#newPassword#">,
					datetimelastupdated = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
					lastupdatedby = 'passwordfix'
			WHERE 	objectid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qUsers.objectid#">
					and datetimelastupdated = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#qUsers.datetimelastupdated#" />
		</cfquery>
	</cfif>
	
	<cfif getTickCount() - start gt url.timeout>
		<cfset timedout = true>
		<cfbreak>
	</cfif>
</cfloop>

<cfoutput>
<h4>Upgrade process has completed.</h4>
<p>Number of passwords read: #qUsers.recordCount#</p>
<p>Number of plaintext passwords upgraded to bcrypt: #plainUpdateCount#</p>
<p>Number of MD5 passwords upgraded to MD5+bcrypt: #md5updateCount#</p>
<p>Timed out before finishing: #yesnoformat(timedout)#</p>
</cfoutput>

<cfsetting enablecfoutputonly="No">