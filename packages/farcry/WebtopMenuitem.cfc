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

<cfcomponent displayname="Webtop Menuitem" 
  hint="Represents a webtop menuitem, can merge with another menuitem,
  and translate to and from xml.">
  
  <cfset this.isInitialized = "false">
  <cfset this.stAttributes = StructNew()>
  
  <!--- default mergeType of a menuitem is 'merge' --->
  <!--- other possible values: 'mergeNoReplace', 'replace', 'none' --->
  <!--- see WebtopRoot.cfc for more info on mergeTypes --->
  <cfset this.stAttributes.mergeType = "merge">
  
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
  
</cffunction>
<!--- }}} package transformLabels() --->

<!--- {{{ package init(MenuitemXmlElement) --->
<cffunction name="init" access="package" output="no" returnType="WebtopMenuitem"
  hint="initializes this WebtopMenuitem with data from the given
  menuitem XmlElement from a webtop xml file.">
  
  <cfargument name="MenuitemXmlElement" required="true"
    hint="webtop menuitem XmlElement">
  
  <cfset var attrib = "">
  
  <!--- if anything is bad, simply return this --->
  <!--- isInitialized is still false, so getXml will --->
  <!--- just return empty string --->
  
  <!--- make sure the argument is an xml element --->
  <cfif not isXmlElem(arguments.MenuitemXmlElement)>
    <cfreturn this>
  </cfif>
  
  <!--- make sure XmlName is 'menuitem' --->
  <cfif not arguments.MenuitemXmlElement.XmlName is "menuitem">
    <cfreturn this>
  </cfif>
  
  <!--- ok, everything SEEMS ok, lets get the attributes --->
  <cfloop index="attrib" list="#StructKeyList(arguments.MenuitemXmlElement.XmlAttributes)#">
    <cfset this.stAttributes[attrib] = arguments.MenuitemXmlElement.XmlAttributes[attrib]>
  </cfloop>
  
  <!--- we are officially initialized, now getXml will work --->
  <cfset this.isInitialized = "true">
  
  <cfreturn this>
</cffunction>
<!--- }}} package init(MenuitemXmlElement) --->


<!--- {{{ package mergeMenuitem(WebtopMenuitem menuitem2) --->
<cffunction name="mergeMenuitem" access="package" output="no" returnType="void"
  hint="merges the given menuitem2 onto this menuitem, following any
  specified mergeType rules.  See WebtopRoot.cfc for more
  information about mergeType.
  Assuming menuitem1 and menuitem2 match (have same id).">
  
  <cfargument name="menuitem2" type="WebtopMenuitem" required="true"
    hint="menuitem to merge into this one">
  
  <!--- comment note: menuitem1 means THIS --->
  
  <!--- if mergeType='none' on menuitem1, it cannot be replaced or merged --->
  <cfif this.stAttributes.mergeType is "none">
    <cfreturn>
  </cfif>
  
  <cfswitch expression="#arguments.menuitem2.stAttributes.mergeType#">
    <cfcase value="replace">
      <!--- replace ALL data about menuitem1 with that of menuitem2 --->
      <!--- ?? should we maintain the same mergeType, though?? -TH --->
      <cfset this.stAttributes = arguments.menuitem2.stAttributes>
    </cfcase>
    
    <cfcase value="merge">
      <!--- append menuitem2.stAttributes to menuitem1.stAttributes, --->
      <!--- replacing if duplicate keys --->
      <cfset StructAppend(this.stAttributes, arguments.menuitem2.stAttributes, "yes")>
    </cfcase>
    
    <cfcase value="mergeNoReplace">
      <!--- append menuitem2.stAttributes to menuitem2.stAttributes, --->
      <!--- do not replace duplicate keys --->
      <cfset StructAppend(this.stAttributes, arguments.menuitem2.stAttributes, "no")>
    </cfcase>
    
    <cfdefaultcase> <!--- this will catch "none" values --->
      <!--- what should we do with strange mergeTypes? or "none"s?  --->
      <!--- (remember, menuitem1.id = menuitem2.id - we assume this in here) --->
      <!--- How about "merge" as default for menuitems? -TH --->
      <cfset StructAppend(this.stAttributes, arguments.menuitem2.stAttributes, "yes")>
    </cfdefaultcase>
  </cfswitch>
  
</cffunction>
<!--- }}} package mergeMenuitem(WebtopMenuitem menuitem2) --->


<!--- {{{ package getXml() --->
<cffunction name="getXml" access="package" output="no" returnType="string"
  hint="returns xml of this webtop element as a string">
  
  <cfset var sOutput = "">
  
  <!--- if we were not initialized with a proper MenuitemXmlElement, --->
  <!--- just return empty string --->
  <!--- this ought to do the least amount of harm --->
  <cfif not this.isInitialized>
    <cfreturn sOutput>
  </cfif>
  
  <!--- this call takes the struct and returns a string that looks like --->
  <!--- 'key="value" key="value" ...' --->
  <cfinvoke component="WebtopRoot" method="toAttributeString" returnVariable="sOutput" stAttributes="#this.stAttributes#">
  <cfset sOutput = "<menuitem " & sOutput & " />">
  
  <!--- menuitems don't have children, so we just closed the xml tag inline --->
  
  <cfreturn sOutput>
</cffunction>
<!--- }}} package getXml() --->


<!--- }}} PACKAGE functions --->


</cfcomponent>
