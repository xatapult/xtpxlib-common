<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.xvp_vtd_f2c"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" version="3.0" exclude-inline-prefixes="#all" name="test-generator">

  <!-- ======================================================================= -->

  <p:import href="../expand-generators.mod.xpl"/>

  <p:input port="source" primary="true" sequence="false" content-types="xml" href="test-generator.xml"/>
  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}"/>


  <!-- ================================================================== -->

  <p:make-absolute-uris match="@href-generator"/>
  <xtlc:expand-generators/>

</p:declare-step>
