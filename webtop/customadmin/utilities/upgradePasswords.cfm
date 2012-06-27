<cfsetting enablecfoutputonly="Yes" requesttimeout="2000">
	
<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header />

<sec:CheckPermission error="true" permission="AdminCOAPITab" result="bPermitted" />

<cfif bPermitted>
	<cfif isDefined("Form.submit")>
		<cfparam name="form.bPlainToBcrypt" type="boolean" default="false" >
		<cfparam name="form.bMD5toMD5thenbcrypt"  type="boolean" default="false" >
		
		<cfoutput><h4>Started Password Processing</h4></cfoutput>
		
		<cfset plainUpdateCount = 0>
		<cfset md5updateCount = 0>
		
		<cfif form.bPlaintoBcrypt>
			<cfset oBcryptHash = application.security.cryptlib.getHashComponent("bcrypt") />
		</cfif>
		<cfif form.bMD5toMD5thenbcrypt>
			<cfset oMd5thenbcryptHash = application.security.cryptlib.getHashComponent("md5thenbcrypt") />
		</cfif>
		
		<cfquery name="qUsers" datasource="#application.dsn#">
			SELECT objectid,password
			FROM #application.dbowner#farUser
		</cfquery>
		
		<cfloop query="qUsers">
			<cfset oldPasswordHashName = application.security.cryptlib.findHash(qUsers.password).alias />
			<cfif oldPasswordHashName eq "none" and form.bPlaintoBcrypt>
				<cfset newPassword = oBcryptHash.encode(qUsers.password) />
				<cfset plainUpdateCount = plainUpdateCount + 1 />
			<cfelseif oldPasswordHashName eq "md5" and form.bMD5toMD5thenbcrypt>
				<cfset newPassword = oMd5thenbcryptHash.bcryptOverMD5(qUsers.password) />
				<cfset md5updateCount = md5updateCount + 1 />
			<cfelse>
				<cfset newPassword = qUsers.password />
			</cfif>
			
			<cfif newPassword neq qUsers.password>
				<cfquery name="qUpdateUser" datasource="#application.dsn#">
					UPDATE #application.dbowner#farUser
					SET
						password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#newPassword#">,
						datetimelastupdated = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
						lastupdatedby = 'passwordfix'
					WHERE objectid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qUsers.objectid#">
				</cfquery>
			</cfif>
		</cfloop>
		
		<cfoutput>
		<h4>Upgrade process has completed.</h4>
		<p>Number of passwords read: #qUsers.recordCount#</p>
		<p>Number of plaintext passwords upgraded to bcrypt: #plainUpdateCount#</p>
		<p>Number of MD5 passwords upgraded to MD5+bcrypt: #md5updateCount#</p>
		</cfoutput>
	
	<cfelse>
		<cfoutput>
		<h3>Upgrade Password Security</h3>
		<form action="" method="post">
		<h4>Hashing Algorithms</h4>
		Upgrade plaintext passwords to bcrypt? : <input type="Radio" name="bPlainToBcrypt" value="true" checked /> Yes <input type="Radio" name="bPlainToBcrypt" value="false" /> No
		<br />
		Upgrade MD5 passwords to MD5+bcrypt? : <input type="Radio" name="bMD5toMD5thenbcrypt" value="true" checked /> Yes <input type="Radio" name="bMD5toMD5thenbcrypt" value="false" /> No
		<br />
		<input type="Submit" name="submit" value="Process Passwords" />
		</form>
		</cfoutput>
	</cfif>
</cfif>

<admin:footer />
<cfsetting enablecfoutputonly="No">