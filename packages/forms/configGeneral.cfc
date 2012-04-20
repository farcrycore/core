<cfcomponent displayname="General Config" hint="General configuration settings for the web application." extends="forms" output="false" key="general">

<!--- site description --->
	<cfproperty ftSeq="10" ftFieldset="Site Description" name="sitetagline" type="string" default="tell it to someone who cares" hint="???" ftLabel="Site tag line" ftType="string" />
	<cfproperty ftSeq="11" ftFieldset="Site Description" name="sitetitle" type="string" default="farcry" hint="???" ftLabel="Site title" ftType="string" />
	<cfproperty ftSeq="12" ftFieldset="Site Description" name="sitelogopath" type="string" default="" hint="???" ftLabel="Logo path" ftType="string" />


<!--- sysadmin properties --->
	<cfproperty ftSeq="21" ftFieldset="SysAdmin Properties" name="adminemail" type="string" default="support@daemon.com.au" hint="The email address to be used by the system for admin functions" ftLabel="Administration email" ftType="email" />
	<cfproperty ftSeq="22" ftFieldset="SysAdmin Properties" name="adminserver" type="string" default="http://##cgi.HTTP_HOST##" ftDefaultType="expression" hint="???" ftLabel="Administration server" ftType="URL" />
	<cfproperty ftSeq="23" ftFieldset="SysAdmin Properties" name="bugemail" type="string" default="support@daemon.com.au" hint="???" ftLabel="Bug email" ftType="email" />
	<cfproperty ftSeq="24" ftFieldset="SysAdmin Properties" name="componentdocurl" type="numeric" default="/CFIDE/componentutils/componentdetail.cfm" hint="???" ftLabel="Component doc URL" ftType="string" />
	<cfproperty ftSeq="25" ftFieldset="SysAdmin Properties" name="genericadminnumitems" type="numeric" default="15" hint="???" ftLabel="Generic admin number of items" ftType="integer" />
	<cfproperty ftSeq="26" ftFieldset="SysAdmin Properties" name="bEmailErrors" type="boolean" default="0" ftLabel="Email errors" />
	<cfproperty ftSeq="27" ftFieldset="SysAdmin Properties" name="errorEmail" type="string" default="" ftLabel="Error email" ftType="email" />


<!--- login properties --->
	<cfproperty ftSeq="31" ftFieldset="Login Properties" name="sessiontimeout" type="numeric" default="60" hint="???" ftLabel="Session timeout" ftType="integer" />
	<cfproperty ftSeq="32" ftFieldset="Login Properties" name="showforgotpassword" type="boolean" default="1" hint="???" ftLabel="Show forgot password" ftType="boolean" />
	<cfproperty ftSeq="33" ftFieldset="Login Properties" name="loginattemptsallowed" type="numeric" default="3" hint="???" ftLabel="Login attempts allowed" ftType="integer" />
	<cfproperty ftSeq="34" ftFieldset="Login Properties" name="loginattemptstimeout" type="numeric" default="10" hint="???" ftLabel="Login attempts timeout" ftType="integer" />


<!--- file media properties --->
	<cfproperty ftSeq="41" ftFieldset="File Media Properties" name="filedownloaddirectlink" type="boolean" default="0" hint="???" ftLabel="File download direct link" ftType="boolean" />
	<cfproperty ftSeq="42" ftFieldset="File Media Properties" name="filenameconflict" type="string" default="makeunique" hint="???" ftLabel="File name conflict" ftType="string" />
	<cfproperty ftSeq="43" ftFieldset="File Media Properties" name="archivedirectory" type="string" default="##application.path.project##/archive/" ftDefaultType="expression" hint="???" ftLabel="Archive directory" ftType="string" />
	<cfproperty ftSeq="44" ftFieldset="File Media Properties" name="archiveweburl" type="string" default="##application.url.webroot##archive/" ftDefaultType="expression" hint="???" ftLabel="Archive web URL" ftType="string" />
	<cfproperty ftSeq="45" ftFieldset="File Media Properties" name="bdoarchive" type="boolean" default="0" hint="???" ftLabel="Do archives" ftType="boolean" />


<!--- deprecated properties; backward compatability only --->
	<cfproperty ftSeq="1000" ftFieldset="Deprecated Properties" name="teaserlimit" type="numeric" default="255" hint="???" ftLabel="Teaser limit" ftType="integer" />
	<cfproperty ftSeq="1001" ftFieldset="Deprecated Properties" name="verityStoragePath" type="string" default="" ftdefault="##Replace('##server.coldfusion.rootdir##/verity/collections/','\','/','All')##" ftDefaultType="evaluate" hint="???"  ftLabel="Verity storage path" />
	<cfproperty ftSeq="1002" ftFieldset="Deprecated Properties" name="newsexpiry" type="numeric" default="12" hint="???" ftLabel="News expiry" ftType="integer" />
	<cfproperty ftSeq="1003" ftFieldset="Deprecated Properties" name="newsexpirytype" type="string" default="d" hint="???" ftLabel="News expiry type" ftType="string" />
	<cfproperty ftSeq="1004" ftFieldset="Deprecated Properties" name="eventsexpiry" type="numeric" default="14" hint="???" ftLabel="Event expiry" ftType="integer" />
	<cfproperty ftSeq="1005" ftFieldset="Deprecated Properties" name="eventsexpirytype" type="string" default="d" hint="???" ftLabel="Event expiry type" ftType="string" />

	<cfproperty ftSeq="1006" ftFieldset="Deprecated Properties" name="dmfilessearchable" type="boolean" default="1" hint="???" ftLabel="Files searchable" ftType="boolean" />
	<cfproperty ftSeq="1007" ftFieldset="Deprecated Properties" name="logstats" type="boolean" default="1" hint="???" ftLabel="Log stats" ftType="boolean" />

	<cfproperty ftSeq="1008" ftFieldset="Deprecated Properties" name="categorycachetimespan" type="numeric" default="0" hint="???" ftLabel="Category cache timespan" ftType="integer" />
	<cfproperty ftSeq="1009" ftFieldset="Deprecated Properties" name="contentreviewdayspan" type="numeric" default="90" hint="???" ftLabel="Content review day span" ftType="integer" />
	<cfproperty ftSeq="1010" ftFieldset="Deprecated Properties" name="exportpath" type="string" default="www/xml" hint="???" ftLabel="Export path" ftType="string" />
	<cfproperty ftSeq="1011" ftFieldset="Deprecated Properties" name="locale" type="string" default="en_AU" hint="???" ftLabel="Locale" ftType="string" />

	<cfproperty ftSeq="1012" ftFieldset="Deprecated Properties" name="defaultUserDirectory" type="string" default="" ftHint="Deprecated; new option is under Security Config" ftLabel="Default user directory" ftType="list" ftListData="listUserDirectories" />

	<!--- Deprecated --->	
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


</cfcomponent>