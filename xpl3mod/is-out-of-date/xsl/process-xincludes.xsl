<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.td2_p5x_k2c" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:xi="http://www.w3.org/2001/XInclude" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Takes a document and creates a list of XInclude-d documents involved (including the main one).
       
       Returns a JSON map with a single entry with key '_'.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="json" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>
  
  <xsl:include href="../../../xslmod/href.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xsl:map>
      <xsl:map-entry key="'_'" select="local:get-xincluded-documents-hrefs(., ())"></xsl:map-entry>
    </xsl:map>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="local:get-xincluded-documents-hrefs" as="xs:string*">
    <!-- Returns a list of (canonical) hrefs of the main document and the documents that are XInclude-d. -->
    <xsl:param name="document" as="document-node()"/>
    <xsl:param name="href-documents-checked" as="xs:string*"/>
    
    <xsl:variable name="href-current" as="xs:string" select="base-uri($document) => xtlc:href-canonical()"/>
    <xsl:choose>
      <xsl:when test="$href-current = $href-documents-checked">
        <!-- Already checked, something recursive that shouldn't be there (?). Ignore. -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$href-current"/>
        <xsl:for-each select="$document//xi:include[@href]/@href/string() => distinct-values()">
          <xsl:variable name="href-include" as="xs:string" select="resolve-uri(., $href-current) => xtlc:href-canonical()"/>
          <xsl:if test="doc-available($href-include)">
            <xsl:sequence select="local:get-xincluded-documents-hrefs(doc($href-include), ($href-documents-checked, $href-current))"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:otherwise>  
    </xsl:choose>
    
  </xsl:function>
  
</xsl:stylesheet>
