<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.znd_n4z_p3c"
  version="3.0" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-inline-prefixes="#all" name="test-process-pi">

  <p:import href="../process-pi.xpl"/>

  <p:input port="source" primary="true" sequence="false" content-types="xml" href="test-process-pi-1.xml"/>
  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}"/>

  <!-- ======================================================================= -->

  <xtlc:process-pi/>

</p:declare-step>
