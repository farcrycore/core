<cfsetting enablecfoutputonly="yes">

<cfset wt = CreateObject("component", "farcry.core.packages.farcry.WebtopRoot")>
<cfset wt.init(application.factory.oWebtop.xmlwebtop)>
<cfset wt.transformLabels()>

<!--- {{{ xsl transform --->
<cfsavecontent variable="xslString">
<cfoutput><xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- KEEP the space before the class name in classAllowed
    and classDisallowed.
    Why?  These are combined with other classes
    and the space is the separator.  classAllowed or classDisallowed
    is the 2nd class listed of two, so the space needs to be a prefix
  -->
  <xsl:variable name="classAllowed"> allowed</xsl:variable>
  <xsl:variable name="classDisallowed"> disallowed</xsl:variable>
  
  <xsl:variable name="classRoot"></xsl:variable>
  <xsl:variable name="idRoot">webtoppermissions</xsl:variable>
  
  <xsl:variable name="classSectionTitle">section-title</xsl:variable>
  <xsl:variable name="classSubsectionTitle">subsection-title</xsl:variable>
  <xsl:variable name="classMenuTitle">menu-title</xsl:variable>
  <xsl:variable name="classMenuitemTitle">menuitem-title</xsl:variable>
  
  <xsl:variable name="classSection">section</xsl:variable>
  <xsl:variable name="classSubsection">subsection</xsl:variable>
  <xsl:variable name="classMenu">menu</xsl:variable>
  <xsl:variable name="classMenuitem">menuitem</xsl:variable>
  
  <xsl:variable name="idPrefixSectionTitle">section-title-</xsl:variable>
  <xsl:variable name="idPrefixSubsectionTitle">subsection-title-</xsl:variable>
  <xsl:variable name="idPrefixMenuTitle">menu-title-</xsl:variable>
  <xsl:variable name="idPrefixMenuitemTitle">menuitem-title-</xsl:variable>
  
  <xsl:variable name="idPrefixSection">section-</xsl:variable>
  <xsl:variable name="idPrefixSubsection">subsection-</xsl:variable>
  <xsl:variable name="idPrefixMenu">menu-</xsl:variable>
  <xsl:variable name="idPrefixMenuitem">menuitem-</xsl:variable>
  
  
  
  <xsl:template match="/">
    <xsl:apply-templates select="webtop" />
  </xsl:template>
  
  
  <xsl:template match="webtop">
    <ul>
      <xsl:attribute name="id"><xsl:value-of select="$idRoot" /></xsl:attribute>
      <xsl:attribute name="class"><xsl:value-of select="$classRoot" /><xsl:if test="@ISALLOWED = 'false'"><xsl:value-of select="$classDisallowed" /></xsl:if><xsl:if test="@ISALLOWED = 'true'"><xsl:value-of select="$classAllowed" /></xsl:if></xsl:attribute>
      
      
      <xsl:apply-templates select="section" />
    </ul>
  </xsl:template>
  
  
  <xsl:template match="section">
    <li>
      <xsl:attribute name="id"><xsl:value-of select="$idPrefixSectionTitle" /><xsl:value-of select="@id" /></xsl:attribute>
      <xsl:attribute name="class"><xsl:value-of select="$classSectionTitle" /><xsl:if test="@ISALLOWED = 'false'"><xsl:value-of select="$classDisallowed" /></xsl:if><xsl:if test="@ISALLOWED = 'true'"><xsl:value-of select="$classAllowed" /></xsl:if></xsl:attribute>
      
      <xsl:value-of select="@TRANSFORMEDLABEL" />
    </li>
    
    <ul>
      <xsl:attribute name="id"><xsl:value-of select="$idPrefixSection" /><xsl:value-of select="@id" /></xsl:attribute>
      <xsl:attribute name="class"><xsl:value-of select="$classSection" /></xsl:attribute>
      
      <xsl:apply-templates select="subsection" />
    </ul>
  </xsl:template>
  
  
  <xsl:template match="subsection">
    <li>
      <xsl:attribute name="id"><xsl:value-of select="$idPrefixSubsectionTitle" /><xsl:value-of select="@id" /></xsl:attribute>
      <xsl:attribute name="class"><xsl:value-of select="$classSubsectionTitle" /><xsl:if test="@ISALLOWED = 'false'"><xsl:value-of select="$classDisallowed" /></xsl:if><xsl:if test="@ISALLOWED = 'true'"><xsl:value-of select="$classAllowed" /></xsl:if></xsl:attribute>
      
      <xsl:value-of select="@TRANSFORMEDLABEL" />
    </li>
    
    <ul>
      <xsl:attribute name="id"><xsl:value-of select="$idPrefixSubsection" /><xsl:value-of select="@id" /></xsl:attribute>
      <xsl:attribute name="class"><xsl:value-of select="$classSubsection" /></xsl:attribute>
      
      <xsl:apply-templates select="menu" />
    </ul>
  </xsl:template>
  
  
  <xsl:template match="menu">
    <li>
      <xsl:attribute name="id"><xsl:value-of select="$idPrefixMenuTitle" /><xsl:value-of select="@id" /></xsl:attribute>
      <xsl:attribute name="class"><xsl:value-of select="$classMenuTitle" /><xsl:if test="@ISALLOWED = 'false'"><xsl:value-of select="$classDisallowed" /></xsl:if><xsl:if test="@ISALLOWED = 'true'"><xsl:value-of select="$classAllowed" /></xsl:if></xsl:attribute>
      
      <xsl:value-of select="@TRANSFORMEDLABEL" />
    </li>
    
    <ul>
      <xsl:attribute name="id"><xsl:value-of select="$idPrefixMenu" /><xsl:value-of select="@id" /></xsl:attribute>
      <xsl:attribute name="class"><xsl:value-of select="$classMenu" /></xsl:attribute>
      
      <xsl:apply-templates select="menuitem" />
    </ul>
  </xsl:template>
  
  
  <xsl:template match="menuitem">
    <li>
      <xsl:attribute name="id"><xsl:value-of select="$idPrefixMenuitemTitle" /><xsl:value-of select="@id" /></xsl:attribute>
      <xsl:attribute name="class"><xsl:value-of select="$classMenuitemTitle" /><xsl:if test="@ISALLOWED = 'false'"><xsl:value-of select="$classDisallowed" /></xsl:if><xsl:if test="@ISALLOWED = 'true'"><xsl:value-of select="$classAllowed" /></xsl:if></xsl:attribute>
      
      <xsl:value-of select="@TRANSFORMEDLABEL" />
    </li>
  </xsl:template>
  
</xsl:stylesheet>
</cfoutput>
</cfsavecontent>
<!--- }}} xsl transform --->


<!--- get list of policy groups --->
<cfset aPolicyGroups = request.dmSec.oAuthorisation.getAllPolicyGroups()>


<cfoutput>
  <!--- display form to choose policy group --->
  <select name="policygroupchooser" id="policygroupchooser" onChange="selectPolicyGroup()">
    <cfloop index="i" from="1" to="#ArrayLen(aPolicyGroups)#">
      <option value="#i#">#aPolicyGroups[i].policyGroupName#</option>
      <!--- NOTICE: the value is NOT the policy group id, but is the
        array index instead --->
    </cfloop>
  </select>
  
  <!--- styles for hiding/showing the permission map for each policy group --->
  <style type="text/css">
    .hidden-permission-map {
      display: none;
    }
    
    .allowed {
      color: green;
    }
    
    .disallowed {
      color: red;
    }
  </style>
  
  <!--- script to switch policy group permission maps when the form field is changed --->
  <script type="text/javascript">
    function selectPolicyGroup() {
      //determine the selected permission map
      var chooser = document.getElementById('policygroupchooser');
      id = chooser.options[chooser.selectedIndex].value;
      
      //hide all permission maps
      for (i = 1; i <= #ArrayLen(aPolicyGroups)#; i++) {
        document.getElementById('permission-map-' + i).className = 'hidden-permission-map';
      }
      
      //show the selected permission map
      document.getElementById('permission-map-' + id).className = '';
      
    }
  </script>
  
</cfoutput>

<cfloop index="i" from="1" to="#ArrayLen(aPolicyGroups)#">
  <cfoutput>
    <div class="hidden-permission-map" id="permission-map-#i#">
      #getTransformedPermissionMap(wt, aPolicyGroups[i].PolicyGroupID, xslString)#
    </div>
  </cfoutput>
</cfloop>

<cfoutput>
  <script type="text/javascript">
    //causes the initially selected policy group's
    //map to show up when the page loads
    selectPolicyGroup();
  </script>
  
</cfoutput>


<cffunction name="getTransformedPermissionMap" returnType="string">
  <cfargument name="webtopRoot" type="farcry.core.packages.farcry.WebtopRoot" required="yes">
  <cfargument name="policyGroupID" type="numeric" required="yes">
  <cfargument name="xslString" type="string" required="yes">
  
  <cfset var sReturn = "">
  
  <cfset arguments.webtopRoot.setPolicyGroup(arguments.policyGroupID)>
  <!--- TO PROPOGATE disallowed permissions, replace the above line with:
  <cfset arguments.webtopRoot.setPolicyGroup(arguments.policyGroupID,"true")>
  --->
  
  
  
  <cfset sReturn = XmlTransform( arguments.webtopRoot.getXmlDoc(), arguments.xslString )>
  <cfset sReturn = Replace(sReturn, '<?xml version="1.0" encoding="UTF-8"?>', '', "ALL")>
  
  <cfreturn sReturn>
</cffunction>






<cfsetting enablecfoutputonly="no">
