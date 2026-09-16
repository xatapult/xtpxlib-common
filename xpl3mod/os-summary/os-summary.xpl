<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.zz1_222_pkc"
  version="3.0" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-inline-prefixes="#all" name="os-summary" type="xtlc:os-summary">

  <p:documentation>
    Gets some summary information about the OS. Only what I need. Can be expanded if necessary.
    Works both on Windows and Linux.
    
    Result: 
      xtlc:os-summary
        os-name = ...
        on-windows = true/false
        hostname = ... (only when $get-hostname is true)
        
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation> </p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="get-hostname" as="xs:boolean" required="false" select="false()">
    <p:documentation>Whether to fetch the hostname (this is relatively expensive).</p:documentation>
  </p:option>


  <!-- ================================================================== -->
  <!-- MAIN: -->

  <p:os-info name="os-info"/>
  <p:variable name="on-windows" as="xs:boolean" select="contains(/*/lower-case(@os-name), 'windows')"/>

  <p:identity name="base-result">
    <p:with-input>
      <xtlc:os-summary os-name="{/*/@os-name}" on-windows="{$on-windows}"/>
    </p:with-input>
  </p:identity>

  <!-- Get the hostname if requested: -->
  <p:if test="$get-hostname">
    <p:os-exec command="hostname">
      <p:with-input>
        <p:empty/>
      </p:with-input>
    </p:os-exec>
    <p:variable name="hostname" as="xs:string" select="replace(., '\s', '')"/>
    <p:add-attribute attribute-name="hostname" attribute-value="{$hostname}">
      <p:with-input pipe="@base-result"/>
    </p:add-attribute>
  </p:if>

</p:declare-step>
