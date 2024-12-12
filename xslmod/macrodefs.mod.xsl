<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.ixh_qhc_z1c"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--~	
       Module for handling macro definitions.
       
       A macro definition is a simple `name=value` construct. They are passed around in maps (`map(xs:string, xs:string)`). 
       
       The `xtlc:expand-macrodefs()` function expands macro definition references within strings by using `${…}` or `{$…}`. 
       To prevent the expansion of these constructions, simply double the opening curly brace. All referenced macro definitions must exist, 
       otherwise an error will be raised. 

       Macro definitions can reference other macro definitions.

       Additionally, you can modify the value of a macro by appending one or more flags (separated by colons), for instance `${MACRO:cap:fnsx}`. 
       For more information on the available flags, refer to the `$xtlc:macrodef-flag-*` global variables.
       
       There are a number of standard macros that can be used. See the `$xtlc:macrodef-standard-*` global variables.
	-->
  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="xtlc:macrodef-start-character" as="xs:string" select="'$'" visibility="public">
    <!--~ Character that starts a macro definition reference. -->
  </xsl:variable>
  <xsl:variable name="xtlc:macrodef-flag-separator-character" as="xs:string" select="':'" visibility="public">
    <!--~ Character that separates a macro reference from its flags. -->
  </xsl:variable>

  <!-- Flags: -->
  <xsl:variable name="xtlc:macrodef-flag-upper-case" as="xs:string" select="'uc'" visibility="public">
    <!--~ Macro flag: upper-case  -->
  </xsl:variable>
  <xsl:variable name="xtlc:macrodef-flag-lower-case" as="xs:string" select="'lc'" visibility="public">
    <!--~ Macro flag: lower-case -->
  </xsl:variable>
  <xsl:variable name="xtlc:macrodef-flag-capitalize" as="xs:string" select="'cap'" visibility="public">
    <!--~ Macro flag: capitalize (upper-case first character) -->
  </xsl:variable>
  <xsl:variable name="xtlc:macrodef-flag-compact" as="xs:string" select="'compact'" visibility="public">
    <!--~ Macro flag: remove all whitespace -->
  </xsl:variable>
  <xsl:variable name="xtlc:macrodef-flag-normalize" as="xs:string" select="'normalize'" visibility="public">
    <!--~ Macro flag: normalize space -->
  </xsl:variable>
  <xsl:variable name="xtlc:macrodef-flag-filename-safe" as="xs:string" select="'fns'" visibility="public">
    <!--~ Macro flag: make filename safe (replace all characters forbidden in file/directory names with underscores) -->
  </xsl:variable>
  <xsl:variable name="xtlc:macrodef-flag-filename-safe-extra" as="xs:string" select="'fnsx'" visibility="public">
    <!--~ Macro flag: make filename safe, extended (replace all characters forbidden in file/directory names and all whitespace with underscores) -->
  </xsl:variable>

  <!-- Standard macro definitions (see function xtlc:get-standard-macrodef-map()): -->
  <xsl:variable name="xtlc:macrodef-standard-datetimeiso" as="xs:string" select="'DATETIMEISO'" visibility="public">
    <!--~ Standard macro: date/time in ISO format -->
  </xsl:variable>
  <xsl:variable name="xtlc:macrodef-standard-date" as="xs:string" select="'DATE'" visibility="public">
    <!--~ Standard macro: date only (`YYYY-MM-DD`) -->
  </xsl:variable>
  <xsl:variable name="xtlc:macrodef-standard-date-compact" as="xs:string" select="'DATECOMPACT'" visibility="public">
    <!--~ Standard macro: date only, compact (`YYYYMMDD`) -->
  </xsl:variable>
  <xsl:variable name="xtlc:macrodef-standard-time" as="xs:string" select="'TIME'" visibility="public">
    <!--~ Standard macro: time only (`hh:mm:ss`) -->
  </xsl:variable>
  <xsl:variable name="xtlc:macrodef-standard-time-compact" as="xs:string" select="'TIMECOMPACT'" visibility="public">
    <!--~ Standard macro: time only, compact (`hhmmss`) -->
  </xsl:variable>
  <xsl:variable name="xtlc:macrodef-standard-time-short" as="xs:string" select="'TIMESHORT'" visibility="public">
    <!--~ Standard macro: time only without seconds (`hh:mm`) -->
  </xsl:variable>
  <xsl:variable name="xtlc:macrodef-standard-time-short-compact" as="xs:string" select="'TIMESHORTCOMPACT'" visibility="public">
    <!--~ Standard macro: time only without seconds, compact (`hhmm`) -->
  </xsl:variable>

  <!-- ======================================================================= -->
  <!-- LOCAL DECLARATIONS: -->

  <xsl:mode name="local:mode-expand-macro-definitions" on-no-match="shallow-copy" visibility="private"/>

  <!-- ======================================================================= -->
  <!-- EXPANSION OF MACRO DEFINITIONS: -->

  <xsl:function name="xtlc:expand-macrodefs" as="xs:string" visibility="public">
    <!--~ 
      Expands macro definition references in a string against the macro definitions in `$macrodef-map`. Checks for circular references.
    -->
    <xsl:param name="text" as="xs:string"/>
    <xsl:param name="macrodef-map" as="map(xs:string, xs:string)"/>

    <xsl:sequence select="local:expand-macrodefs($text, $macrodef-map, ())"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:expand-macrodefs" as="xs:string" visibility="private">
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
                  <xsl:variable name="parameter-parts" as="xs:string+"
                    select="tokenize($parameter-name-and-flags, xtlc:str2regexp($xtlc:macrodef-flag-separator-character))[.]"/>

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

  <xsl:function name="local:process-macrodef-flags" as="xs:string" visibility="private">
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
            <xsl:when test="$current-flag eq $xtlc:macrodef-flag-capitalize">
              <xsl:sequence select="xtlc:capitalize($value)"/>
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

  <xsl:function name="xtlc:get-standard-macrodef-map" as="map(xs:string, xs:string)" visibility="public">
    <!--~ Returns a map with standard macro definitions. See the `$xtlc:macrodef-standard-*` global variable definitions. -->
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

  <xsl:function name="xtlc:merge-macrodefs" as="map(xs:string, xs:string)" visibility="public">
    <!--~ Merges multiple macro definition maps, taking care that newer definitions override existing ones. 
          Will return an empty map if the input is the empty sequence. -->
    <xsl:param name="macrodefs" as="map(xs:string, xs:string)*">
      <!--~ The macro definition maps to merge. -->
    </xsl:param>

    <xsl:sequence select="map:merge($macrodefs, map{'duplicates': 'use-last'})"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="xtlc:macrodefs-as-comment" visibility="public">
    <!--~ Outputs a simple comment showing the contents of `$macrodef-map`.  -->
    <xsl:param name="macrodef-map" as="map(xs:string, xs:string)" required="yes">
      <!--~ The macro definitions to show in the comment. -->
    </xsl:param>

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
    <!--~ Expands macro definitions in text nodes and/or attribute values.
      
          The template checks for `<:macrodefs>` elements that are the first child of any element. 
          If so, any `<:macrodef>` children are used to define (or override) macro definitions. These elements can be in any namespace.
          
          See also `xsdmod/macrodefs.mod.xsd`.
    
          You can customize its functionality by using the template parameters.
    -->
    <xsl:param name="in" as="node()" required="false" select=".">
      <!--~ The node for which to expand the macro definitions. Must be an element or a document node. -->
    </xsl:param>
    <xsl:param name="use-standard-macrodefs" as="xs:boolean" required="false" select="true()">
      <!--~ Whether to use the standard macro definitions. -->
    </xsl:param>
    <xsl:param name="macrodefs" as="map(xs:string, xs:string)*" required="false" select="()">
      <!--~ Any initial macro definitions. -->
    </xsl:param>
    <xsl:param name="expand-in-text" as="xs:boolean" required="false" select="true()">
      <!--~ Whether to expand the macro definitions in text nodes. -->
    </xsl:param>
    <xsl:param name="expand-in-attributes" as="xs:boolean" required="false" select="true()">
      <!--~ Whether to expand the macro definitions in attributes. -->
    </xsl:param>
    <xsl:param name="use-local-macrodefs" as="xs:boolean" required="false" select="true()">
      <!--~ Check for `<*:macrodefs>` element as first child and process accordingly -->
    </xsl:param>
    <xsl:param name="add-macrodef-comments" as="xs:boolean" required="false" select="false()">
      <!--~ Whether to add a macro definition comment (summarizing all macro definitions) when a `<*:macrodefs>` element is processed. -->
    </xsl:param>

    <xsl:apply-templates select="$in" mode="local:mode-expand-macro-definitions">
      <xsl:with-param name="macrodef-map"
        select="xtlc:merge-macrodefs((if ($use-standard-macrodefs) then xtlc:get-standard-macrodef-map() else (), $macrodefs))" tunnel="true"/>
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
          <xsl:variable name="current-macrodefs" as="map(xs:string, xs:string)" select="xtlc:merge-macrodefs(($macrodef-map, $new-macrodefs))"/>
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
        <xsl:attribute name="{local-name(.)}" namespace="{namespace-uri(.)}" select="xtlc:expand-macrodefs(string(.), $macrodef-map)"/>
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

  <xsl:function name="local:has-local-macrodefs" as="xs:boolean" visibility="private">
    <!-- Returns true() if the first child element of $elm (without non-whitespace text nodes before it) is a <*:macrodefs> 
         and this element has valid <*:macrodef> children.  -->
    <xsl:param name="elm" as="element()"/>

    <xsl:variable name="macrodefs-element" as="element()?" select="(($elm/(text()[normalize-space() ne ''] | *))[1])/self::*:macrodefs"/>
    <xsl:sequence select="exists($macrodefs-element/*:macrodef[exists(@name[normalize-space(.) ne ''])])"/>
  </xsl:function>

</xsl:stylesheet>
