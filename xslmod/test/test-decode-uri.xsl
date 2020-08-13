<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.pzx_cnr_c3b" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Test driver for decode-uri
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

 <xsl:include href="../href.mod.xsl"/>

 <!-- ======================================================================= -->
  
  <xsl:template match="/">
    <xsl:variable name="in" as="xs:string" select="'a ab [a].xml'"/>
    <xsl:variable name="uri" as="xs:string" select="encode-for-uri($in)"/>
    <xsl:variable name="out" as="xs:string" select="xtlc:href-decode-uri($uri)"/>
    <test encoded="{$uri}" decoded="{$out}" ok="{$in eq $out}"></test>
    
  </xsl:template>
  
  
</xsl:stylesheet>
