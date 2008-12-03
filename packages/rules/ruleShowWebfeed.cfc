<!--- @@Copyright: Copyright (c) 2008 Rob Rohan. All rights reserved. --->
<!--- @@displayname: Utility: Show Defined Webfeed  --->
<!--- @@description: Utility: Show Defined Webfeed --->
<cfcomponent displayname="ruleShowWebfeed" output="false" 
	extends="farcry.core.packages.rules.rules" hint="">

	<!--- properties --->
	<cfproperty name="aWebDisplayFeeds" type="array" hint="The Webfeed to add to this page" 
		ftSeq="1" ftLabel="Web Feeds" ftJoin="farWebfeed" />
	
	<!--- methods --->
	
</cfcomponent>