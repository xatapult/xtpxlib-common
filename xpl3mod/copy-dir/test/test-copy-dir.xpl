<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="#local.hnn_34k_sxb" version="3.0" exclude-inline-prefixes="#all" name="this">

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="../copy-dir.xpl"/>
  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}"/>

  <!-- ================================================================== -->

  <p:variable name="href-source" as="xs:string" select="resolve-uri('../../', static-base-uri())"/>
  <p:variable name="href-target" as="xs:string" select="resolve-uri('../../../tmp/copy-dir-result', static-base-uri())"/>

  <xtlc:copy-dir href-source="{$href-source}" href-target="{$href-target}">
    <!-- filters? -->
  </xtlc:copy-dir>

  <p:wrap-sequence wrapper="test-ciopy-dir"/>

</p:declare-step>
