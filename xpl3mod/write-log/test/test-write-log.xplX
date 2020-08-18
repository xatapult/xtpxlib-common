<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.by4_spg_smb"
  version="3.0" exclude-inline-prefixes="#all" xmlns:xtlc="http://www.xtpxlib.nl/ns/common">

  <p:documentation>
    Test driver for xtlc:write-log
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:import href="../write-log.xpl"/>
  
  <p:input port="source" primary="true">
    <null/>
  </p:input>

  <!-- ================================================================== -->

  <p:variable name="href-log" as="xs:string" select="resolve-uri('../tmp/test.log.xml', static-base-uri())"/>
  <p:variable name="writes" as="xs:integer" select="4"/>

  <p:for-each>
    <p:with-input select="1 to $writes"/>
    <p:variable name="index" as="xs:integer" select="p:iteration-position()"/>

    <xtlc:write-log href-log="{$href-log}" status="debug" keep-entries="0" enable-debug-messages="true">
      <p:with-option name="log-comments" select="('A', 'BBBBBBBBBBBBBBBBBB')"/> 
      <p:with-option name="messages" select="('Entry ' || $index, 'Another ' || $index)"/>
      <p:with-option name="additional-attributes" as="map(xs:QName, xs:string)" select="map{'x': 'ý', 'Q{#xx}xxx': 'xtlc?'}"/> 
      <p:with-option name="additional-elements" as="element()*" select="/*/*">
        <p:inline>
          <ELMS>
            <elms1>1</elms1>
            <elms2>1</elms2>
          </ELMS>
        </p:inline>
      </p:with-option> 
    </xtlc:write-log>
    
  </p:for-each>
  <p:sink/>

</p:declare-step>
