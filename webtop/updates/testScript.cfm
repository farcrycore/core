<cfsetting requestTimeOut="500">

<cffunction name="setPage">
	<cfargument name="title" required="yes" type="string">
	<cfscript>
		// set up page
		stHTML = structNew();
		stHTML.aObjectIDs = arrayNew(1);
		stHTML.aRelatedIDs = arrayNew(1);
		stHTML.aTeaserImageIDs = arrayNew(1);
		stHTML.body = '<p>blah blah blah</p>';
		stHTML.commentLog = '';
		stHTML.createdBy = 'farcry';
		stHTML.datetimeCreated = now();
		stHTML.datetimeLastUpdated = now();
		stHTML.displayMethod = 'displaypageLanding';
		stHTML.label = arguments.title;
		stHTML.lastUpdatedBy = 'farcry';
		stHTML.metaKeywords = '';
		stHTML.objectID = application.fc.utils.createJavaUUID();
		stHTML.status = 'approved';
		stHTML.teaser = '<p>Teaser teaser teaser</p>';
		stHTML.title = arguments.title;
		stHTML.typeName = 'dmHTML';
		stHTML.versionID = '';
	</cfscript>
	
	<cfreturn stHTML>
</cffunction>

<cffunction name="setNode">
	<cfargument name="title" required="yes" type="string">
	<cfargument name="child" required="yes" type="UUID">
	<cfscript>
		stHomeNode = structNew();
		stHomeNode.objectID = application.fc.utils.createJavaUUID();
		stHomeNode.aObjectIDs = arrayNew(1);
		stHomeNode.aObjectIDs[1] = arguments.child;
		stHomeNode.status = 'approved';
		stHomeNode.ExternalLink = '';
		stHomeNode.target = '';
		stHomeNode.options = '';
		stHomeNode.lNavIDAlias = '';
		stHomeNode.title = arguments.title;
		stHomeNode.createdBy = 'farcry';
		stHomeNode.label = arguments.title;
		stHomeNode.datetimecreated = now();
		stHomeNode.datetimelastupdated = now();
		stHomeNode.lastupdatedby = 'farcry';
	</cfscript>
	
	<cfreturn stHomeNode>
</cffunction>

<cffunction name="createBranch">
	<cfargument name="level" required="yes" type="numeric">
	<cfargument name="parent" required="yes" type="uuid">
	<cfset var numNodes = "">
	<cfset var i = "">
	
	<cfscript>
		numNodes = randRange(2,5);
		
		// loop over nodes
		for (i = 1; i LTE numNodes; i = i + 1) {
		
			stHTML = setPage("#arguments.level#_#i#");
			
			// create page
			oHTML.createData(stProperties=stHTML);
			
			// define default navigation nodes	
			stNode = setNode(title="#arguments.level#_#i#",child=stHTML.objectid);
			
			// create node
			o_dmNav.createData(dsn=application.dsn,stProperties=stNode,bAudit=false);
			
			// attach node
			o_farCryTree.setYoungest(dsn=application.dsn,parentID=arguments.parent,objectID=stNode.objectID,objectName=stNode.title,typeName='dmNavigation');
			
			if (arguments.level lt 5) {
				createBranch(level=arguments.level+1,node=i,parent=stNode.objectid);
			}
		}
	</cfscript>
</cffunction>

<cfscript>
	oHTML = createobject("component","#application.packagepath#.types.dmHTML");
	o_dmNav = createObject("component", "#application.packagepath#.types.dmNavigation");
	o_farcrytree = createObject("component", "#application.packagepath#.farcry.tree");
	
	createBranch(level=1,parent=application.navid.home);
</cfscript>