<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.lsr_2gn_1bc"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" version="3.0" exclude-inline-prefixes="#all" name="expand-macro-definitions"
  type="xtlc:expand-macro-definitions">

  <p:documentation>
    This is an XProc driver for the `xtlc:expand-macro-definitions` template in `xslmod/macrodefs.mod.xsl`. 
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:documentation>The document to expand the macro definition references in</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>The resulting document with the macro definitions expanded. </p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="use-standard-macrodefs" as="xs:boolean" required="false" select="true()">
    <p:documentation>Whether to use the standard macro definitions.</p:documentation>
  </p:option>
  <p:option name="macrodefs" as="map(xs:string, xs:string)*" required="false" select="()">
    <p:documentation>Any initial macro definitions.</p:documentation>
  </p:option>
  <p:option name="expand-in-text" as="xs:boolean" required="false" select="true()">
    <p:documentation>Whether to expand the macro definitions in text nodes.</p:documentation>
  </p:option>
  <p:option name="expand-in-attributes" as="xs:boolean" required="false" select="true()">
    <p:documentation>Whether to expand the macro definitions in attributes.</p:documentation>
  </p:option>
  <p:option name="use-local-macrodefs" as="xs:boolean" required="false" select="true()">
    <p:documentation>Check for `&lt;*:macrodefs>` element as first child and process accordingly</p:documentation>
  </p:option>
  <p:option name="add-macrodef-comments" as="xs:boolean" required="false" select="false()">
    <p:documentation>Whether to add a macro definition comment (summarizing all macro definitions) when a `&lt;*:macrodefs>` element is processed.</p:documentation>
  </p:option>


  <!-- ================================================================== -->
  <!-- MAIN: -->

  <p:xslt>
    <p:with-input port="stylesheet" href="../../xsl/expand-macro-definitions.xsl"/>
    <p:with-option name="parameters" select="map{ 
      'use-standard-macrodefs': $use-standard-macrodefs,  
      'macrodefs': $macrodefs,  
      'expand-in-text': $expand-in-text,  
      'expand-in-attributes': $expand-in-attributes,  
      'use-local-macrodefs': $use-local-macrodefs,  
      'add-macrodef-comments': $add-macrodef-comments  
    }"/>
  </p:xslt>

</p:declare-step>
