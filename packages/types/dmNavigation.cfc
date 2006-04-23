<cfcomponent name="dmNavigation" extends="types" displayname="Navigation" hint="Navigation nodes are combined with the ntm_navigation table to build the site layout model for the FarCry CMS system.">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty name="title" type="nstring" hint="Object title.  Same as Label, but required for overview tree render." required="no" default="">
<cfproperty name="aObjectIDs" type="array" hint="Holds objects to be displayed at this particular node.  Can be of mixed types." required="no" default=""> 
<cfproperty name="ExternalLink" type="string" hint="URL to an external (ie. off site) link." required="no" default="">
<cfproperty name="lNavIDAlias" type="string" hint="A Nav alias provides a human interpretable link to this navigation node.  Each Nav alias is set up as key in the structure application.navalias.<i>aliasname</i> with a value equal to the navigation node's UUID." required="no" default="">
<cfproperty name="options" type="string" hint="No idea what this is for." required="no" default="">
<cfproperty name="status" type="string" hint="Status of the node (draft, pending, approved)." required="yes" default="draft">

<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	
<cffunction name="edit" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_dmnavigation/edit.cfm">
</cffunction>

<cffunction name="getParent" access="public" returntype="query" output="false" hint="Returns the navigation parent of child (dmHTML page for example)">
	<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of element needing a parent">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	
	<cfquery name="qGetParent" datasource="#arguments.dsn#">
		SELECT objectid FROM #application.dbowner#dmNavigation_aObjectIDs
		WHERE data = '#arguments.objectid#'	
	</cfquery>
	
	<cfreturn qGetParent>
</cffunction>

<cffunction name="delete" access="public" hint="Specific delete method for dmNavigation. Removes all descendants">
	<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	
	<!--- get object details --->
	<cfset stObj = getData(arguments.objectid)>
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_dmnavigation/delete.cfm">
</cffunction>

<cffunction name="getNavAlias" access="public" hint="Return a structure of all the dmNavigation nodes with aliases." returntype="struct" output="false">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">

	<cfset var stResult = structNew()>
	<cfset var q = "">

	<!--- $TODO: all app vars should be passed in as arguments! 
	move application.dbowner (and others no doubt) GB$ --->
	<cfquery datasource="#arguments.dsn#" name="q">
		SELECT objectID, lNavIDAlias
		FROM #application.dbowner#dmNavigation
		WHERE lNavIDAlias <> ''
	</cfquery>

	<cfloop query="q">
		<cfscript>
			if(len(q.lNavIdAlias))
			{
				for( i=1; i le ListLen(q.lNavIdAlias); i=i+1 )
				{
					alias = Trim(ListGetAt(q.lNavIdAlias,i));
					if (NOT StructKeyExists(stResult, alias))
						stResult[alias] = q.objectID;
					else 
						stResult[alias] = ListAppend(stResult[alias], q.objectID);
				}
			}
		</cfscript>
	</cfloop>
	<cfreturn stResult>
</cffunction>

</cfcomponent>