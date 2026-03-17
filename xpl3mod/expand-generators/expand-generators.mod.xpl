<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.bhs_tpd_f2c"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" version="3.0" exclude-inline-prefixes="#all">

  <p:documentation>
    Library with steps for handling generate elements (see ../../xsdmod/generate.mod.xsd).
    
    A generator is either a stylesheet or a pipeline:
    * The stylesheet gets the generate element as its input.
    * The pipeline must have a primary input called source and output port called result. Both XML, non-sequence.
      The generate element will be present on its input port.
    
    The outcome of a generator must be a single well-formed XML document.
    * If the root element is _GENERATED, it will be removed/unwrapped. This allows returning multiple elements.
    * If the root element is _EMPTY, the result will be discarded.
  </p:documentation>

  <!-- ======================================================================= -->

  <p:option name="local:generator-type-xsl" static="true" as="xs:string" select="'xsl'"/>
  <p:option name="local:generator-type-xpl" static="true" as="xs:string" select="'xpl'"/>

  <p:option name="local:generator-type-all" static="true" as="xs:string+" select="($local:generator-type-xsl, $local:generator-type-xpl)"/>

  <!-- ================================================================== -->

  <p:declare-step type="xtlc:handle-generate-element" name="handle-generate-element">

    <p:documentation>
      Handles a single generate element(on its source port).
    </p:documentation>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:input port="source" primary="true" sequence="false" content-types="xml">
      <p:documentation>The generate element to handle</p:documentation>
    </p:input>

    <p:output port="result" primary="true" sequence="true" content-types="xml">
      <p:documentation>The resulting XML. This might be empty.</p:documentation>
    </p:output>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <!-- Pre-flight checks: -->
    <p:if test="empty(/*/self::*:generate)">
      <p:error code="xtlc:error">
        <p:with-input>
          <p:inline content-type="text/plain" xml:space="preserve">Invalid element for generate: &quot;{local-name(/*)}&quot;</p:inline>
        </p:with-input>
      </p:error>
    </p:if>
    <p:variable name="href-generator" as="xs:string?" select="xs:string(/*/@href-generator)[.]"/>
    <p:if test="empty($href-generator)">
      <p:error code="xtlc:error">
        <p:with-input>
          <p:inline content-type="text/plain" xml:space="preserve">Missing or empty href-generator attribute on generate element</p:inline>
        </p:with-input>
      </p:error>
    </p:if>
    <p:if test="not(doc-available($href-generator))">
      <p:error code="xtlc:error">
        <p:with-input>
          <p:inline content-type="text/plain" xml:space="preserve">Generator document missing (or not well-formed): &quot;{$href-generator}&quot;</p:inline>
        </p:with-input>
      </p:error>
    </p:if>

    <!-- Find out what type we have and go: -->
    <p:variable name="generator-type" as="xs:string" select="substring($href-generator, string-length($href-generator) - 2)"/>
    <p:try>
      <p:choose>
        <p:when test="$generator-type eq $local:generator-type-xsl">
          <p:xslt>
            <p:with-input port="source" pipe="source@handle-generate-element"/>
            <p:with-input port="stylesheet" href="{$href-generator}"/>
          </p:xslt>
        </p:when>
        <p:when test="$generator-type eq $local:generator-type-xpl">
          <p:run>
            <p:with-input href="{$href-generator}"/>
            <p:run-input port="source" pipe="source@handle-generate-element"/>
            <p:output port="result" primary="true"/>
          </p:run>
        </p:when>
        <p:otherwise>
          <p:error code="xtlc:error">
            <p:with-input>
              <p:inline content-type="text/plain" xml:space="preserve">Unrecognized generator type: &quot;{$generator-type}&quot; (expected: one of {string-join($local:generator-type-all, ', ')})</p:inline>
            </p:with-input>
          </p:error>
        </p:otherwise>
      </p:choose>

      <p:catch>
        <p:error code="xtlc:error">
          <p:with-input>
            <p:inline content-type="text/plain" xml:space="preserve">Error in resolving generator &quot;{$href-generator}&quot;: {string-join(//*:message, '; ')}</p:inline>
          </p:with-input>
        </p:error>
      </p:catch>
      
    </p:try>

    <!-- Handle any specials: -->
    <p:choose>
      <p:when test="exists(/*/self::*:_GENERATED)">
        <p:unwrap match="/*"/>
      </p:when>
      <p:when test="exists(/*/self::*:_EMPTY)">
        <p:identity>
          <p:with-input>
            <p:empty/>
          </p:with-input>
        </p:identity>
      </p:when>
      <p:otherwise>
        <p:identity/>
      </p:otherwise>

    </p:choose>

  </p:declare-step>

  <!-- ======================================================================= -->

  <p:declare-step type="xtlc:expand-generators">

    <p:documentation>
      Expands all the generate elements in a document.
    </p:documentation>

    <p:input port="source" primary="true" sequence="false" content-types="xml">
      <p:documentation>The document to expand the generate elements in.</p:documentation>
    </p:input>

    <p:output port="result" primary="true" sequence="true" content-types="xml">
      <p:documentation>The resulting document.</p:documentation>
    </p:output>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:viewport match="*:generate[exists(@href-generator)]">
      <xtlc:handle-generate-element/>
    </p:viewport>

  </p:declare-step>

</p:library>
