<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="#local" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--~	
    Flattens the retrieved directory list into a long list of files.
    Each file gets a relative and absolute path. 
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <xsl:include href="../../../xslmod/general.mod.xsl"/>
  <xsl:include href="../../../xslmod/href.mod.xsl"/>
  
  <xsl:mode on-no-match="shallow-copy"/>

  <!-- ======================================================================= -->
  <!-- PARAMETERS: -->

  <xsl:param name="add-decoded" as="xs:boolean" required="yes"/>
  
  <!-- ================================================================== -->
  
  <xsl:template match="/c:directory[not(xtlc:str2bln(@error, false()))]">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@* except @xml:base" copy-namespaces="no"/>
      
      <xsl:variable name="base-dir" as="xs:string" select="xtlc:href-canonical(@xml:base)"/>
      <xsl:attribute name="xml:base" select="$base-dir"/>
      
      <xsl:for-each select=".//c:file">
        <xsl:copy copy-namespaces="no">
          <xsl:copy-of select="@* except @xml:base" copy-namespaces="no"/>
          <xsl:variable name="href-abs" as="xs:string" select="xtlc:href-canonical(xtlc:href-concat(ancestor-or-self::*/@xml:base))"/>
          <xsl:variable name="href-rel" as="xs:string" select="xtlc:href-relative-from-path($base-dir, $href-abs)"/>
          <xsl:attribute name="href-abs" select="$href-abs"/>
          <xsl:attribute name="href-rel" select="$href-rel"/>
          <xsl:if test="$add-decoded">
            <xsl:attribute name="href-abs-decoded" select="xtlc:href-decode-uri($href-abs)"/>
            <xsl:attribute name="href-rel-decoded" select="xtlc:href-decode-uri($href-rel)"/>
          </xsl:if>
        </xsl:copy>
      </xsl:for-each>
      
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
