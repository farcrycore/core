<!--- 
dmNavigation Type
 ---> 


<cfcomponent name="dmNavigation" extends="types" displayname="Navigation Tree Nodes" hint="Navigation nodes are combined with the ntm_navigation table to build the site layout model for the FarCry CMS system.">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty name="title" type="string" hint="Object title.  Same as Label, but required for overview tree render." required="no" default="(unspecified)">
<cfproperty name="aObjectIDs" type="array" hint="Holds objects to be displayed at this particular node.  Can be of mixed types." required="no" default=""> 
<cfproperty name="ExternalLink" type="string" hint="URL to an external (ie. off site) link." required="no" default="">
<cfproperty name="target" type="string" hint="Target for the anchor tag that fires when the navigation node is an external link." required="no" default="">
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
	<cfinclude template="_dmNavigation/edit.cfm">
</cffunction>

</cfcomponent>

