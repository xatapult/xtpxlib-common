<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.td2_p5x_k2c"
  xmlns:c="http://www.w3.org/ns/xproc-step" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Takes the document with file information prepared and tries to find out whether the targets are out-of-date.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <!-- ================================================================== -->

  <xsl:template match="/">

    <!-- All sources must exist: -->
    <xsl:variable name="href-sources-not-exist" as="xs:string*" select="/*/sources/c:error/@href/string()"/>
    <xsl:if test="exists($href-sources-not-exist)">
      <xsl:sequence select="error((), 'Out-of-date determination: some sources do not exist: ', string-join($href-sources-not-exist, '; '))"/>
    </xsl:if>

    <!-- Go and find out: -->
    <xsl:choose>

      <!-- When one of the targets is missing, its always out-of-date: -->
      <xsl:when test="exists(/*/targets/c:error)">
        <c:result>true</c:result>
      </xsl:when>

      <!-- Compare the dates: -->
      <xsl:otherwise>
        <xsl:variable name="sources-max-last-modified" as="xs:dateTime" select="max(/*/sources/c:file/@last-modified ! xs:dateTime(.))"/>
        <xsl:variable name="targets-min-last-modified" as="xs:dateTime" select="min(/*/targets/c:file/@last-modified ! xs:dateTime(.))"/>
        <c:result><xsl:sequence select="string($targets-min-last-modified le $sources-max-last-modified)"/></c:result>
      </xsl:otherwise>

    </xsl:choose>

  </xsl:template>

</xsl:stylesheet>
