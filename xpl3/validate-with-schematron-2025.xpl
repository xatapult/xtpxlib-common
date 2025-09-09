<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.n4j_41s_ngc"
  xmlns:schxslt="http://dmaus.name/ns/2023/schxslt" xmlns:sch="http://purl.oclc.org/dsdl/schematron" version="3.0" exclude-inline-prefixes="#all"
  name="validate-with-schematron-2025">

  <p:documentation>
    This pipeline validates a document using Schematron 2025 (using the 
    SchXslt processor as attached to Morgana).
    
    The schema should be attached to the document with a standard xml-model PI, like this:
    
    <?xml-model href="visit-each-example-schema.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>

  </p:documentation>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml" href="test/visit-each-example.xml">
    <p:documentation>The document to validate. Must have an appropriate xml-model PI.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>The resulting SVRL</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="phase" as="xs:string" required="false" select="'#DEFAULT'">
    <p:documentation>The Schematron phase to select</p:documentation>
  </p:option>


  <!-- ================================================================== -->
  <!-- MAIN: -->

  <p:variable name="base-uri" as="xs:string" select="base-uri(/)"/>
  <p:variable name="xml-model-pi" as="processing-instruction(xml-model)?" select="/processing-instruction(xml-model)"/>
  <p:variable name="xml-model-raw" as="xs:string" select="string($xml-model-pi)"/>

  <!-- Perform some checks: -->
  <p:if test="empty($xml-model-pi)">
    <p:error code="no-xml-model-pi">
      <p:with-input>
        <p:inline content-type="text/plain" xml:space="preserve">Missing xml-model processing instruction in {$base-uri}</p:inline>
      </p:with-input>
    </p:error>
  </p:if>
  <p:if test="not(contains($xml-model-raw, 'schematypens=&quot;http://purl.oclc.org/dsdl/schematron&quot;'))">
    <p:error code="invalid-xml-mdel-pi">
      <p:with-input>
        <p:inline content-type="text/plain" xml:space="preserve">xml-model processing instruction &quot;{$xml-model-raw}&quot; not for Schematron validation in {$base-uri}</p:inline>
      </p:with-input>
    </p:error>
  </p:if>

  <!-- Extract the schema URI, load it, and do some checks: -->
  <p:variable name="href-schema" as="xs:string" select="replace($xml-model-raw, '^.*href=&quot;(.+?)&quot;.*$', '$1') => resolve-uri($base-uri)"/>
  <p:if test="not(doc-available($href-schema))">
    <p:error code="no-schema">
      <p:with-input>
        <p:inline content-type="text/plain" xml:space="preserve">Schematron 2025 schema {$href-schema} not found or not well-formed</p:inline>
      </p:with-input>
    </p:error>
  </p:if>

  <p:load href="{$href-schema}" name="schematron-schema"/>
  <p:if test="empty(/sch:schema)">
    <p:error code="not-schematron-schema">
      <p:with-input>
        <p:inline content-type="text/plain" xml:space="preserve">Document {$href-schema} is not a Schematron schema</p:inline>
      </p:with-input>
    </p:error>
  </p:if>
  <p:if test="empty(/*/@schematronEdition[. eq '2025'])">
    <p:error code="not-schematron-2025-edition">
      <p:with-input>
        <p:inline content-type="text/plain" xml:space="preserve">Document {$href-schema} is not a 2025 edition Schematron schema (no /*/@schematronEdition=&quot;2025&quot; attribute)</p:inline>
      </p:with-input>
    </p:error>
  </p:if>

  <!-- At last, perform the validation: -->
  <p:variable name="compiler-options" as="map(xs:QName, xs:anyAtomicType)" select="map{ 'schxslt:expand-text': true() }"/>
  <p:validate-with-schematron assert-valid="false" report-format="svrl">
    <p:with-input port="source" pipe="source@validate-with-schematron-2025"/>
    <p:with-input port="schema" pipe="result@schematron-schema"/>
    <p:with-option name="phase" select="$phase"/>
    <p:with-option name="parameters" select="map{ 'c:compile': $compiler-options }"/>
  </p:validate-with-schematron>
  <p:identity>
    <p:with-input pipe="report"/>
  </p:identity>
  
  <!-- The following code uses the transpiler directly. This is no longer necessary, 
    I thought p:validate-with-schematron didn't pass the compiler arguments ok, 
    but that was a misunderstanding on my side. Just kept the code here for future reference. -->
  <!--<p:xslt name="compiled-schema">
    <p:with-input pipe="result@schematron-schema"/>
    <p:with-input port="stylesheet" href="file:/xatapult/xtools/schxslt2/transpile.xsl"/>
    <p:with-option name="parameters" select="map{ 'schxslt:expand-text': true() }"/>
  </p:xslt>
  
  <p:xslt>
    <p:with-input port="stylesheet" pipe="result@compiled-schema"/>
    <p:with-input port="source" pipe="source@validate-with-schematron-2025"/>
  </p:xslt>-->

</p:declare-step>
