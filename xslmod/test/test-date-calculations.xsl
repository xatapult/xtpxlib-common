<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.xwl_k2s_2yb"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Tests for the more complex date calculations
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../general.mod.xsl"/>
  <xsl:include href="../date-time.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <test-date-calculations timestamp="{current-dateTime()}"> 
      <!--<xsl:call-template name="test">
        <xsl:with-param name="datestring" select="''"/>
        <xsl:with-param name="expected-weeknumber" select=""/>
        <xsl:with-param name="expected-weekday-number" select=""/>
      </xsl:call-template>-->
      <xsl:call-template name="test">
        <xsl:with-param name="datestring" select="'2023-07-21'"/>
        <xsl:with-param name="expected-weeknumber" select="29"/>
        <xsl:with-param name="expected-weekday-number" select="5"/>
      </xsl:call-template>
      <xsl:call-template name="test">
        <xsl:with-param name="datestring" select="'2023-01-01'"/>
        <xsl:with-param name="expected-weeknumber" select="52"/>
        <xsl:with-param name="expected-weekday-number" select="7"/>
      </xsl:call-template>
      
      <xsl:call-template name="test">
        <xsl:with-param name="datestring" select="'2000-01-01'"/>
        <xsl:with-param name="expected-weeknumber" select="52"/>
        <xsl:with-param name="expected-weekday-number" select="6"/>
      </xsl:call-template>
      <xsl:call-template name="test">
        <xsl:with-param name="datestring" select="'2000-02-29'"/>
        <xsl:with-param name="expected-weeknumber" select="9"/>
        <xsl:with-param name="expected-weekday-number" select="2"/>
      </xsl:call-template>
      <xsl:call-template name="test">
        <xsl:with-param name="datestring" select="'2000-03-01'"/>
        <xsl:with-param name="expected-weeknumber" select="9"/>
        <xsl:with-param name="expected-weekday-number" select="3"/>
      </xsl:call-template>
    
      <!-- From the https://beginnersbook.com/2013/04/calculating-day-given-date/ given examples: -->
      <xsl:call-template name="test">
        <xsl:with-param name="datestring" select="'1983-04-01'"/>
        <xsl:with-param name="expected-weeknumber" select="13"/>
        <xsl:with-param name="expected-weekday-number" select="5"/>
      </xsl:call-template>
      <xsl:call-template name="test">
        <xsl:with-param name="datestring" select="'2004-03-02'"/>
        <xsl:with-param name="expected-weeknumber" select="10"/>
        <xsl:with-param name="expected-weekday-number" select="2"/>
      </xsl:call-template>
      
      <!-- Some other randoms -->
      <xsl:call-template name="test">
        <xsl:with-param name="datestring" select="'2012-01-01'"/>
        <xsl:with-param name="expected-weeknumber" select="52"/>
        <xsl:with-param name="expected-weekday-number" select="7"/>
      </xsl:call-template>
    
    </test-date-calculations>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="test">
    <xsl:param name="datestring" as="xs:string" required="yes"/>
    <xsl:param name="expected-weekday-number" as="xs:integer" required="yes"/>
    <xsl:param name="expected-weeknumber" as="xs:integer" required="yes"/>

    <xsl:variable name="date" as="xs:date" select="xs:date($datestring)"/>
    <xsl:variable name="weekday-number" as="xs:integer" select="xtlc:weekday-number($date)"/>
    <xsl:variable name="weeknumber" as="xs:integer" select="xtlc:week-number($date)"/>

    <test date="{$date}" computed-weekday-number="{$weekday-number}" expected-weekday-number="{$expected-weekday-number}"
      computed-weeknumber="{$weeknumber}" expected-weeknumber="{$expected-weeknumber}">
      <xsl:if test="$weeknumber ne $expected-weeknumber">
        <ERROR>Weeknumber differs!</ERROR>
      </xsl:if>
      <xsl:if test="$weekday-number ne $expected-weekday-number">
        <ERROR>Weekday number differs!</ERROR>
      </xsl:if>
    </test>

  </xsl:template>


</xsl:stylesheet>
