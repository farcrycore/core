<cfcomponent displayname="General Configuration" hint="General configuration settings for the web application." extends="forms" output="false" key="general">

<!--- site description --->
	<cfproperty ftSeq="10" ftFieldset="Site Description" name="sitetitle" type="string" default="farcry" hint="???" ftLabel="Site title" ftType="string" />
	<cfproperty ftSeq="11" ftFieldset="Site Description" name="sitetagline" type="string" default="tell it to someone who cares" hint="???" ftLabel="Site tag line" ftType="string" />

<!--- webtop / login appearance --->
	<cfproperty name="webtopLogoPath" type="string" default="" 
		ftSeq="13" ftFieldset="Webtop / Login Appearance" ftLabel="Webtop Logo" 
		ftType="image" ftDestination="/wsimages"
		ftAutoGenerateType="fitinside" ftImageWidth="180" ftImageHeight="60"
		ftAllowUpload="true" ftbUploadOnly="true" ftQuality="1.0" ftInterpolation="blackman">
	<cfproperty name="webtopBackgroundPath" type="string" default="" 
		ftSeq="14" ftFieldset="Webtop / Login Appearance" ftLabel="Login Background" 
		ftType="image" ftDestination="/wsimages"
		ftAutoGenerateType="fitinside" ftImageWidth="1600" ftImageHeight="1600"
		ftAllowUpload="true" ftbUploadOnly="true" ftQuality="1.0" ftInterpolation="blackman"
		ftHint="Upload a large image that will fill the background of the login page">
	<cfproperty name="webtopBackgroundPosition" type="string" default="" 
		ftSeq="15" ftFieldset="Webtop / Login Appearance" ftLabel="Login Background Position" 
		ftType="list"
		ftList="left top,left center,left bottom,right top,right center,right bottom,center top,:center center,center bottom"
		ftHint="The CSS position of the login background image">
	<cfproperty name="bWebtopBackgroundMask" type="boolean" default="false" 
		ftSeq="16" ftFieldset="Webtop / Login Appearance" ftLabel="Login Background Mask"
		ftType="boolean"
		ftHint="Display a subtle texture that will mask the login background image (recommended for low resolution photos)">

<!--- 
 // contributor properites 
--------------------------------------------------------------------------------->
	<cfproperty ftSeq="20" ftFieldset="Editing Options" name="genericadminnumitems" type="numeric" default="25" hint="???" ftLabel="Content Admin Size" ftType="integer"
		fthint="Number of rows to show per page by default on content admin grids." />
	<!--- TODO: default locale should be the first locale nominated in the farcryconstructor --->
	<cfproperty ftSeq="20" ftFieldset="Editing Options" name="locale" type="string" default="en_AU" hint="???" ftLabel="Default Locale" ftType="string" 
		fthint="Nominate a default locale for the site."/>

<!--- sysadmin properties --->
	<cfproperty ftSeq="21" ftFieldset="SysAdmin Properties" name="adminemail" type="string" default="support@daemon.com.au" hint="The email address to be used by the system for admin functions" ftLabel="Administration email" ftType="email" />
	<cfproperty ftSeq="22" ftFieldset="SysAdmin Properties" name="adminserver" type="string" default="http://##cgi.HTTP_HOST##" ftDefaultType="expression" hint="???" ftLabel="Administration server" ftType="URL" />
	<cfproperty ftSeq="23" ftFieldset="SysAdmin Properties" name="bugemail" type="string" default="support@daemon.com.au" hint="???" ftLabel="Bug email" ftType="email" />
	<cfproperty ftSeq="24" ftFieldset="SysAdmin Properties" name="componentdocurl" type="numeric" default="/CFIDE/componentutils/componentdetail.cfm" hint="???" ftLabel="Component doc URL" ftType="string" />
	<cfproperty ftSeq="26" ftFieldset="SysAdmin Properties" name="bEmailErrors" type="boolean" default="0" ftLabel="Email errors" />
	<cfproperty ftSeq="27" ftFieldset="SysAdmin Properties" name="errorEmail" type="string" default="" ftLabel="Error email" ftType="email" />
	<cfproperty ftSeq="28" ftFieldset="SysAdmin Properties" name="emailWhitelist" type="longchar" ftLabel="Email Whitelist" ftHint="Emails sent through the email library are filtered by this list (leave empty for no filtering). Each LINE can be the full email domain (e.g. daemon.com.au), or a full email address (e.g. support@daemon.com.au).">
	<cfproperty ftSeq="29" ftFieldset="SysAdmin Properties" name="logDBChanges" type="longchar" ftLabel="Log DB Changes" ftHint="Flag specific types to say that all db changes should be logged" ftType="list" ftSelectMultiple="true" ftListData="listTypes" />


<!--- TODO: move to security config; update references --->
	<cfproperty ftSeq="33" ftFieldset="Login Properties" name="loginattemptsallowed" type="numeric" default="3" hint="???" ftLabel="Login attempts allowed" ftType="integer" />
	<cfproperty ftSeq="34" ftFieldset="Login Properties" name="loginattemptstimeout" type="numeric" default="10" hint="???" ftLabel="Login attempts timeout" ftType="integer" />


<!--- deprecated properties; backward compatability only --->
	<cfproperty name="sitelogopath" type="string" default="" hint="???" ftLabel="Logo path" ftType="string" />
	<cfproperty name="showforgotpassword" type="boolean" default="1" hint="???" ftLabel="Show forgot password" ftType="boolean" />
	<cfproperty name="sessiontimeout" type="numeric" default="60" hint="???" ftLabel="Session timeout" ftType="integer" />
	<cfproperty name="bdoarchive" type="boolean" default="0" hint="???" ftLabel="Do archives" ftType="boolean" />
	<cfproperty name="archivedirectory" type="string" default="##application.path.project##/archive/" ftDefaultType="expression" hint="???" ftLabel="Archive directory" ftType="string" />
	<cfproperty name="archiveweburl" type="string" default="##application.url.webroot##archive/" ftDefaultType="expression" hint="???" ftLabel="Archive web URL" ftType="string" />
	<cfproperty name="filedownloaddirectlink" type="boolean" default="0" hint="???" ftLabel="File download direct link" ftType="boolean" />
	<cfproperty name="filenameconflict" type="string" default="makeunique" hint="???" ftLabel="File name conflict" ftType="string" />
	<cfproperty name="teaserlimit" type="numeric" default="255" hint="???" ftLabel="Teaser limit" ftType="integer" />
	<cfproperty name="verityStoragePath" type="string" default="" ftdefault="##Replace('##server.coldfusion.rootdir##/verity/collections/','\','/','All')##" ftDefaultType="evaluate" hint="???"  ftLabel="Verity storage path" />
	<cfproperty name="newsexpiry" type="numeric" default="12" hint="???" ftLabel="News expiry" ftType="integer" />
	<cfproperty name="newsexpirytype" type="string" default="d" hint="???" ftLabel="News expiry type" ftType="string" />
	<cfproperty name="eventsexpiry" type="numeric" default="14" hint="???" ftLabel="Event expiry" ftType="integer" />
	<cfproperty name="eventsexpirytype" type="string" default="d" hint="???" ftLabel="Event expiry type" ftType="string" />

	<cfproperty name="dmfilessearchable" type="boolean" default="1" hint="???" ftLabel="Files searchable" ftType="boolean" />
	<cfproperty name="logstats" type="boolean" default="1" hint="???" ftLabel="Log stats" ftType="boolean" />

	<cfproperty name="categorycachetimespan" type="numeric" default="0" hint="???" ftLabel="Category cache timespan" ftType="integer" />
	<cfproperty name="contentreviewdayspan" type="numeric" default="90" hint="???" ftLabel="Content review day span" ftType="integer" />
	<cfproperty name="exportpath" type="string" default="www/xml" hint="???" ftLabel="Export path" ftType="string" />
	

	<cfproperty name="defaultUserDirectory" type="string" default="" ftHint="Deprecated; new option is under Security Config" ftLabel="Default user directory" ftType="string" />


<!--- 
 // supporting list functions 
--------------------------------------------------------------------------------->
	<cffunction name="listTypes" access="public" returntype="query" description="Returns the types in this application" output="false">
		<cfset var qResult = querynew("value,name,order","varchar,varchar,integer") />
		<cfset var k = "" />
		
		<cfset queryaddrow(qResult) />
		<cfset querysetcell(qResult,"value","") />
		<cfset querysetcell(qResult,"name","None") />
		<cfset querysetcell(qResult,"order",0) />
		
		<cfloop collection="#application.stCOAPI#" item="k">
			<cfif application.stCOAPI[k].class eq "type" and structkeyexists(application.stCOAPI[k],"displayname")>
				<cfset queryaddrow(qResult) />
				<cfset querysetcell(qResult,"value",k) />
				<cfset querysetcell(qResult,"name",application.stCOAPI[k].displayname) />
				<cfset querysetcell(qResult,"order",1) />
			</cfif>
		</cfloop>
		
		<cfquery dbtype="query" name="qResult">select * from qResult order by [order],[name]</cfquery>
		
		<cfreturn qResult />
	</cffunction>
	

<!--- 
 // process form 
--------------------------------------------------------------------------------->
	<cffunction name="process" access="public" output="false" returntype="struct">
		<cfargument name="fields" type="struct" required="true" />
		
		<cfset application.fc.lib.db.setLogChangeFlags(arguments.fields.logDBChanges) />
		
		<cfreturn arguments.fields />
	</cffunction>
		

</cfcomponent>