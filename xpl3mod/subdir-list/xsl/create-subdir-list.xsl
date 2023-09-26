<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="#local.ccs_g3g_xyb" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Turns the output of a p:directory into the appropriate structure for xtlc:subdir-list. 
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-skip"/>
  
  <xsl:include href="../../../xslmod/href.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:variable name="root-path" as="xs:string" select="/*/@xml:base"/>
  
  <!-- ======================================================================= -->
  
  <xsl:template match="/*">
    <subdir-list href="{$root-path}">
      <xsl:apply-templates/>
    </subdir-list>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="c:directory"> 
    <subdir href="{xtlc:href-concat(($root-path, @name))}" name="{@name}"/>
  </xsl:template>

</xsl:stylesheet>
