<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.yyk_3vd_f2c"
  version="3.0" exclude-inline-prefixes="#all" name="test-generator-pipeline">

  <p:documentation>
    
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->


  <!-- ======================================================================= -->
  <!-- DEVELOPMENT SETTINGS: -->

  <p:option name="develop" as="xs:boolean" static="true" select="false()"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:documentation> </p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation> </p:documentation>
  </p:output>

  <p:identity>
    <p:with-input>
      <GENERATED-CONTENTS-XPL generator="{static-base-uri()}" timestamp="{current-dateTime()}">{string-join(//message, ', ')}</GENERATED-CONTENTS-XPL>
    </p:with-input>
  </p:identity>

</p:declare-step>
