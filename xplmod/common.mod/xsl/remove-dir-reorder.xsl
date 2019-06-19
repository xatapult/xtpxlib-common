<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="#local" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--*	
    Reorders a directory list so all files/directories are in order for removal.
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <xsl:output method="xml" indent="no" encoding="UTF-8"/>
  
  <xsl:include href="../../../xslmod/general.mod.xsl"/>
  <xsl:include href="../../../xslmod/href.mod.xsl"/>
  
  <xsl:variable name="minimum-slash-count" as="xs:integer" select="2"/>
  
  <!-- ================================================================== -->
  
  <xsl:template match="/c:directory[not(xtlc:str2bln(@error, false()))]">
    
    <!-- Do a little sanity check: -->
    <xsl:variable name="main-href" as="xs:string" select="xtlc:href-protocol-remove(xtlc:href-canonical(/*/@xml:base))"/>
    <xsl:variable name="slashcount" as="xs:integer" select="string-length(replace($main-href, '[^/]', ''))"/>
    <xsl:choose>
      <xsl:when test="not(xtlc:href-is-absolute($main-href))">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="('Directory to remove &quot;', $main-href, '&quot; is not absolute')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$slashcount le $minimum-slash-count">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts"
            select="('Directory to remove &quot;', $main-href, '&quot; must be further away from root (must contain at least ', 
              string($minimum-slash-count), ' slashes)')"
          />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    
    <!-- Ok, go: -->
    <removals>
      <xsl:for-each select="//(c:file | c:directory)">
        <xsl:sort select="count(ancestor-or-self::*)" order="descending"/>
        
        <xsl:variable name="href-full-1" as="xs:string">
          <xsl:choose>
            <xsl:when test="self::c:directory">
              <xsl:sequence select="@xml:base"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="xtlc:href-concat((../@xml:base, @name))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="href-full-2" as="xs:string" select="xtlc:href-protocol-add(xtlc:href-canonical($href-full-1), $xtlc:protocol-file, true())"/>
        
        <remove href="{xtlc:href-add-encoding($href-full-2)}"/>
        
      </xsl:for-each>
    </removals>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="/*" priority="-10">
    <removals/>
  </xsl:template>
  
</xsl:stylesheet>
