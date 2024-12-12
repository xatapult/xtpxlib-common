<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.ldl_jfn_1bc"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--~
      This is a driver for the `xtlc:expand-macro-definitions` template in `xslmod/macrodefs.mod.xsl`. 
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <xsl:include href="../xslmod/general.mod.xsl"/>
  <xsl:include href="../xslmod/macrodefs.mod.xsl"/>

  <!-- ======================================================================= -->
  <!-- PARAMETERS -->

  <xsl:param name="in" as="node()" required="false" select=".">
    <!--~ The node for which to expand the macro definitions. Must be an element or a document node. -->
  </xsl:param>
  <xsl:param name="use-standard-macrodefs" as="xs:boolean" required="false" select="true()">
    <!--~ Whether to use the standard macro definitions. -->
  </xsl:param>
  <xsl:param name="macrodefs" as="map(xs:string, xs:string)*" required="false" select="()">
    <!--~ Any initial macro definitions. -->
  </xsl:param>
  <xsl:param name="expand-in-text" as="xs:boolean" required="false" select="true()">
    <!--~ Whether to expand the macro definitions in text nodes. -->
  </xsl:param>
  <xsl:param name="expand-in-attributes" as="xs:boolean" required="false" select="true()">
    <!--~ Whether to expand the macro definitions in attributes. -->
  </xsl:param>
  <xsl:param name="use-local-macrodefs" as="xs:boolean" required="false" select="true()">
    <!--~ Check for `<*:macrodefs>` element as first child and process accordingly -->
  </xsl:param>
  <xsl:param name="add-macrodef-comments" as="xs:boolean" required="false" select="false()">
    <!--~ Whether to add a macro definition comment (summarizing all macro definitions) when a `<*:macrodefs>` element is processed. -->
  </xsl:param>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xsl:call-template name="xtlc:expand-macro-definitions"> 
      <xsl:with-param name="use-standard-macrodefs" select="$use-standard-macrodefs"/>
      <xsl:with-param name="macrodefs" select="$macrodefs"/>
      <xsl:with-param name="expand-in-text" select="$expand-in-text"/>
      <xsl:with-param name="expand-in-attributes" select="$expand-in-attributes"/>
      <xsl:with-param name="use-local-macrodefs" select="$use-local-macrodefs"/>
      <xsl:with-param name="add-macrodef-comments" select="$add-macrodef-comments"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
