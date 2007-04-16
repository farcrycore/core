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

<cfcomponent displayname="Webtop Menu"
  hint="Represents a webtop menu, can merge with another menu,
  and translate to and from xml.">
  
  <!--- this is the name of the xml attribute used to order items --->
  <cfset this.orderAttrib = "sequence">
  
  <cfset this.isInitialized = "false">
  <cfset this.stAttributes = StructNew()>
  <cfset this.aMenuitems = ArrayNew(1)>
  
  <!--- default mergeType of a menu is 'merge' --->
  <!--- other possible values: 'mergeNoReplace', 'replace', 'none' --->
  <!--- see WebtopRoot.cfc for more info on mergeTypes --->
  <cfset this.stAttributes.mergeType = "merge">
  
  <!--- TODO: set default order attribute --->
  <cfset this.stAttributes[this.orderAttrib] = "500000">
  
<!--- {{{ PACKAGE functions --->

<!--- {{{ package setPolicyGroup(policyGroupID, qPermissions) --->
<cffunction name="setPolicyGroup" access="package" output="no"
  hint="sets isAllowed attributes on each node if it allows access
  to the specified policy group">
  
  <cfargument name="policyGroupID" type="numeric" required="yes"
    hint="ID of the policy group to mark allowed nodes for">
  
  <cfargument name="qPermissions" type="query" required="yes"
    hint="permission map query">
  
  <cfargument name="overrideAllowed" type="boolean" required="yes"
    hint="if true, a parent node that is disallowed will cause all children
    nodes to be disallwoed, regardless of the permissions">
  
  <cfargument name="parentIsAllowed" type="boolean" required="yes"
    hint="indicates if the parent permission is allowed">
  
  <cfset var checkPermission = "">
  <cfset var i = "">
  
  <!--- first, get permissions - we'll need to pass them down the chain --->
  <cfset var permissions = arguments.qPermissions>
  
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
  
  <!--- override isAllowed if necessary --->
  <cfif this.stAttributes.isAllowed
    and arguments.overrideAllowed 
    and (not arguments.parentIsAllowed)>
    <cfset this.stAttributes.isAllowed = "false">
  </cfif>
  
  <!--- set policy group on children --->
  <cfloop index="i" from="1" to="#ArrayLen(this.aMenuitems)#">
    <cfset this.aMenuitems[i].setPolicyGroup(arguments.policyGroupID, permissions, arguments.overrideAllowed, this.stAttributes.isAllowed)>
  </cfloop>
  
</cffunction>
<!--- }}} package setPolicyGroup(policyGroupID, qPermissions) --->

<!--- {{{ package transformLabels() --->
<cffunction name="transformLabels" access="package" output="no"
  hint="transforms the label attributes (if any) of nodes
  depending on the labelType attribute (evaluate, expression, text)">
  
  <cfset var i = "">
  
  <cfset this.stAttributes.transformedLabel = "">
  
  <cfif StructKeyExists(this.stAttributes, "label")>
    <cfset this.stAttributes.transformedLabel = this.stAttributes.label>
  </cfif>
  
  <cfif StructKeyExists(this.stAttributes, "labelType")>
    <cftry>
      <cfswitch expression="#this.stAttributes.labelType#">
        <cfcase value="evaluate">
          <cfset this.stAttributes.transformedLabel = Evaluate(this.stAttributes.label)>
        </cfcase>
        
        <cfcase value="expression">
          <cfset this.stAttributes.transformedLabel = Evaluate(this.stAttributes.label)>
        </cfcase>
        
        <cfcase value="text">
          <!--- let transformedLabel just equal label (it already does) --->
        </cfcase>
        
        <cfdefaultcase>
          <!--- let transformedLabel just equal label (it already does) --->
        </cfdefaultcase>
      </cfswitch>
      
      <cfcatch>
        <cfset this.stAttributes.transformedLabel = "*** #this.stAttributes.label# ***">
      </cfcatch>
    </cftry>
  </cfif>
  
  <!--- transform labels on children --->
  <cfloop index="i" from="1" to="#ArrayLen(this.aMenuitems)#">
    <cfset this.aMenuitems[i].transformLabels()>
  </cfloop>
  
</cffunction>
<!--- }}} package transformLabels() --->

<!--- {{{ package init(MenuXmlElement) --->
<cffunction name="init" access="package" output="no" returnType="WebtopMenu"
  hint="initializes this WebtopMenu with data from the given menu XmlElement
  from a webtop xml file.">
  
  <cfargument name="MenuXmlElement" required="true"
    hint="webtop menu XmlElement">
  
  <cfset var i = "">
  <cfset var attrib = "">
  <cfset var newChild = "">
  
  <!--- if anything is bad, simply return this --->
  <!--- isInitialized is still false, so getXml will --->
  <!--- just return empty string --->
  
  <!--- make sure the argument is an xml element --->
  <cfif not isXmlElem(arguments.MenuXmlElement)>
    <cfreturn this>
  </cfif>
  
  <!--- make sure XmlName is 'menu' --->
  <cfif not arguments.MenuXmlElement.XmlName is "menu">
    <cfreturn this>
  </cfif>
  
  <!--- ok, everything SEEMS ok, lets get the attributes --->
  <cfloop index="attrib" list="#StructKeyList(arguments.MenuXmlElement.XmlAttributes)#">
    <cfset this.stAttributes[attrib] = arguments.MenuXmlElement.XmlAttributes[attrib]>
  </cfloop>
  
  <!--- get the xml children --->
  <cfloop index="i" from="1" to="#ArrayLen(arguments.MenuXmlElement.XmlChildren)#">
    <cfinvoke component="WebtopMenuitem" method="init" returnVariable="newChild">
      <cfinvokeargument name="MenuitemXmlElement" value="#arguments.MenuXmlElement.XmlChildren[i]#">
    </cfinvoke>
    
    <cfset insertChildWithOrder(newChild)>
  </cfloop>
  
  <!--- we are officially initialized, now getXml will work --->
  <cfset this.isInitialized = "true">
  
  <cfreturn this>
</cffunction>
<!--- }}} package init(MenuXmlElement) --->



<!--- {{{ package mergeMenu(WebtopMenu menu2) --->
<cffunction name="mergeMenu" access="package" output="no" returnType="void"
  hint="merges the given menu2 onto this menu, following any specified
  mergeType rules.  See WebtopRoot.cfc for more information about mergeType.
  Assuming menu1 and menu2 match (have same id).">
  
  <cfargument name="menu2" type="WebtopMenu" required="true"
    hint="menu to merge into this one">
  
  <!--- comment note: menu1 means THIS --->
  
  <!--- if mergeType='none' on menu1, it cannot be replaced or merged --->
  <cfif this.stAttributes.mergeType is "none">
    <cfreturn>
  </cfif>
  
  <cfswitch expression="#arguments.menu2.stAttributes.mergeType#">
    <cfcase value="replace">
      <!--- replace ALL data about menu1 with that of menu2 --->
      <!--- ?? should we maintain the same mergeType, though?? -TH --->
      <cfset this.stAttributes = arguments.menu2.stAttributes>
      <cfset this.aMenuitems = arguments.menu2.aMenuitems>
    </cfcase>
    
    <cfcase value="merge">
      <!--- append menu2.stAttributes to menu1.stAttributes, --->
      <!--- replacing if duplicate keys --->
      <!--- normal merge/replace operation on children --->
      <cfset StructAppend(this.stAttributes, arguments.menu2.stAttributes, "yes")>
      <cfset mergeChildren(arguments.menu2)>
    </cfcase>
    
    <cfcase value="mergeNoReplace">
      <!--- append menu2.stAttributes to menu1.stAttributes, --->
      <!--- do not replace duplicate keys --->
      <!--- normal merge/replace operation on children --->
      <cfset StructAppend(this.stAttributes, arguments.menu2.stAttributes, "no")>
      <cfset mergeChildren(arguments.menu2)>
    </cfcase>
    
    <cfdefaultcase> <!--- this will catch "none" values --->
      <!--- what should we do with strange mergeTypes? or "none"s? --->
      <!--- (remember, menu1.id = menu2.id - we assume this in here) --->
      <!--- How about "merge" as default for menus? -TH --->
      <cfset StructAppend(this.stAttributes, arguments.menu2.stAttributes, "yes")>
      <cfset mergeChildren(arguments.menu2)>
    </cfdefaultcase>
  </cfswitch>
  
</cffunction>
<!--- }}} package mergeMenu(WebtopMenu menu2) --->





<!--- {{{ package getXml() --->
<cffunction name="getXml" access="package" output="no" returnType="string"
  hint="returns xml of this webtop element as a string">
  
  <cfset var sOutput = "">
  <cfset var i = "">
  
  <!--- if we were not initialized with a proper MenuXmlElement, --->
  <!--- just return empty string--->
  <!--- this ought to do the least amount of harm --->
  <cfif not this.isInitialized>
    <cfreturn sOutput>
  </cfif>
  
  <!--- this call takes the struct and returns a string that looks like --->
  <!--- 'key="value" key="value" ...' --->
  <cfinvoke component="WebtopRoot" method="toAttributeString" returnVariable="sOutput" stAttributes="#this.stAttributes#">
  <cfset sOutput = "<menu " & sOutput & " >">
  
  <!--- add the children --->
  <cfloop index="i" from="1" to="#ArrayLen(this.aMenuitems)#">
    <cfset sOutput = sOutput & " " & this.aMenuitems[i].getXml()>
  </cfloop>
  
  <!--- add the close tag --->
  <cfset sOutput = sOutput & " </menu>">
  
  <cfreturn sOutput>
</cffunction>
<!--- }}} package getXml() --->

<!--- }}} PACKAGE functions --->



<!--- {{{ PRIVATE functions --->

<!--- {{{ private mergeChildren(WebtopMenu menu2) --->
<cffunction name="mergeChildren" access="private" output="no" returnType="void"
  hint="merges the children of menu2 into the children of this menu,
  following any specified mergeType rules.  See WebtopRoot.cfc for more information
  about mergeType.">
  
  <cfargument name="menu2" type="WebtopMenu" required="true"
    hint="menu whose children to merge with this one">
  
  <cfset var i = "">
  
  <!--- comment note: menu1 means THIS --->
  
  <!--- loop through and merge each child (passing the buck again!) --->
  <cfloop index="i" from="1" to="#ArrayLen(arguments.menu2.aMenuitems)#">
    <cfset mergeChild(arguments.menu2.aMenuitems[i])>
  </cfloop>
  
</cffunction>
<!--- }}} private mergeChildren(WebtopMenu menu2) --->


<!--- {{{ private mergeChild(WebtopMenuitem child) --->
<cffunction name="mergeChild" access="private" output="no" returnType="void"
  hint="merges the child into aMenuitems">
  
  <cfargument name="child" type="WebtopMenuitem" required="true"
    hint="menuitem to merge into this menu's children">
  
  <cfset var i = "">
  <cfset var matchFound = "false">
  
  <!--- we must have an id to match, otherwise, no point in looking --->
  <cfif StructKeyExists(arguments.child.stAttributes, "id")>
    <!--- does the same child exist in this menu? --->
    <!--- ID will match, if so --->
    <cfloop index="i" from="1" to="#ArrayLen(this.aMenuitems)#">
      <!--- id attribute must be present and must match --->
      <cfif StructKeyExists(this.aMenuitems[i].stAttributes, "id")
        and this.aMenuitems[i].stAttributes.id is arguments.child.stAttributes.id>
        
        <!--- set matchFound=true so we don't append the child later --->
        <cfset matchFound = "true">
        
        <!--- they match, so merge them --->
        <cfset this.aMenuitems[i].mergeMenuitem(arguments.child)>
        
        <!--- no need to keep looping --->
        <cfbreak>
      </cfif>
    </cfloop>
    
  </cfif>
  
  <cfif not matchFound>
    <!--- a match was not found, so we should append the menuitem --->
    
    <cfset insertChildWithOrder(arguments.child)>
  </cfif>
  
</cffunction>
<!--- }}} private mergeChild(WebtopMenuitem child) --->

<!--- {{{ private insertChildWithOrder(WebtopMenuitem child) --->
<cffunction name="insertChildWithOrder" access="private" output="no" returnType="void"
  hint="inserts the child into aMenuitems with order">
  
  <cfargument name="child" type="WebtopMenuitem" required="true"
    hint="menuitem to insert into this menu's children">
  
  <cfset var i = 0>
  <cfset var inserted = "false">
  
  <cfloop index="i" from="1" to="#ArrayLen(this.aMenuitems)#">
    <cfif arguments.child.stAttributes[this.orderAttrib] lt this.amenuitems[i].stAttributes[this.orderAttrib]>
      <cfset ArrayInsertAt(this.aMenuitems, i, arguments.child)>
      <cfset inserted="true">
      <cfbreak>
    </cfif>
  </cfloop>
  
  <cfif not inserted>
    <cfset ArrayAppend(this.aMenuitems, arguments.child)>
    <cfset inserted = "true">
  </cfif>
</cffunction>
<!--- }}} private insertChildWithOrder(WebtopMenuitem child) --->

<!--- }}} PRIVATE functions --->

</cfcomponent>
