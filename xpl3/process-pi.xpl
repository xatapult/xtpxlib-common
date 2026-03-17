<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.ksx_mnz_p3c"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" version="3.0" exclude-inline-prefixes="#all"
  name="process-pi" type="xtlc:process-pi">

  <p:documentation>
    This pipeline looks for XML processing instructions xtpxlib-process (as children of the document root)
    and processes these accordingly, in sequence. 
    
    * Main syntax: <?xtpxlib-process command par1=val1 par2=val2 ...?>
    * The par=value constructs must not contain spacing
    * The values can be written as "..." or '...'. However, spacing is still not allowed!
    
    Command: xproc
      Runs an XProc pipeline. 
      Parameters:
      * pipeline (mandatory): The URI of the pipeline to run (relative against the document).
      * source (optional): The primary source document, passed on the source port (relative against the document).
      * All other parameter/value combinations are passed in as a map in a single option called parameters.
    
     Command: xslt
      Runs an XSLT stylesheet. 
      Parameters:
      * stylesheet (mandatory): The URI of the stylesheet to run (relative against the document).
      * source (optional): The primary source document, passed as the stylesheet input (relative against the document).
      * All other parameter/value combinations are passed in as stylesheet parameters.
    
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml" href="test/test-process-pi-1.xml">
    <p:documentation>The XML document to process.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="true" content-types="any">
    <p:documentation>Whatever falls out at the end.</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="silent" as="xs:boolean" required="false" select="false()">
    <p:documentation>Whether to tell the world what we're doing</p:documentation>
  </p:option>

  <!-- ======================================================================= -->
  <!-- PIPELINES FOR THE SEPARATE COMMANDS: -->

  <p:declare-step name="process-xproc-command" type="local:process-xproc-command">

    <p:input port="main-document" primary="false" sequence="false" content-types="xml"/>
    <p:output port="result" primary="true" sequence="true" content-types="any"/>

    <p:option name="silent" as="xs:boolean" required="true"/>
    <p:option name="parameters-map" as="map(*)" required="true"/>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:variable name="href-main-document" as="xs:string" pipe="main-document@process-xproc-command" select="p:document-property(., 'base-uri')"/>

    <!-- Get the pipeline and do some pre-flight checks: -->
    <p:variable name="href-pipeline-raw" as="xs:string?" select="xs:string($parameters-map?pipeline)"/>
    <p:if test="empty($href-pipeline-raw)">
      <p:error code="xtlc:xtpxlib-process-error">
        <p:with-input>
          <p:inline content-type="text/plain" xml:space="preserve">Missing pipeline for xtpxlib-process xproc command</p:inline>
        </p:with-input>
      </p:error>
    </p:if>
    <p:variable name="href-pipeline" as="xs:string" select="resolve-uri($href-pipeline-raw, $href-main-document)"/>
    <p:if test="not(doc-available($href-pipeline))">
      <p:error code="xtlc:xtpxlib-process-error">
        <p:with-input>
          <p:inline content-type="text/plain" xml:space="preserve">Pipeline for xtpxlib-process xproc command not found or not well-formed: &quot;{$href-pipeline}&quot;</p:inline>
        </p:with-input>
      </p:error>
    </p:if>
    <p:load>
      <p:with-option name="href" select="$href-pipeline"/>
    </p:load>
    <p:variable name="pipeline-uri" as="xs:string" select="base-uri(.)"/>
    <p:if test="empty(/p:declare-step)">
      <p:error code="xtlc:xtpxlib-process-error">
        <p:with-input>
          <p:inline content-type="text/plain" xml:space="preserve">Pipeline for xtpxlib-process xproc command is not an XProc step: {$pipeline-uri}</p:inline>
        </p:with-input>
      </p:error>
    </p:if>
    <p:identity name="xproc-step"/>

    <!-- Get the required input and clean the xtpxlib-process PIs from it: -->
    <p:variable name="href-source-document-raw" as="xs:string?" select="xs:string($parameters-map?source)"/>
    <p:choose>
      <p:when test="exists($href-source-document-raw)">
        <p:variable name="href-source-document" as="xs:string" select="resolve-uri($href-source-document-raw, $href-main-document)"/>
        <p:if test="not(doc-available($href-source-document))">
          <p:error code="xtlc:xtpxlib-process-error">
            <p:with-input>
              <p:inline content-type="text/plain" xml:space="preserve">Source document for xtpxlib-process xproc command not found or not well-formed: &quot;{$href-source-document}&quot;</p:inline>
            </p:with-input>
          </p:error>
        </p:if>
        <p:load>
          <p:with-option name="href" select="$href-source-document"/>
        </p:load>
      </p:when>
      <p:otherwise>
        <!-- No specific source document specified, use the original main document (the one that contained the xtpxlib-process PI): -->
        <p:identity>
          <p:with-input pipe="main-document@process-xproc-command"/>
        </p:identity>
      </p:otherwise>
    </p:choose>
    <p:variable name="source-uri" as="xs:string" select="base-uri(.)"/>
    <p:delete match="/processing-instruction(xtpxlib-process)"/>
    <p:identity name="source-document"/>

    <!-- Tell the world what we're doing: -->
    <p:if test="not($silent)">
      <p:identity message="* Processing XProc pipeline {$pipeline-uri} (source={$source-uri})"/>
    </p:if>

    <!-- And finally run the pipeline. Any left over parameters are passed in a map called "parameters": -->
    <!-- Remark: oXygen will mark this p:run as invalid, but that's nonsense.  -->
    <p:run>
      <p:with-input pipe="@xproc-step"/>
      <p:run-input port="source" primary="true" pipe="@source-document"/>
      <p:run-option name="parameters" as="map(*)" select="map:remove($parameters-map, ('pipeline', 'source'))"/>
      <p:output port="result" primary="true" sequence="true" content-types="any"/>
    </p:run>

  </p:declare-step>

  <!-- ======================================================================= -->

  <p:declare-step name="process-xslt-command" type="local:process-xslt-command">

    <p:input port="main-document" primary="false" sequence="false" content-types="xml"/>
    <p:output port="result" primary="true" sequence="true" content-types="any"/>

    <p:option name="silent" as="xs:boolean" required="true"/>
    <p:option name="parameters-map" as="map(*)" required="true"/>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:variable name="href-main-document" as="xs:string" pipe="main-document@process-xslt-command" select="p:document-property(., 'base-uri')"/>

    <!-- Get the stylesheet and do some pre-flight checks: -->
    <p:variable name="href-stylesheet-raw" as="xs:string?" select="xs:string($parameters-map?stylesheet)"/>
    <p:if test="empty($href-stylesheet-raw)">
      <p:error code="xtlc:xtpxlib-process-error">
        <p:with-input>
          <p:inline content-type="text/plain" xml:space="preserve">Missing stylesheet for xtpxlib-process xslt command</p:inline>
        </p:with-input>
      </p:error>
    </p:if>
    <p:variable name="href-stylesheet" as="xs:string" select="resolve-uri($href-stylesheet-raw, $href-main-document)"/>
    <p:if test="not(doc-available($href-stylesheet))">
      <p:error code="xtlc:xtpxlib-process-error">
        <p:with-input>
          <p:inline content-type="text/plain" xml:space="preserve">Stylesheet for xtpxlib-process xslt command not found or not well-formed: &quot;{$href-stylesheet}&quot;</p:inline>
        </p:with-input>
      </p:error>
    </p:if>
    <p:load>
      <p:with-option name="href" select="$href-stylesheet"/>
    </p:load>
    <p:variable name="stylesheet-uri" as="xs:string" select="base-uri(.)"/>
    <p:if test="empty(/xsl:stylesheet)">
      <p:error code="xtlc:xtpxlib-process-error">
        <p:with-input>
          <p:inline content-type="text/plain" xml:space="preserve">stylesheet for xtpxlib-process xslt command is not an XProc step: {$stylesheet-uri}</p:inline>
        </p:with-input>
      </p:error>
    </p:if>
    <p:identity name="stylesheet"/>

    <!-- Get the required input and clean the xtpxlib-process PIs from it: -->
    <p:variable name="href-source-document-raw" as="xs:string?" select="xs:string($parameters-map?source)"/>
    <p:choose>
      <p:when test="exists($href-source-document-raw)">
        <p:variable name="href-source-document" as="xs:string" select="resolve-uri($href-source-document-raw, $href-main-document)"/>
        <p:if test="not(doc-available($href-source-document))">
          <p:error code="xtlc:xtpxlib-process-error">
            <p:with-input>
              <p:inline content-type="text/plain" xml:space="preserve">Source document for xtpxlib-process xslt command not found or not well-formed: &quot;{$href-source-document}&quot;</p:inline>
            </p:with-input>
          </p:error>
        </p:if>
        <p:load>
          <p:with-option name="href" select="$href-source-document"/>
        </p:load>
      </p:when>
      <p:otherwise>
        <!-- No specific source document specified, use the original main document (the one that contained the xtpxlib-process PI): -->
        <p:identity>
          <p:with-input pipe="main-document@process-xslt-command"/>
        </p:identity>
      </p:otherwise>
    </p:choose>
    <p:variable name="source-uri" as="xs:string" select="base-uri(.)"/>
    <p:delete match="/processing-instruction(xtpxlib-process)"/>
    <p:identity name="source-document"/>

    <!-- Tell the world what we're doing: -->
    <p:if test="not($silent)">
      <p:identity message="* Processing XSLT stylesheet {$stylesheet-uri} (source={$source-uri})"/>
    </p:if>

    <!-- And finally run the stylesheet. Any left over parameters are passed in as parameters: -->
    <p:xslt>
      <p:with-input pipe="@source-document"/>
      <p:with-input port="stylesheet" pipe="@stylesheet"/>
      <p:with-option name="parameters" select="map:remove($parameters-map, ('stylesheet', 'source'))"/>
    </p:xslt>

  </p:declare-step>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <p:for-each>
    <p:with-input select="/processing-instruction(xtpxlib-process)[normalize-space(.) ne '']"/>

    <!-- Dissect the PIs value: 
         * The first word is a command
         * The rest are the parameters and must be name=value constructs. Spacing here is not allowed!
    -->
    <p:variable name="pi-value" as="xs:string" select="string(/node()[1])"/>
    <p:variable name="pi-value-components" as="xs:string*" select="tokenize($pi-value, '\s+')[.]"/>
    <p:variable name="pi-command" as="xs:string" select="$pi-value-components[1]"/>
    <p:xslt>
      <p:with-input port="stylesheet" href="xsl-process-pi/process-pi-parameters.xsl"/>
      <p:with-option name="parameters" select="map{'parameters': subsequence($pi-value-components, 2)}"/>
    </p:xslt>
    <p:variable name="pi-parameters-map" as="map(*)" select="."/>

    <p:choose>

      <p:when test="$pi-command eq 'xproc'">
        <local:process-xproc-command>
          <p:with-input port="main-document" pipe="source@process-pi"/>
          <p:with-option name="silent" select="$silent"/>
          <p:with-option name="parameters-map" select="$pi-parameters-map"/>
        </local:process-xproc-command>
      </p:when>
      
      <p:when test="$pi-command eq 'xslt'">
        <local:process-xslt-command>
          <p:with-input port="main-document" pipe="source@process-pi"/>
          <p:with-option name="silent" select="$silent"/>
          <p:with-option name="parameters-map" select="$pi-parameters-map"/>
        </local:process-xslt-command>
      </p:when>

      <p:otherwise>
        <p:if test="not($silent)">
          <p:error code="xtlc:xtpxlib-process-error">
            <p:with-input>
              <p:inline content-type="text/plain" xml:space="preserve">Unrecognized xtpxlib-process PI command: &quot;{$pi-command}&quot;</p:inline>
            </p:with-input>
          </p:error>
        </p:if>
      </p:otherwise>

    </p:choose>

  </p:for-each>

</p:declare-step>
