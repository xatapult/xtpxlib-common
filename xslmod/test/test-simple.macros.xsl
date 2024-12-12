<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="#local.whr_nbm_vzb" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../general.mod.xsl"/>
  <xsl:include href="../simple-macros.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:template match="/">

    <xsl:variable name="in" as="xs:string" select="'This is $DATE and $$DATE, recursive $XX'"/>
    <xsl:variable name="macros" as="map(*)" select="map{'DATE': string(current-date()), 'XX': '***$DATE***'}"/>

    <test-simple-macros timestamp="{current-dateTime()}">
      <in>{$in}</in>
      <out>{xtlc:expand-simple-macros($in, $macros, true())}</out>
    </test-simple-macros>

  </xsl:template>

</xsl:stylesheet>
