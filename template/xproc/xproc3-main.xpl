<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.${id}" version="3.0"
  exclude-inline-prefixes="#all">

  <p:documentation>
    ${caret}
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:input port="source" primary="true" sequence="false">
    <p:documentation> </p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation> </p:documentation>
  </p:output>


  <!-- ================================================================== -->

  <p:identity/>

</p:declare-step>
