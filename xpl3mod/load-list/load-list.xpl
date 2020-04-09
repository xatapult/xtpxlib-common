<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.mgg_kmb_xkb"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" version="3.0" exclude-inline-prefixes="#all" type="xtlc:load-list">

  <p:documentation>
    
  </p:documentation>

  <!-- ================================================================== -->
  <!-- SETUP: -->

  <p:documentation>
      Loads a list of documents according to xsd ... TBD
    </p:documentation>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


  <p:input port="source" primary="true" sequence="false" content-types="any" href="{resolve-uri('test/load-list-1.xml', static-base-uri())}">

    <p:documentation>The load list TBD</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="true" content-types="any" serialization="map{'indent': true()}">
    <p:documentation>TBD</p:documentation>
  </p:output>
  
  <!-- ================================================================== -->
  
  <p:option static="true" name="default-fail-on-error" as="xs:boolean"  select="true()"/>

  <!-- ================================================================== -->

  <p:declare-step type="local:force-xdm">

    <p:input port="source" primary="true" sequence="false" content-types="any"/>
    <p:output port="result" primary="true" sequence="true" content-types="xml" pipe="@step-load-file"/>
    
    <p:option name="href-location" as="xs:string?" required="false" select="()"/>
    <p:option name="filename-modifier" as="xs:string?" required="false" select="()"/>
    <p:option name="fail-on-error" as="xs:boolean" required="false" select="true()"/>

    <p:variable name="href-location-to-use" as="xs:string" select="($href-location, p:document-property(., 'base-uri'))[1]"/>
    <p:variable name="filename-temp" as="xs:string"
      select="'TEMP-' || translate(string(current-dateTime()), ':.+', '---') || $filename-modifier || '.xml'"/>
    <p:variable name="href-temp" as="xs:string" select="p:urify($filename-temp, $href-location-to-use)"/>

    <p:choose name="step-load-file">
      <p:when test="$fail-on-error">
        <p:store href="{$href-temp}"/>
        <p:load href="{$href-temp}" content-type="text/xml"/>
      </p:when>
      <p:otherwise>
<p:try>
  <p:output sequence="true"/>
  <p:store href="{$href-temp}"/>
  <p:load href="{$href-temp}" content-type="text/xml"/>
  <p:catch>
    <p:output sequence="true"/>
    <p:sink/>
  </p:catch>
  <p:finally>
    <p:file-delete href="{$href-temp}"/>
    <p:sink/>
  </p:finally>
</p:try>
      </p:otherwise>
    </p:choose>
    
    <!-- Delete the temp file. We don't care whether this succeeds... -->
    
    <!--<p:try>
      <p:file-delete href="{$href-temp}"/>
      <p:sink/>
      <p:catch>
        <p:sink/>
      </p:catch>
    </p:try>-->

  </p:declare-step>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <p:declare-step type="local:load">
    <!-- Save loader step. Always loads something, even if the file extension is incorrect for its type. -->

    <p:output port="result" primary="true" sequence="false" content-types="any"/>
    <p:option name="href-document" as="xs:string" required="true"/>

    <!-- Load the document and have the system guess the content type. If this proves wrong (e.g. a *.xml file that is not well-formed),
      load it as binary. -->
    <p:try>
      <p:load href="{$href-document}"/>
      <p:catch>
        <p:load href="{$href-document}" content-type="application/octet-stream"/>
      </p:catch>
    </p:try>

  </p:declare-step>

  <!-- ================================================================== -->

  <p:variable name="base-uri-load-list" as="xs:string" select="base-uri(/)"/>
  <p:variable name="global-force-xdm" as="xs:boolean" select="(xs:boolean(/*/@force-xdm), false())[1]"/>
  <p:variable name="global-fail-on-error" as="xs:boolean" select="(xs:boolean(/*/@fail-on-error), $default-fail-on-error)[1]"/>

  <p:for-each>
    <p:with-input select="/xtlc:load-list/xtlc:*"/>

    <p:variable name="load-list-position" as="xs:integer" select="p:iteration-position()"/>

    <p:choose>

      <!-- Load file from disk: -->
      <p:when test="exists(/*/self::xtlc:load-from-disk)">
        <p:output sequence="true"/>

        <p:variable name="href-document" as="xs:string" select="p:urify(/*/@href, $base-uri-load-list)"/>
        <p:variable name="force-xdm" as="xs:boolean" select="(xs:boolean(/*/@force-xdm), $global-force-xdm)[1]"/>
        <p:variable name="fail-on-error" as="xs:boolean" select="(xs:boolean(/*/@fail-on-error), $global-fail-on-error)[1]"/>

        <!-- Load the document, fail on loading errors if requested: -->
        <p:choose>
          <p:when test="$fail-on-error">
            <local:load href-document="{$href-document}"/>
          </p:when>
          <p:otherwise>
            <p:try>
              <p:output sequence="true"/>
              <local:load href-document="{$href-document}"/>
              <p:catch>
                <p:output sequence="true"/>
                <p:sink/>
              </p:catch>
            </p:try>
          </p:otherwise>
        </p:choose>

        <!-- If there is a document loaded (hence the p:for-each), check if we need to force the file to XDM format. -->
        <p:for-each>
          <p:variable name="is-xdm" as="xs:boolean" select="if (. instance of document-node()) then exists(/*) else false()"/>
          <p:if test="$force-xdm and not($is-xdm)">
            <local:force-xdm filename-modifier="-{$load-list-position}" fail-on-error="{$fail-on-error}"/>
          </p:if>
        </p:for-each>

      </p:when>

      <!-- Load file from a zip: -->
      <!-- TBD -->

      <!-- Unrecognized. Let it be. -->
      <p:otherwise>
        <p:output sequence="true"/>
        <p:sink/>
      </p:otherwise>


    </p:choose>

  </p:for-each>


  <!-- ================================================================== -->

  <p:wrap-sequence wrapper="TEMPWRAPPER"/>
  <p:add-attribute attribute-name="morgana-version" attribute-value="{p:system-property('p:product-name')} {p:system-property('p:product-version')}"/>

</p:declare-step>
