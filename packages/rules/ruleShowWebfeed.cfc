<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@displayname: Utility: Show Defined Webfeed  --->
<cfcomponent displayname="Show Web Feed" output="false" 
	extends="farcry.core.packages.rules.rules" hint="">

	<!--- properties --->
	<cfproperty name="aWebDisplayFeeds" type="array" hint="The Webfeed to add to this page" 
		ftSeq="1" ftLabel="Web Feeds" ftJoin="farWebfeed" />
	
	<!--- methods --->
	
</cfcomponent>