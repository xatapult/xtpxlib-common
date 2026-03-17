<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.kls_zsz_p3c"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Processes the PI parameters into a map.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="json" encoding="UTF-8"/>

  <xsl:param name="parameters" as="xs:string*" required="true"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xsl:map>
      <xsl:for-each select="$parameters">
        <xsl:variable name="parameter" as="xs:string" select="."/>
        <xsl:choose>
          <xsl:when test="contains($parameter, '=')">
            <xsl:variable name="value" as="xs:string"
              select="substring-after($parameter, '=') => replace('^[&quot;&apos;&apos;]', '') => replace('[&quot;&apos;&apos;]$', '')"/>
            <xsl:map-entry key="substring-before($parameter, '=')" select="$value"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:map-entry key="$parameter" select="()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:map>
  </xsl:template>

</xsl:stylesheet>
