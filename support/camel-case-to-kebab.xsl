<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.s3n_chs_sdc"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Stylesheet that attempts to change the naming style of another stylesheet 
       from lowerCamelCase into lower-kebab for variables and parameters.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <!-- ================================================================== -->

  <!-- Create a translation table: -->
  <xsl:variable name="all-names-with-uc" as="xs:string*"
    select="(((//(xsl:variable | xsl:param)/@name)[matches(., '[A-Z]')] ! string(.)) => distinct-values())"/>
  <xsl:variable name="name-translations" as="map(*)">
    <!-- old-name -> new name (no $ signs in front!) -->
    <xsl:map>
      <xsl:for-each select="$all-names-with-uc">
        <xsl:map-entry key="." select="replace(., '([A-Z])', '-$1') => lower-case()"/>
      </xsl:for-each>
    </xsl:map>
  </xsl:variable>

  <!-- ======================================================================= -->

  <xsl:template match="xsl:*/@name[matches(., '[A-Z]')]">
    <xsl:variable name="name" as="xs:string" select="string(.)"/>
    <xsl:choose>
      <xsl:when test="map:contains($name-translations, $name)">
        <xsl:attribute name="name" select="$name-translations($name)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xsl:*/@*[contains(., '$') and matches(., '[A-Z]')]">
    <xsl:attribute name="{node-name(.)}" select="local:translate-names(string(.))"/>
  </xsl:template>


  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="text()[contains(., '$') and contains(., '{') and contains(., '}') and matches(., '[A-Z]')]">
    <xsl:value-of select="local:translate-names(string(.))"/>
  </xsl:template>

  <!-- ======================================================================= -->

  <xsl:function name="local:translate-names" as="xs:string">
    <xsl:param name="in" as="xs:string"/>

    <xsl:iterate select="map:keys($name-translations)">
      <xsl:param name="in" select="$in"/>
      <xsl:on-completion select="$in"/>

      <xsl:variable name="source-name" as="xs:string" select="."/>
      <xsl:variable name="source-regexp" as="xs:string" select="'\$' || $source-name"/>
      <xsl:variable name="target-exp" as="xs:string" select="'\$' || $name-translations($source-name)"/>
      <xsl:variable name="replaced" as="xs:string" select="replace($in, $source-regexp, $target-exp)"/>

      <xsl:next-iteration>
        <xsl:with-param name="in" select="$replaced"/>
      </xsl:next-iteration>
    </xsl:iterate>

  </xsl:function>

</xsl:stylesheet>
