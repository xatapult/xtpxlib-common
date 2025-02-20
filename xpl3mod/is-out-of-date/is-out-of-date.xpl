<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.kf1_fsx_k2c"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" version="3.0" exclude-inline-prefixes="#all" name="is-out-of-date" type="xtlc:is-out-of-date">

  <p:documentation>
    Step that finds out if a list of target files is out-of-date against a list of source files.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->


  <!-- ======================================================================= -->
  <!-- DEVELOPMENT SETTINGS: -->

  <p:option name="develop-is-out-of-date" as="xs:boolean" static="true" select="false()"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>A single c:result document, containing either true (out-of-date) or false(not out-of-date).</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="href-sources" as="xs:string+" required="true" use-when="not($develop-is-out-of-date)">
    <p:documentation>A list of source files. These files must exist.</p:documentation>
  </p:option>
  <p:option name="href-sources" as="xs:string+" required="false"
    select="(resolve-uri('test/source-01.xml', static-base-uri()), resolve-uri('test/source-02.xml', static-base-uri()))"
    use-when="$develop-is-out-of-date"/>

  <p:option name="href-targets" as="xs:string+" required="true" use-when="not($develop-is-out-of-date)">
    <p:documentation>A list of target files. If one of these does not exist, the whole thing is out-of-date.</p:documentation>
  </p:option>
  <p:option name="href-targets" as="xs:string+" required="false"
    select="(resolve-uri('test/target-01.xml', static-base-uri()), resolve-uri('test/target-02.xml', static-base-uri()))"
    use-when="$develop-is-out-of-date"/>

  <!-- ======================================================================= -->

  <p:declare-step type="local:get-file-infos">

    <p:output port="result" primary="true" sequence="true" content-types="xml"/>

    <p:option name="hrefs" required="true" as="xs:string+"/>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

    <p:for-each>
      <p:with-input select="$hrefs">
        <dummy/>
      </p:with-input>
      <p:variable name="href" as="xs:string" select="string(.)"/>
      <p:file-info fail-on-error="false">
        <p:with-option name="href" select="$href"/>
      </p:file-info>
    </p:for-each>

  </p:declare-step>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <!-- Create a single document with info about all sources and targets: -->
  <local:get-file-infos>
    <p:with-option name="hrefs" select="$href-sources"/>
  </local:get-file-infos>
  <p:wrap-sequence wrapper="sources" name="sources-info"/>

  <local:get-file-infos>
    <p:with-option name="hrefs" select="$href-targets"/>
  </local:get-file-infos>
  <p:wrap-sequence wrapper="targets" name="targets-info"/>

  <p:insert match="/*" position="first-child">
    <p:with-input>
      <out-of-date-info/>
    </p:with-input>
    <p:with-input port="insertion" pipe="@sources-info"/>
  </p:insert>
  <p:insert match="/*" position="last-child">
    <p:with-input port="insertion" pipe="@targets-info"/>
  </p:insert>

  <!-- All sources must exist: -->
  <p:variable name="href-sources-not-exist" as="xs:string*" select="/*/sources/c:error/@href/string()"/>
  <p:if test="exists($href-sources-not-exist)">
    <p:error code="xtlc:error">
      <p:with-input>
        <p:inline content-type="text/plain" xml:space="preserve">Out-of-date determination: some sources do not exist: {string-join($href-sources-not-exist, '; ')}</p:inline>
      </p:with-input>
    </p:error>
  </p:if>

  <!-- Go and find out: -->
  <p:choose>

    <!-- When one of the targets is missing, its always out-of-date: -->
    <p:when test="exists(/*/targets/c:error)">
      <p:identity>
        <p:with-input>
          <c:result>true</c:result>
        </p:with-input>
      </p:identity>
    </p:when>

    <!-- Compare the dates: -->
    <p:otherwise>
      <p:variable name="sources-max-last-modified" as="xs:dateTime" select="max(/*/sources/c:file/@last-modified ! xs:dateTime(.))"/>
      <p:variable name="targets-min-last-modified" as="xs:dateTime" select="min(/*/targets/c:file/@last-modified ! xs:dateTime(.))"/>
      <p:identity>
        <p:with-input>
          <c:result>{$targets-min-last-modified le $sources-max-last-modified}</c:result>
        </p:with-input>
      </p:identity>
    </p:otherwise>

  </p:choose>

</p:declare-step>
