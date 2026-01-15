<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.zl3_vmx_yhc" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  version="3.0" exclude-inline-prefixes="#all" name="test-message">

  <p:import href="../message.xpl"/>

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <dummy/>
  </p:input>
  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}"/>


  <!-- ======================================================================= -->

  <xtlc:message prompt-string="***">
    <p:with-option name="text" select="('hello', 'hi')"/>
  </xtlc:message>
  <xtlc:message level="1" prompt-string="***">
    <p:with-option name="text" select="('hello', 'hi')"/>
  </xtlc:message>
  <xtlc:message/>
  <xtlc:message level="2" prompt-string="***" debug="true">
    <p:with-option name="text" select="('hello', 'hi')"/>
  </xtlc:message>

</p:declare-step>
