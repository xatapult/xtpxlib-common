<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:local="#local.omv_qkc_z1c"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Test driver for the macrodefs.mod.xsl module
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:include href="../general.mod.xsl"/>
  <xsl:include href="../macrodefs.mod.xsl"/>

  <!-- ================================================================== -->
  
  <xsl:variable name="test-macrodefs" as="map(xs:string, xs:string)">
    <xsl:map>
      <xsl:map-entry key="'M1'" select="'[value of M1]'"/>
      <xsl:map-entry key="'M2'" select="'[value of    M2]'"/>
      <xsl:map-entry key="'C1'" select="'[ref of M2: {$M2}]'"/>
      <xsl:map-entry key="'C2'" select="'[ref of C1: {$C1}]'"/>
      <xsl:map-entry key="'X1'" select="'[filename invalid chars:\/*?&gt;|]'"/>
    </xsl:map>
  </xsl:variable>
  
  <xsl:variable name="testdoc" as="document-node()" expand-text="false">
    <xsl:document>
      <testdoc xmlns="#something">
        <macrodefs>
          <macrodef name="X" value="XVALUE"/>
        </macrodefs>
        
        <blub x="${{X}}"/>
        <bloeb>X: {$X}</bloeb>
        
        <nested1>
          Some text
          <macrodefs>
            <macrodef name="X" value="XVALUE-IN-NESTED1"/>
          </macrodefs>
        </nested1>
        
        <nested1>
          <macrodefs>
            <macrodef name="X" value="XVALUE-IN-NESTED2"/>
          </macrodefs>
        </nested1>
        
      </testdoc>
      
      
      
      
    </xsl:document>
    
    
  </xsl:variable>
  
  <!-- ======================================================================= -->
  
  <xsl:template match="/"> 
    <macrodefs-test timestamp="{current-dateTime()}">
      <test>{ xtlc:expand-macrodefs('No macro reference in sight', $test-macrodefs) }</test>
      <test>{ xtlc:expand-macrodefs('Macro references that should not expand: ${{XX} and {{$XX}', $test-macrodefs) }</test>
      <test>{ xtlc:expand-macrodefs('Simple expansion: ${M1} and {$M2}', $test-macrodefs) }</test>
      <test>{ xtlc:expand-macrodefs('Circular expansion: ${C1}', $test-macrodefs) }</test>
      <test>{ xtlc:expand-macrodefs('Double circular expansion: ${C2}', $test-macrodefs) }</test>
      <test>{ xtlc:expand-macrodefs('Simple expansion with uc/lc flag: ${M1:uc} and {$M2:lc}', $test-macrodefs) }</test>
      <test>{ xtlc:expand-macrodefs('Simple expansion with compact/normalize flag + uc: ${M1:compact:uc} and {$M2:normalize:uc}', $test-macrodefs) }</test>
      <test>{ xtlc:expand-macrodefs('Simple expansion with filename safe flag: ${X1:fns}', $test-macrodefs) }</test>
      <test>{ xtlc:expand-macrodefs('Simple expansion with filename safe extra flag: ${X1:fnsx}', $test-macrodefs) }</test>
      <xsl:call-template name="xtlc:expand-macro-definitions">
        <xsl:with-param name="in" select="$testdoc"/>
        <xsl:with-param name="add-macrodef-comments" select="true()"/>
      </xsl:call-template>
      
    </macrodefs-test>
  
  
  
  
  
  </xsl:template>

</xsl:stylesheet>
