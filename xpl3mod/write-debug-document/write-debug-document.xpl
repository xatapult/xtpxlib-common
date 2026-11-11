<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.ojz_j3k_clc"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" version="3.0" exclude-inline-prefixes="#all"
  name="write-debug-document" type="xtlc:write-debug-document">

  <p:documentation>
    Writes a debug document to disk, if enabled. Acts as an identity step
  </p:documentation>
 
  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:documentation>The document to write to disk.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}"
    pipe="source@write-debug-document">
    <p:documentation>The source document, unchanged</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- STATIC DECLARATIONS: -->
  
  <p:option static="true" name="empty-map" as="map(*)" required="false" select="map{}"/>
  
   <!-- ======================================================================= -->
  <!-- OPTIONS: -->
  
  <p:option name="href-dir-debug" as="xs:string" required="true">
    <p:documentation>The directory to write the debug document to.</p:documentation>
  </p:option>

  <p:option name="filename" as="xs:string" required="true">
    <p:documentation>The filename (including extension) of the debug document.</p:documentation>
  </p:option>

  <p:option name="enabled" as="xs:boolean" required="false" select="true()">
    <p:documentation>Whether debug documents are enabled</p:documentation>
  </p:option>


  <!-- ================================================================== -->
  <!-- MAIN: -->

  <p:if test="$enabled">
    <p:variable name="href-debug-document" as="xs:string" select="string-join(($href-dir-debug, $filename), '/')"/>
    <p:set-properties properties="map{'serialization': $empty-map}"/>
    <p:store serialization="map{'mathod': 'xml', 'indent': true()}">
      <p:with-option name="href" select="$href-debug-document"/>
    </p:store>
  </p:if>

</p:declare-step>
