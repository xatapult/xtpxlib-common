<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.ncx_5vq_xjb"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../general.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:variable name="in" as="element()">
    <TEXT xml:space="preserve">
  
  
  a
  
  
   b
  
  
</TEXT>
  </xsl:variable>


  <xsl:template match="/">
    <test-text2lines timestamp="{current-dateTime()}">
      <xsl:for-each select="xtlc:text2lines(string($in), true(), true())">
        <line>{.}</line>
      </xsl:for-each>
    </test-text2lines>
  </xsl:template>

</xsl:stylesheet>
