<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.ixh_qhc_z1c"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--~	
       Module for handling macro definitions and expansions.
       
       * Macro's are written as `${...}` or `{$...}`. 
       * Their value comes from a `map(macro-name, value)`
       * Macro values can reference other macros
       * A macro reference can be followed by flags, like ${MACRONAME:uc:compact}
       * You can auto-process a document or element with <*:macrodefs> as first children
	-->
  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="xtlc:macrodef-start-character" as="xs:string" select="'$'"/>

  <!-- Flags: -->
  <xsl:variable name="xtlc:macrodef-flag-upper-case" as="xs:string" select="'uc'"/>
  <xsl:variable name="xtlc:macrodef-flag-lower-case" as="xs:string" select="'lc'"/>
  <xsl:variable name="xtlc:macrodef-flag-compact" as="xs:string" select="'compact'"/>
  <xsl:variable name="xtlc:macrodef-flag-normalize" as="xs:string" select="'normalize'"/>
  <xsl:variable name="xtlc:macrodef-flag-filename-safe" as="xs:string" select="'fns'"/>
  <xsl:variable name="xtlc:macrodef-flag-filename-safe-extra" as="xs:string" select="'fnsx'"/>

  <!-- Standard macro definitions (see function xtlc:get-standard-macrodef-map()): -->
  <xsl:variable name="xtlc:macrodef-standard-datetimeiso" as="xs:string" select="'DATETIMEISO'"/>
  <xsl:variable name="xtlc:macrodef-standard-date" as="xs:string" select="'DATE'"/>
  <xsl:variable name="xtlc:macrodef-standard-date-compact" as="xs:string" select="'DATECOMPACT'"/>
  <xsl:variable name="xtlc:macrodef-standard-time" as="xs:string" select="'TIME'"/>
  <xsl:variable name="xtlc:macrodef-standard-time-compact" as="xs:string" select="'TIMECOMPACT'"/>
  <xsl:variable name="xtlc:macrodef-standard-time-short" as="xs:string" select="'TIMESHORT'"/>
  <xsl:variable name="xtlc:macrodef-standard-time-short-compact" as="xs:string" select="'TIMESHORTCOMPACT'"/>

  <xsl:mode name="local:mode-expand-macro-definitions" on-no-match="shallow-copy"/>

  <!-- ======================================================================= -->
  <!-- EXPANSION OF MACRO DEFINITIONS: -->

  <xsl:function name="xtlc:expand-macrodefs" as="xs:string">
    <!--~ 
      Expands a string value against the macro definitions in $macrodef-map. Checks for circular references.
    -->
    <xsl:param name="text" as="xs:string"/>
    <xsl:param name="macrodef-map" as="map(xs:string, xs:string)"/>

    <xsl:sequence select="local:expand-macrodefs($text, $macrodef-map, ())"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:expand-macrodefs" as="xs:string">
    <!--
      This function actually expands the macro definitions. It uses an additional parameter to check for circular references.
    -->
    <xsl:param name="text" as="xs:string"/>
    <xsl:param name="macrodef-map" as="map(xs:string, xs:string)"/>
    <xsl:param name="visited-parameters" as="xs:string*"/>

    <xsl:choose>
      <xsl:when test="contains($text, $xtlc:macrodef-start-character)">
        <xsl:variable name="substituted-parts" as="xs:string*">

          <!-- First check for doubled quotes with $ signs before or after. Make this into single quotes: -->
          <xsl:analyze-string select="$text" regex="\$\{{\{{|\{{\{{\$">
            <xsl:matching-substring>
              <xsl:choose>
                <xsl:when test=". eq '${{'">
                  <xsl:sequence select="'${'"/>
                </xsl:when>
                <xsl:when test=". eq '{{$'">
                  <xsl:sequence select="'{$'"/>
                </xsl:when>
                <xsl:otherwise>
                  <!-- Should not occur... -->
                  <xsl:sequence select="."/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:matching-substring>

            <xsl:non-matching-substring>
              <!-- Check all other texts for ${...} and {$...} patterns and substitute the bastards: -->
              <xsl:analyze-string select="." regex="\$\{{(\S+?)\}}|\{{\$(\S+?)\}}">
                <xsl:matching-substring>
                  <xsl:variable name="parameter-name-and-flags" as="xs:string"
                    select="if (regex-group(1) ne '') then regex-group(1) else regex-group(2)"/>
                  <xsl:variable name="parameter-parts" as="xs:string+" select="tokenize($parameter-name-and-flags, ':')[.]"/>

                  <xsl:variable name="parameter-name" as="xs:string" select="$parameter-parts[1]"/>
                  <xsl:variable name="parameter-flags" as="xs:string*" select="subsequence($parameter-parts, 2)"/>
                  <xsl:choose>
                    <xsl:when test="$parameter-name = $visited-parameters">
                      <xsl:call-template name="xtlc:raise-error">
                        <xsl:with-param name="msg-parts" select="('Circular macro definition reference for ', xtlc:q($parameter-name))"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="map:contains($macrodef-map, $parameter-name)">
                      <xsl:variable name="macro-value" as="xs:string"
                        select="local:process-macrodef-flags(string($macrodef-map($parameter-name)[1]), $parameter-flags)"/>
                      <xsl:sequence select="local:expand-macrodefs($macro-value, $macrodef-map, ($visited-parameters, $parameter-name))"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:call-template name="xtlc:raise-error">
                        <xsl:with-param name="msg-parts" select="('Macro definition not found: ', xtlc:q($parameter-name))"/>
                      </xsl:call-template>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                  <xsl:sequence select="."/>
                </xsl:non-matching-substring>
              </xsl:analyze-string>
            </xsl:non-matching-substring>

          </xsl:analyze-string>
        </xsl:variable>

        <xsl:sequence select="string-join($substituted-parts)"/>
      </xsl:when>

      <!-- No macro definition start character found in the text, just return what it was… -->
      <xsl:otherwise>
        <xsl:sequence select="$text"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:process-macrodef-flags" as="xs:string">
    <!-- Processes any macrodef flags that are on a macro reference. -->
    <xsl:param name="value" as="xs:string"/>
    <xsl:param name="flags" as="xs:string*"/>

    <xsl:choose>
      <xsl:when test="empty($flags)">
        <xsl:sequence select="$value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="current-flag" as="xs:string?" select="$flags[1]"/>
        <xsl:variable name="value-processed" as="xs:string">
          <xsl:choose>
            <xsl:when test="$current-flag eq $xtlc:macrodef-flag-upper-case">
              <xsl:sequence select="upper-case($value)"/>
            </xsl:when>
            <xsl:when test="$current-flag eq $xtlc:macrodef-flag-lower-case">
              <xsl:sequence select="lower-case($value)"/>
            </xsl:when>
            <xsl:when test="$current-flag eq $xtlc:macrodef-flag-compact">
              <xsl:sequence select="replace($value, '\s', '')"/>
            </xsl:when>
            <xsl:when test="$current-flag eq $xtlc:macrodef-flag-normalize">
              <xsl:sequence select="normalize-space($value)"/>
            </xsl:when>
            <xsl:when test="$current-flag eq $xtlc:macrodef-flag-filename-safe">
              <xsl:sequence select="xtlc:str2filename-safe($value)"/>
            </xsl:when>
            <xsl:when test="$current-flag eq $xtlc:macrodef-flag-filename-safe-extra">
              <xsl:sequence select="xtlc:str2filename-safe($value) => replace('\s', '_')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="xtlc:raise-error">
                <xsl:with-param name="msg-parts" select="('Unrecognized macro definition flag: ', xtlc:q($current-flag))"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="local:process-macrodef-flags($value-processed, subsequence($flags, 2))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- ======================================================================= -->
  <!-- STANDARD MACRO DEFINITIONS: -->

  <xsl:function name="xtlc:get-standard-macrodef-map" as="map(xs:string, xs:string)">
    <!--~ Returns a map with standard macro definitions.  -->
    <xsl:variable name="date-time" as="xs:dateTime" select="current-dateTime()"/>
    <xsl:map>
      <xsl:map-entry key="$xtlc:macrodef-standard-datetimeiso" select="string($date-time)"/>
      <xsl:map-entry key="$xtlc:macrodef-standard-date" select="format-dateTime($date-time, '[Y0001]-[M01]-[D01]')"/>
      <xsl:map-entry key="$xtlc:macrodef-standard-date-compact" select="format-dateTime($date-time, '[Y0001][M01][D01]')"/>
      <xsl:map-entry key="$xtlc:macrodef-standard-time" select="format-dateTime($date-time, '[H01]:[m01]:[s01]')"/>
      <xsl:map-entry key="$xtlc:macrodef-standard-time-compact" select="format-dateTime($date-time, '[H01][m01][s01]')"/>
      <xsl:map-entry key="$xtlc:macrodef-standard-time-short" select="format-dateTime($date-time, '[H01]:[m01]')"/>
      <xsl:map-entry key="$xtlc:macrodef-standard-time-short-compact" select="format-dateTime($date-time, '[H01][m01]')"/>
    </xsl:map>
  </xsl:function>

  <!-- ======================================================================= -->
  <!-- HELPER FUNCTIONS/TEMPLATES: -->

  <xsl:function name="xtlc:add-macrodefs" as="map(xs:string, xs:string)">
    <!--Merges two macro definition maps, taking care that newer definitions override existing ones.  -->
    <xsl:param name="existing-macrodefs" as="map(xs:string, xs:string)"/>
    <xsl:param name="new-macrodefs" as="map(xs:string, xs:string)?"/>

    <xsl:sequence select="map:merge(($existing-macrodefs, $new-macrodefs), map{'duplicates': 'use-last'})"/>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template name="xtlc:macrodefs-as-comment">
    <!-- Outputs a comment showing the contents of $macrodef-map.  -->
    <xsl:param name="macrodef-map" as="map(xs:string, xs:string)" required="yes"/>
    
    <xsl:variable name="lf" as="xs:string" select="'&#10;'"/>
    <xsl:variable name="parts" as="xs:string*">
      <xsl:for-each select="map:keys($macrodef-map)">
        <xsl:sort select="."/>
        <xsl:variable name="name" as="xs:string" select="."/>
        <xsl:sequence select="$name || '=' || xtlc:q($macrodef-map($name))"/>
      </xsl:for-each>      
    </xsl:variable>
    <xsl:comment>{$lf}{string-join($parts, $lf)}{$lf}</xsl:comment>
  </xsl:template>
  
  <!-- ======================================================================= -->
  <!-- EXPANSION OF MACRO DEFINITIONS IN AN XML DOCUMENT -->

  <xsl:template name="xtlc:expand-macro-definitions">
    <!-- Expands all macrodefs in a node (recursively). -->
    <xsl:param name="in" as="node()" required="false" select="."/>
    <xsl:param name="macrodef-map" as="map(xs:string, xs:string)" required="false" select="map{}"/>
    <xsl:param name="expand-in-text" as="xs:boolean" required="false" select="true()"/>
    <xsl:param name="expand-in-attributes" as="xs:boolean" required="false" select="true()"/>
    <xsl:param name="use-local-macrodefs" as="xs:boolean" required="false" select="true()">
      <!-- Check for <*:macrodefs> as first child and process this accordingly -->
    </xsl:param>
    <xsl:param name="add-macrodef-comments" as="xs:boolean" required="false" select="false()"/>

    <xsl:apply-templates select="$in" mode="local:mode-expand-macro-definitions">
      <xsl:with-param name="macrodef-map" select="$macrodef-map" tunnel="true"/>
      <xsl:with-param name="expand-in-text" select="$expand-in-text" tunnel="true"/>
      <xsl:with-param name="expand-in-attributes" select="$expand-in-attributes" tunnel="true"/>
      <xsl:with-param name="use-local-macrodefs" select="$use-local-macrodefs" tunnel="true"/>
      <xsl:with-param name="add-macrodef-comments" select="$add-macrodef-comments" tunnel="true"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="*[local:has-local-macrodefs(.)]" mode="local:mode-expand-macro-definitions">
    <xsl:param name="use-local-macrodefs" as="xs:boolean" required="true" tunnel="true"/>
    <xsl:param name="macrodef-map" as="map(xs:string, xs:string)" required="true" tunnel="true"/>
    <xsl:param name="add-macrodef-comments" as="xs:boolean" required="true" tunnel="true"/>
    
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>

      <xsl:choose>
        <xsl:when test="$use-local-macrodefs">
          <xsl:variable name="macrodefs-element" as="element()" select="*:macrodefs[1]"/>
          <xsl:variable name="new-macrodefs" as="map(xs:string, xs:string)">
            <xsl:variable name="macrodef-elements" as="element()+" select="$macrodefs-element/*:macrodef[exists(@name[normalize-space(.) ne ''])]"/>
            <xsl:map>
              <!-- Use grouping to prevent double macrodef names causing errors. -->
              <xsl:for-each-group select="$macrodef-elements" group-by="string(@name)">
                <xsl:variable name="macrodef-element" as="element()" select="current-group()[last()]"/>
                <xsl:map-entry key="current-grouping-key()" select="string($macrodef-element/@value)"/>
              </xsl:for-each-group>
            </xsl:map>
          </xsl:variable>
          <xsl:variable name="current-macrodefs" as="map(xs:string, xs:string)" select="xtlc:add-macrodefs($macrodef-map, $new-macrodefs)"/>
          <xsl:if test="$add-macrodef-comments">
            <xsl:call-template name="xtlc:macrodefs-as-comment">
              <xsl:with-param name="macrodef-map" select="$current-macrodefs"/>
            </xsl:call-template>
          </xsl:if>
          <xsl:apply-templates select="node() except $macrodefs-element" mode="#current">
            <xsl:with-param name="macrodef-map" select="$current-macrodefs" tunnel="true"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="#current"/>
        </xsl:otherwise>  
      </xsl:choose>

    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="@*[contains(., $xtlc:macrodef-start-character)]" mode="local:mode-expand-macro-definitions">
    <xsl:param name="macrodef-map" as="map(xs:string, xs:string)" required="true" tunnel="true"/>
    <xsl:param name="expand-in-attributes" as="xs:boolean" required="true" tunnel="true"/>

    <xsl:choose>
      <xsl:when test="$expand-in-attributes">
        <xsl:attribute name="{node-name(.)}" select="xtlc:expand-macrodefs(string(.), $macrodef-map)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="text()[contains(., $xtlc:macrodef-start-character)]" mode="local:mode-expand-macro-definitions">
    <xsl:param name="macrodef-map" as="map(xs:string, xs:string)" required="true" tunnel="true"/>
    <xsl:param name="expand-in-text" as="xs:boolean" required="true" tunnel="true"/>

    <xsl:choose>
      <xsl:when test="$expand-in-text">
        <xsl:value-of select="xtlc:expand-macrodefs(string(.), $macrodef-map)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:has-local-macrodefs" as="xs:boolean">
    <!-- Returns true() if the first child element (without non-whitespace text nodes before it) is a <*:macrodefs> 
         and this element has valid <*:macrodef> children  -->
    <xsl:param name="elm" as="element()"/>

    <xsl:variable name="macrodefs-element" as="element()?" select="(($elm/(text()[normalize-space() ne ''] | *))[1])/self::*:macrodefs"/>
    <xsl:sequence select="exists($macrodefs-element/*:macrodef[exists(@name[normalize-space(.) ne ''])])"/>
  </xsl:function>

</xsl:stylesheet>
