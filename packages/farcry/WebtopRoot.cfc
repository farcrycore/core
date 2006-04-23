<!--- {{{ jEdit Modes
:mode=coldfusion:
:collapseFolds=1:
:noTabs=true:
:tabSize=4:
:indentSize=4:
}}} --->
<!--- {{{
|| LEGAL ||
$Copyright: (C) 2005 The University of Texas at Austin, http://www.utexas.edu $
$License: Released Under the "Common Public License 1.0", http://www.opensource.com/licenses/cpl.php$

|| DESCRIPTION ||
$Description: Represents a webtop configuration, can merge with other webtop roots, and translate to and from xml. $

|| DEVELOPER ||
$Developer: Tyler Ham (tylerh@austin.utexas.edu)$
}}} --->

<cfcomponent displayname="Webtop Root"
  hint="Represents a webtop configuration, can merge with other webtop roots,
  and translate to and from xml.">
  
  <!--- about mergeType:
  webtop, section, subsection, menu, and menuitem are all nodes.
  The node being merged into/onto is referred to as node1.
  The node being merged is referred to as node2.
  
  If node1 has mergeType="none", 
    replaces and appends to node1 are not allowed.
  
  Otherwise, node1's mergeType is irrelevant.
  
  
  *** Possible mergeType's ***
    * replace
    * merge
    * mergeNoReplace
    * none
  
  
  *** Node2 Merge Types ***
    * replace
      - the entire node1 is trashed in favor of node2, as it is
    * merge
      - node1 takes on attributes/values of node2
      - if duplicate attributes exist, node2's values are used
      - children are merged normally (see below)
    * mergeNoReplace
      - node1 takes on attributes/values of node2
      - if duplicate attributes exist, node1's values are used
      - children are merged normally (see below)
    * none
      - if node2 has 'none' as the merge type, the
        default mergeType for the node is used
  
  
  *** Normal Children Merge ***
    - start with node1 children
    - for each child of node2:
       - if a node with a matching 'id' attribute value exists in node1:
          * merge the two children (recurse these comments with these two
            child nodes as node1 and node2)
       - otherwise, add the child of node2 to the list of children of node1
  
  
  *** Default mergeTypes ***
    * NODE          MERGETYPE
    ----------------------------
    * webtop        merge
    * section       merge
    * subsection    merge
    * menu          merge
    * menuitem      merge
    
  
  --->
  
  <cfset this.isInitialized = "false">
  <cfset this.stAttributes = StructNew()>
  <cfset this.aSections = ArrayNew(1)>
  
  <!--- default mergeType of a webtop is 'merge' --->
  <!--- other possible values: 'mergeNoReplace', 'replace', 'none' --->
  <!--- see above for more info on mergeTypes --->
  <cfset this.stAttributes.mergeType = "merge">
  
<!--- {{{ PUBLIC functions --->

<!--- {{{ public setPolicyGroup(policyGroupID) --->
<cffunction name="setPolicyGroup" access="public" output="no"
  hint="sets isAllowed attributes on each node if it allows access
  to the specified policy group">
  
  <cfargument name="policyGroupID" type="numeric" required="yes"
    hint="ID of the policy group to mark allowed nodes for">
  
  <cfargument name="overrideAllowed" type="boolean" default="false"
    hint="if true, a parent node that is disallowed will cause all children
    nodes to be disallowed, regardless of the permissions">
  
  <cfset var checkPermission = "">
  <cfset var i = "">
  
  <!--- first, get permissions - we'll need to pass them down the chain --->
  <cfset var permissions = getPermissions()>
  
  <!--- set isAllowed for the root node --->
  <cfif StructKeyExists(this.stAttributes, "permission")>
    <!--- check that any required permission on this node is allowed by the policy group --->
    <cfquery name="checkPermission" dbtype="query">
      SELECT *
      FROM permissions
      WHERE PolicyGroupID = <cfqueryparam value="#arguments.policyGroupID#" cfsqltype="cf_sql_numeric">
        AND PermissionName = <cfqueryparam value="#this.stAttributes.permission#" cfsqltype="cf_sql_varchar">
        AND Allowed = 1
    </cfquery>
    
    <cfif checkPermission.RecordCount>
      <cfset this.stAttributes.isAllowed = "true">
    <cfelse>
      <cfset this.stAttributes.isAllowed = "false">
    </cfif>
    
  <cfelse>
    <cfset this.stAttributes.isAllowed = "true">  <!--- allow by default --->
    
  </cfif>
  
  <!--- set policy group on children --->
  <cfloop index="i" from="1" to="#ArrayLen(this.aSections)#">
    <cfset this.aSections[i].setPolicyGroup(arguments.policyGroupID, permissions, arguments.overrideAllowed, this.stAttributes.isAllowed)>
  </cfloop>
  
</cffunction>
<!--- }}} public setPolicyGroup(policyGroupID) --->

<!--- {{{ public transformLabels() --->
<cffunction name="transformLabels" access="public" output="no"
  hint="transforms the label attributes (if any) of nodes
  depending on the labelType attribute (evaluate, expression, text)">
  
  <cfset var i = "">
  
  <!--- transform labels on children --->
  <cfloop index="i" from="1" to="#ArrayLen(this.aSections)#">
    <cfset this.aSections[i].transformLabels()>
  </cfloop>
  
</cffunction>
<!--- }}} public transformLabels() --->

<!--- {{{ public init(WebtopXmlDoc) --->
<cffunction name="init" access="public" output="no" returnType="WebtopRoot"
  hint="initializes this WebtopRoot with data from the given XmlDoc from a webtop xml file.">
  
  <cfargument name="WebtopXmlDoc" required="true"
    hint="webtop XmlDoc">
  
  <cfset var root = "">
  
  <!--- if anything is bad, simply return this --->
  <!--- isInitialized is still false, so getXml will --->
  <!--- just return empty string --->
  
  <!--- make sure the argument is an xml doc --->
  <cfif not isXmlDoc(arguments.WebtopXmlDoc)>
    <cfreturn this>
  </cfif>
  
  <!--- get Xmlroot --->
  <cfset root = arguments.WebtopXmlDoc.XmlRoot>
  
  <!--- make sure XmlName is 'webtop' --->
  <cfif not root.XmlName is "webtop">
    <cfreturn this>
  </cfif>
  
  <!--- ok, everything SEEMS ok, lets get the attributes --->
  <cfloop index="attrib" list="#StructKeyList(root.XmlAttributes)#">
    <cfset this.stAttributes[attrib] = root.XmlAttributes[attrib]>
  </cfloop>
  
  <!--- get the xml children --->
  <cfloop index="i" from="1" to="#ArrayLen(root.XmlChildren)#">
    <cfinvoke component="WebtopSection" method="init" returnVariable="newChild">
      <cfinvokeargument name="SectionXmlElement" value="#root.XmlChildren[i]#">
    </cfinvoke>
    <cfset ArrayAppend(this.aSections, newChild)>
  </cfloop>
  
  <!--- we are officially initialized, now getXml will work --->
  <cfset this.isInitialized = "true">
  
  <cfreturn this>
</cffunction>
<!--- }}} public init(WebtopXmlDoc) --->


<!--- {{{ public getXml() --->
<cffunction name="getXml" access="public" output="no" returnType="string"
  hint="returns xml of this webtop element as a string">
  
  <cfset var sOutput = "">
  <cfset var i = "">
  
  <!--- if we were not initialized with a proper WebtopXmlDoc, --->
  <!--- just return empty string --->
  <!--- this ought to do the least amount of harm --->
  <cfif not this.isInitialized>
    <cfreturn sOutput>
  </cfif>
  
  <!--- this call takes the struct and returns a string that looks like --->
  <!--- 'key="value" key="value" ...' --->
  <cfset sOutput = toAttributeString(this.stAttributes)>
  <cfset sOutput = "<webtop " & sOutput & " >">
  
  <!--- add the children --->
  <cfloop index="i" from="1" to="#ArrayLen(this.aSections)#">
    <cfset sOutput = sOutput & " " & this.aSections[i].getXml()>
  </cfloop>
  
  <!--- add the close tag --->
  <cfset sOutput = sOutput & " </webtop>">
  
  <cfreturn sOutput>
</cffunction>
<!--- }}} public getXml() --->


<!--- {{{ public mergeRoot(WebtopRoot root2) --->
<cffunction name="mergeRoot" access="public" output="no" returnType="void"
  hint="merges the given root2 onto this root, following any specified
  mergeType rules.  See WebtopRoot.cfc for more information about mergeType.
  Assuming root1 and root2 match.">
  
  <cfargument name="root2" type="WebtopRoot" required="true"
    hint="root to merge into this one">
  
  <!--- comment note: root1 means THIS --->
  
  <!--- if mergeType='none' on root1, it cannot be replaced or merged --->
  <cfif this.stAttributes.mergeType is "none">
    <cfreturn>
  </cfif>
  
  <cfswitch expression="#arguments.root2.stAttributes.mergeType#">
    <cfcase value="replace">
      <!--- replace ALL data about root1 with that of root2 --->
      <!--- ?? should we maintain the same mergeType, though?? -TH --->
      <cfset this.stAttributes = arguments.root2.stAttributes>
      <cfset this.aSections = arguments.root2.aSections>
    </cfcase>
    
    <cfcase value="merge">
      <!--- append root2.stAttributes to root1.stAttributes --->
      <!--- replace if duplicate keys --->
      <!--- normal merge/replace operation on children --->
      <cfset StructAppend(this.stAttributes, arguments.root2.stAttributes, "yes")>
      <cfset mergeChildren(arguments.root2)>
    </cfcase>
    
    <cfcase value="mergeNoReplace">
      <!--- append root2.stAttributes to root1.stAttributes --->
      <!--- do not replace duplicate keys --->
      <!--- normal merge/replace operation on children --->
      <cfset StructAppend(this.stAttributes, arguments.root2.stAttributes, "no")>
      <cfset mergeChildren(arguments.root2)>
    </cfcase>
    
    <cfdefaultcase> <!--- this will catch "none" values --->
      <!--- what should we do with strange mergeTypes? or "none"s? --->
      <!--- (remember, root1.id = root2.id - we assume this in here) --->
      <!--- How about "merge" as default for sections? -TH --->
      <cfset StructAppend(this.stAttributes, arguments.root2.stAttributes, "yes")>
      <cfset mergeChildren(arguments.root2)>
    </cfdefaultcase>
  </cfswitch>
  
</cffunction>
<!--- }}} public mergeRoot(WebtopRoot root2) --->


<!--- {{{ public getXmlDoc() --->
<cffunction name="getXmlDoc" access="public" output="no"
  hint="returns xmlDoc of this webtop's xml. 
  Convenience function, just parses getXml().">
  
  <cfreturn XmlParse(getXml())>
</cffunction>
<!--- }}} public getXmlDoc() --->



<!--- {{{ public toAttributeString(Struct stAttributes) --->
<cffunction name="toAttributeString" access="public" output="no" returnType="string"
  hint="converts a struct into a space-separated string of key/value pairs like
  'key=""value"" key=""value"" ...'">
  
  <cfargument name="stAttributes" type="Struct" required="true"
    hint="struct to convert to a string">
  
  <cfset var sOutput = "">
  <cfset var attrib = "">
  
  <cfloop index="attrib" list="#StructKeyList(arguments.stAttributes)#">
    <!--- XmlFormat makes the following characters safe for use in xml: 
          * Greater than symbol ( > )
          * Less than symbol ( < )
          * Single quotation mark ( ' )
          * Double quotation mark ( " )
          * Ambersand symbol ( & ) --->
    <cfset sOutput = sOutput & attrib & "=""" & XmlFormat(arguments.stAttributes[attrib]) & """ ">
  </cfloop>
  
  <!--- we might have ended up with a trailing space, remove it --->
  <cfif Right(sOutput, 1) is " ">
    <cfset sOutput = Left(sOutput, Len(sOutput)-1)>
  </cfif>
  
  <cfreturn sOutput>
</cffunction>
<!--- }}} public toAttributeString(Struct stAttribs) --->

<!--- }}} PUBLIC functions --->



<!--- {{{ PRIVATE functions --->

<!--- {{{ private mergeChildren(WebtopRoot root2) --->
<cffunction name="mergeChildren" access="private" output="no" returnType="void"
  hint="merges the children of root2 into the children of this root,
  following any specified mergeType rules.  See WebtopRoot.cfc for more information
  about mergeType.">
  
  <cfargument name="root2" type="WebtopRoot" required="true"
    hint="root whose children to merge with this one">
  
  <cfset var i = "">
  
  <!--- comment note: root1 means THIS --->
  
  <!--- loop through and merge each child (passing the buck again!) --->
  <cfloop index="i" from="1" to="#ArrayLen(arguments.root2.aSections)#">
    <cfset mergeChild(arguments.root2.aSections[i])>
  </cfloop>
  
</cffunction>
<!--- }}} private mergeChildren(WebtopRoot root2) --->


<!--- {{{ private mergeChild(WebtopSection child) --->
<cffunction name="mergeChild" access="private" output="no" returnType="void"
  hint="merges the child into aSections">
  
  <cfargument name="child" type="WebtopSection" required="true"
    hint="section to merge into this root's children">
  
  <cfset var i = "">
  <cfset var matchFound = "false">
  
  <!--- we must have an id to match, otherwise, no point in looking --->
  <cfif StructKeyExists(arguments.child.stAttributes, "id")>
    <!--- does the same child exist in this menu? --->
    <!--- ID will match, if so --->
    <cfloop index="i" from="1" to="#ArrayLen(this.aSections)#">
      <!--- id attribute must be present and must match --->
      <cfif StructKeyExists(this.aSections[i].stAttributes, "id")
        and this.aSections[i].stAttributes.id is arguments.child.stAttributes.id>
        
        <!--- set matchFound=true so we don't append the child later --->
        <cfset matchFound = "true">
        
        <!--- they match, so merge them --->
        <cfset this.aSections[i].mergeSection(arguments.child)>
        
        <!--- no need to keep looping --->
        <cfbreak>
      </cfif>
    </cfloop>
    
  </cfif>
  
  <cfif not matchFound>
    <!--- a match was not found, so we should append the menuitem --->
    <cfset ArrayAppend(this.aSections, arguments.child)>
  </cfif>
  
</cffunction>
<!--- }}} private mergeChild(WebtopSection child) --->


<!--- {{{ private getPermissions() --->
<cffunction name="getPermissions" access="private" output="no" returnType="query"
  hint="returns a query mapping policy groups and their permissions"
  hintReturnQuery="PolicyGroupID,PolicyGroupName,PermissionID,PermissionName,Allowed">
  
  <cfset var qReturn = QueryNew("PolicyGroupID,PolicyGroupName,PermissionID,PermissionName,Allowed")>
  <cfset var oAuthorisation = request.dmSec.oAuthorisation>
  <cfset var stObjectPermissions = oAuthorisation.getObjectPermission(reference="policyGroup",bUseCache=0)>
  <cfset var policyGroupID = "">
  <cfset var permissionID = "">
  <cfset var pg = "">
  <cfset var perm = "">
  <cfset var allowed = 1>
  
  <cfloop index="policyGroupID" list="#StructKeyList(stObjectPermissions)#">
    <cfset pg = oAuthorisation.getPolicyGroup(policyGroupID=policyGroupID)>
    
    <cfloop index="permissionID" list="#StructKeyList(stObjectPermissions[policyGroupID])#">
      <cfset perm = oAuthorisation.getPermission(permissionID=permissionID)>
      <cfset allowed = 1>
      <cfif stObjectPermissions[policyGroupID][permissionID].a eq -1
         or stObjectPermissions[policyGroupID][permissionID].a eq 0>
        <cfset allowed = 0>
      </cfif>
      
      <cfset QueryAddRow(qReturn)>
      <cfset QuerySetCell(qReturn, "PolicyGroupID", policyGroupID)>
      <cfset QuerySetCell(qReturn, "PolicyGroupName", pg.PolicyGroupName)>
      <cfset QuerySetCell(qReturn, "PermissionID", permissionID)>
      <cfset QuerySetCell(qReturn, "PermissionName", perm.PermissionName)>
      <cfset QuerySetCell(qReturn, "Allowed", allowed)>
    </cfloop>
    
  </cfloop>
  
  <cfreturn qReturn>
</cffunction>
<!--- }}} private getPermissions() --->

<!--- }}} PRIVATE functions --->


</cfcomponent>
