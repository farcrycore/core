<cfcomponent displayname="General config" hint="General cofiguration settings" extends="forms" output="false" key="general">
	<cfproperty name="adminemail" type="string" default="support@daemon.com.au" hint="The email address to be used by the system for admin functions" ftSeq="1" ftFieldset="" ftLabel="Administration email" ftType="email" />
	<cfproperty name="adminserver" type="string" default="http://##cgi.HTTP_HOST##" ftDefaultType="expression" hint="???" ftSeq="2" ftFieldset="" ftLabel="Administration server" ftType="URL" />
	<cfproperty name="archivedirectory" type="string" default="##application.path.project##/archive/" ftDefaultType="expression" hint="???" ftSeq="3" ftFieldset="" ftLabel="Archive directory" ftType="string" />
	<cfproperty name="archiveweburl" type="string" default="##application.url.webroot##archive/" ftDefaultType="expression" hint="???" ftSeq="4" ftFieldset="" ftLabel="Archive web URL" ftType="string" />
	<cfproperty name="bdoarchive" type="boolean" default="0" hint="???" ftSeq="5" ftFieldset="" ftLabel="Do archives" ftType="boolean" />
	<cfproperty name="bugemail" type="boolean" default="farcry@daemon.com.au" hint="???" ftSeq="6" ftFieldset="" ftLabel="Bug email" ftType="boolean" />
	<cfproperty name="categorycachetimespan" type="numeric" default="0" hint="???" ftSeq="7" ftFieldset="" ftLabel="Category cache timespan" ftType="integer" />
	<cfproperty name="componentdocurl" type="numeric" default="/CFIDE/componentutils/componentdetail.cfm" hint="???" ftSeq="8" ftFieldset="" ftLabel="Component doc URL" ftType="string" />
	<cfproperty name="contentreviewdayspan" type="numeric" default="90" hint="???" ftSeq="9" ftFieldset="" ftLabel="Content review day span" ftType="integer" />
	<cfproperty name="dmfilessearchable" type="boolean" default="1" hint="???" ftSeq="10" ftFieldset="" ftLabel="Files searchable" ftType="boolean" />
	<cfproperty name="eventsexpiry" type="numeric" default="14" hint="???" ftSeq="11" ftFieldset="" ftLabel="Event expiry" ftType="integer" />
  	<cfproperty name="eventsexpirytype" type="string" default="d" hint="???" ftSeq="12" ftFieldset="" ftLabel="Event expiry type" ftType="string" />
  	<cfproperty name="exportpath" type="string" default="www/xml" hint="???" ftSeq="13" ftFieldset="" ftLabel="Export path" ftType="string" />
  	<cfproperty name="filedownloaddirectlink" type="boolean" default="0" hint="???" ftSeq="14" ftFieldset="" ftLabel="File download direct link" ftType="boolean" />
  	<cfproperty name="filenameconflict" type="string" default="makeunique" hint="???" ftSeq="15" ftFieldset="" ftLabel="File name conflict" ftType="string" />
  	<cfproperty name="genericadminnumitems" type="numeric" default="15" hint="???" ftSeq="16" ftFieldset="" ftLabel="Generic admin number of items" ftType="integer" />
  	<cfproperty name="locale" type="string" default="en_AU" hint="???" ftSeq="17" ftFieldset="" ftLabel="Locale" ftType="string" />
  	<cfproperty name="loginattemptsallowed" type="numeric" default="3" hint="???" ftSeq="18" ftFieldset="" ftLabel="Login attempts allowed" ftType="integer" />
  	<cfproperty name="loginattemptstimeout" type="numeric" default="10" hint="???" ftSeq="19" ftFieldset="" ftLabel="Login attempts timeout" ftType="integer" />
  	<cfproperty name="logstats" type="boolean" default="1" hint="???" ftSeq="20" ftFieldset="" ftLabel="Log stats" ftType="boolean" />
  	<cfproperty name="newsexpiry" type="numeric" default="12" hint="???" ftSeq="21" ftFieldset="" ftLabel="News expiry" ftType="integer" />
  	<cfproperty name="newsexpirytype" type="string" default="d" hint="???" ftSeq="22" ftFieldset="" ftLabel="News expiry type" ftType="string" />
  	<cfproperty name="sessiontimeout" type="numeric" default="60" hint="???" ftSeq="23" ftFieldset="" ftLabel="Session timeout" ftType="integer" />
  	<cfproperty name="showforgotpassword" type="boolean" default="1" hint="???" ftSeq="24" ftFieldset="" ftLabel="Show forgot password" ftType="boolean" />
  	<cfproperty name="sitelogopath" type="string" default="" hint="???" ftSeq="25" ftFieldset="" ftLabel="Logo path" ftType="string" />
  	<cfproperty name="sitetagline" type="string" default="tell it to someone who cares" hint="???" ftSeq="26" ftFieldset="" ftLabel="Site tag line" ftType="string" />
  	<cfproperty name="sitetitle" type="string" default="farcry" hint="???" ftSeq="27" ftFieldset="" ftLabel="Site title" ftType="string" />
  	<cfproperty name="teaserlimit" type="numeric" default="255" hint="???" ftSeq="28" ftFieldset="" ftLabel="Teaser limit" ftType="integer" />
	<cfproperty name="verityStoragePath" type="string" default="##Replace('##server.coldfusion.rootdir##/verity/collections/','\','/','All')##" ftDefaultType="evaluate" hint="???" ftSeq="29" ftFieldset="" ftLabel="Verity storage path" ftType="string" />

</cfcomponent>