<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.hgm_2fr_c3b"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!--	
     TBD:
     - expose expand text
     - doc (no namespace anymore!)
	-->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:mode name="local:mode-evaluate-parameters" on-no-match="deep-skip"/>

  <xsl:variable name="xtlc:parameter-group-separator" as="xs:string" select="'.'"/>

  <!-- ================================================================== -->
  <!--  -->

  <xsl:function name="xtlc:parameters-get" as="map(xs:string, xs:string*)">
    <xsl:param name="root-item" as="item()"/>
    <xsl:param name="filters" as="map(xs:string, xs:string*)?"/>

    <!-- Get the first *:parameters element at or underneath $root-item: -->
    <xsl:variable name="root" as="element()?" select="(xtlc:item2element($root-item, false())/descendant-or-self::*:parameters)[1]"/>
    <xsl:variable name="unexpanded-map" as="map(xs:string, xs:string*)">
      <xsl:map>
        <xsl:apply-templates select="$root/*" mode="local:mode-evaluate-parameters">
          <xsl:with-param name="filters" as="map(xs:string, xs:string*)?" tunnel="yes" select="$filters"/>
        </xsl:apply-templates>
        <xsl:sequence select="$filters"/>
      </xsl:map>
    </xsl:variable>
    <xsl:sequence select="local:expand-map($unexpanded-map)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="*:parameter[normalize-space(@name) ne '']" mode="local:mode-evaluate-parameters">
    <xsl:param name="prefix" as="xs:string?" required="no" tunnel="yes" select="()"/>
    <xsl:param name="filters" as="map(xs:string, xs:string*)?" required="yes" tunnel="yes"/>

    <xsl:variable name="parameter-name" as="xs:string" select="$prefix || local:normalize-name(@name)"/>
    <xsl:variable name="values" as="xs:string*">
      <xsl:for-each select="*:value[local:check-filters(., $filters)]">
        <xsl:sequence select="string(.)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:map-entry key="$parameter-name" select="$values"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="*:group[normalize-space(@name) ne '']" mode="local:mode-evaluate-parameters">
    <xsl:param name="prefix" as="xs:string?" required="no" select="()" tunnel="yes"/>
    <xsl:apply-templates select="*" mode="#current">
      <xsl:with-param name="prefix" as="xs:string" tunnel="yes" select="$prefix || local:normalize-name(@name) || $xtlc:parameter-group-separator"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- SUPPORT: -->

  <xsl:function name="local:normalize-name" as="xs:string">
    <xsl:param name="name-raw" as="xs:string"/>
    <xsl:sequence select="$name-raw => normalize-space() => translate(' ', '_')"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:check-filters" as="xs:boolean">
    <xsl:param name="value-element" as="element()"/>
    <xsl:param name="filters" as="map(xs:string, xs:string*)?"/>

    <!-- Check all attributes on the value element. If there is a corresponding entry in $filters, the value of
      the attribute must be one of the values in the map under this key. -->
    <xsl:variable name="attribute-matches-filters" as="xs:boolean*">
      <xsl:if test="exists($filters)">
        <xsl:for-each select="$value-element/@*">
          <xsl:variable name="filter-name" as="xs:string" select="local-name(.)"/>
          <xsl:if test="map:contains($filters, $filter-name)">
            <xsl:sequence select="xtlc:str2seq(.) = $filters($filter-name)"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </xsl:variable>

    <!-- A value checks out if there were either no matches (no attributes on $value-element were mentioned in $filters) or 
      all must be true: -->
    <xsl:sequence select="empty($attribute-matches-filters) or (every $match in $attribute-matches-filters satisfies $match)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:expand-map" as="map(xs:string, xs:string*)?">
    <xsl:param name="parameter-map" as="map(xs:string, xs:string*)"/>

    <xsl:map>
      <xsl:for-each select="map:keys($parameter-map)">
        <xsl:variable name="key" as="xs:string" select="."/>
        <xsl:variable name="values" as="xs:string*">
          <xsl:for-each select="$parameter-map($key)">
            <xsl:sequence select="local:expand-text(., $parameter-map, $key)"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:map-entry key="$key" select="$values"/>
      </xsl:for-each>
    </xsl:map>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:expand-text" as="xs:string">
    <xsl:param name="text" as="xs:string"/>
    <xsl:param name="parameter-map" as="map(xs:string, xs:string*)"/>
    <xsl:param name="visited-parameters" as="xs:string*"/>

    <xsl:variable name="substituted-parts" as="xs:string*">
      <xsl:analyze-string select="$text" regex="\$\{{(\S+)\}}|\{{\$(\S+)\}}">
        <xsl:matching-substring>
          <xsl:variable name="parameter-name" as="xs:string" select="if (regex-group(1) ne '') then regex-group(1) else regex-group(2)"/>
          <xsl:choose>
            <xsl:when test="$parameter-name = $visited-parameters">
              <xsl:call-template name="xtlc:raise-error">
                <xsl:with-param name="msg-parts" select="('Cyclic parameter reference: ', xtlc:q($parameter-name))"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="map:contains($parameter-map, $parameter-name)">
              <xsl:sequence
                select="local:expand-text(string-join($parameter-map($parameter-name)), $parameter-map, ($visited-parameters, $parameter-name))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:sequence select="."/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    <xsl:sequence select="string-join($substituted-parts)"/>
  </xsl:function>
</xsl:stylesheet>
