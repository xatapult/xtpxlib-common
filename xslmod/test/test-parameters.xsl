<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.pzx_cnr_c3b" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Test driver for the parameters.mod.xsl module.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:include href="../general.mod.xsl"/>
  <xsl:include href="../parameters.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- PARAMETERS: -->

  <xsl:variable name="href-1" as="xs:string" select="resolve-uri('test-parameters-1.xml', static-base-uri())"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->



  <!-- ================================================================== -->
  <!-- MAIN TEMPLATES: -->

  <xsl:template match="/"> 
    <test-parameters timestamp="{current-dateTime()}">
      
      <xsl:variable name="filters-1" as="map(xs:string, xs:string*)?" select="map{'system': 'acc', 'level': ('current', 'new')}"/>
      <xsl:variable name="parameter-map-1" as="map(xs:string, xs:string*)?" select="xtlc:parameters-get($href-1, $filters-1)"/>      
      <test href="{$href-1}">
        <xsl:call-template name="map-out">
          <xsl:with-param name="map" select="$parameter-map-1"/>
        </xsl:call-template>
      </test>
    </test-parameters>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:template name="map-out">
    <xsl:param name="map" as="map(xs:string, xs:string*)?" required="yes"/>
    
    <map>
      <xsl:for-each select="map:keys($map)">
        <entry key="{.}">{ string-join($map(.), ';') }</entry> 
      </xsl:for-each>
    </map>
  </xsl:template>
  
</xsl:stylesheet>
