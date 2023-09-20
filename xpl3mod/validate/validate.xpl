<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.dr1_vbj_sxb" version="3.0"
  exclude-inline-prefixes="#all" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" type="xtlc:validate" name="validate">

  <p:documentation>
    This step performs validation using a W3C Schema and/or Schematron. It breaks the processing if something is wrong.
    
    This might seem superfluous (there are already `p:validate-with...` steps), but often these steps *change* the document.
    This step performs like a real identity step.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:documentation>Document to validate.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" pipe="source@validate">
    <p:documentation>The same as the input document.</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="href-schema" as="xs:string?" required="false" select="()">
    <p:documentation>Optional reference to an W3C Schema to validate the document with. If `()`, 
      no schema validation will be performed.</p:documentation>
  </p:option>
  
  <p:option name="schema-version" as="xs:string" required="false" select="'1.0'">
    <p:documentation>The W3C Schema version to use.</p:documentation>
  </p:option>
  
  <p:option name="href-schematron" as="xs:string?" required="false" select="()">
    <p:documentation>Optional reference to a Schematron Schema to validate the document with. If `()`, 
      no Schematron validation will be performed.</p:documentation>
  </p:option>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <p:if test="exists($href-schema)">
    <p:validate-with-xml-schema assert-valid="true" version="{$schema-version}">
      <p:with-input port="source" pipe="source@validate"/>
      <p:with-input port="schema" href="{$href-schema}"/>
    </p:validate-with-xml-schema>
  </p:if>
  
  <p:if test="exists($href-schematron)">
    <p:validate-with-schematron assert-valid="true">
      <p:with-input port="source" pipe="source@validate"/>
      <p:with-input port="schema" href="{$href-schematron}"/>
    </p:validate-with-schematron>
  </p:if>
  
</p:declare-step>
