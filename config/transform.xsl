<?xml version="1.0" ?>
<!-- 
author: Tyler Ham (tylerh@austin.utexas.edu)
purpose: to transform customadmin.xml from version 2.3 format to 2.4
date: 2005-06-27

updated: 2005-10-05
 * this xsl makes section, subsection, and menu xmlText into label attributes
 * the doctype line is removed from the resulting xml - coldfusion chokes on it
 * the link is placed as 'link' attribute of menuitem, instead of xmlText


assumes:
  * No more than 26 subsections per section, otherwise we run out of alphabet!
     - this can be solved by using the position() number of the subsection
       as part of the ID, rather than converting to a letter
       Replace:
         <xsl:value-of select="substring($alphabetLower, position() mod 26, 1)" />
       With:
         <xsl:value-of select="concat('_', position())" />
       on line 62, to end up with id of the form "custom3_397", for section 3, subsection 397
  * each subsection has attributes 'sidebar' and 'content' that aren't represented the 2.3 format,
    they are set to the following:
     - sidebar="content/sidebar.cfm"
     - content="inc/content_overview.html"
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- <xsl:output method="xml" encoding="iso8859-1" doctype-system="customadmin.dtd" /> -->
  
  <!-- here's where the sidebar and content attributes of <subsection> are set -->
  <xsl:variable name="sidebar">content/sidebar.cfm</xsl:variable>
  <xsl:variable name="content">inc/content_overview.html</xsl:variable>
  
  <!-- later, we will use this to convert a position number into a position letter -->
  <xsl:variable name="alphabetLower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  
  <xsl:template match="/">
    <xsl:apply-templates select="customtabs" />
  </xsl:template>
  
  <xsl:template match="customtabs">
    <webtop>
      <xsl:apply-templates select="parenttab" />
    </webtop>
  </xsl:template>
  
  <!-- transform 'parenttab' node into 'section' node -->
  <xsl:template match="parenttab">
    <section>
      <!-- add 'id' and 'permission' attributes -->
      <xsl:attribute name="id"><xsl:value-of select="concat('custom', position())" /></xsl:attribute>
      <xsl:if test="@permission">
        <xsl:attribute name="permission"><xsl:value-of select="@permission" /></xsl:attribute>
      </xsl:if>
      
      <!-- put the name of the section -->
      <xsl:attribute name="label"><xsl:value-of select="normalize-space(text())" /></xsl:attribute>
      
      <!-- 'subtabs' -> 'subsection' -->
      <xsl:apply-templates select="subtabs" />
      
    </section>
  </xsl:template>
  
  <!-- transform 'subtabs' node into 'subsection' node -->
  <xsl:template match="subtabs">
    <subsection>
      <!-- add 'id', 'permission', 'sidebar', 'content' attributes -->
      <xsl:attribute name="id">custom<xsl:number count="parenttab" from="subtabs" /><xsl:value-of select="substring($alphabetLower, position() mod 26, 1)" /></xsl:attribute>
      <xsl:attribute name="sidebar"><xsl:value-of select="$sidebar" /></xsl:attribute>
      <xsl:attribute name="content"><xsl:value-of select="$content" /></xsl:attribute>
      <xsl:if test="@permission">
        <xsl:attribute name="permission"><xsl:value-of select="@permission" /></xsl:attribute>
      </xsl:if>
      
      <!-- put the name of the subsection -->
      <xsl:if test="text()">
        <xsl:attribute name="label"><xsl:value-of select="normalize-space(text())" /></xsl:attribute>
      </xsl:if>
      
      <!-- loop through nodes under subtabs.
           nodes 'menutitle' and 'menuitem' are not linked
           in the original customadmin. -->
      
      <!-- Here, we add any 'menuitem' nodes NOT under a 'menutitle'
           to a default menu -->
      <xsl:if test="boolean(menuitem[boolean(preceding-sibling::menutitle) = false()])">
        <menu>
          <xsl:attribute name="label">Default Menu</xsl:attribute>
          <xsl:for-each select="menuitem[boolean(preceding-sibling::menutitle) = false()]">
            <xsl:apply-templates select="." />
          </xsl:for-each>
        </menu>
      </xsl:if>
      
      <!-- We want a set of related 'menuitem' nodes to have a
           single 'menu' parent, with the 'menutitle' implemented
           as a property of 'menu'. -->
      <xsl:for-each select="menutitle">
        <menu>
          <!-- add permission attribute, if present -->
          <xsl:if test="@permission">
            <xsl:attribute name="permission"><xsl:value-of select="@permission" /></xsl:attribute>
          </xsl:if>
          
          <!-- menu label text -->
          <xsl:attribute name="label"><xsl:value-of select="normalize-space(text())" /></xsl:attribute>
          
          <!-- now the tricky part:
               for each 'menuitem' node AFTER the current 'menutitle' node, whose
               most recent preceding 'menutitle' node is the current node in the
               outer for-each (select="menutitle") -->
          <xsl:for-each select="following-sibling::menuitem[(preceding-sibling::menutitle)[last()] = current()]">
            <xsl:apply-templates select="." />
          </xsl:for-each>
          
        </menu>
      </xsl:for-each>
      
    </subsection>
  </xsl:template>
  
  <xsl:template match="menuitem">
    <menuitem>
      <!-- add 'label' and 'link' attributes -->
      <xsl:attribute name="label"><xsl:value-of select="label" /></xsl:attribute>
      <xsl:attribute name="link"><xsl:value-of select="link" /></xsl:attribute>
      
      <!-- add permission attribute, if present -->
      <xsl:if test="@permission">
        <xsl:attribute name="permission"><xsl:value-of select="@permission" /></xsl:attribute>
      </xsl:if>
      
      <!-- moved to attribute <xsl:value-of select="label" /> -->
    </menuitem>
  </xsl:template>
  
</xsl:stylesheet>
