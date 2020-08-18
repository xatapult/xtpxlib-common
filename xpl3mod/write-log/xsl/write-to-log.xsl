<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.nm5_ymg_smb"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Writes an entry to a log file. Either creating a new one or adding an existing one. 
       
       Input doesn't matter, output will be the new log file.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->
  
  <xsl:output method="xml" indent="no" encoding="UTF-8"/>
  
  <xsl:mode on-no-match="fail"/>
  
  <!-- ================================================================== -->
  <!-- PARAMETERS: -->
  
  <xsl:param name="href-log" as="xs:string" required="yes"/>
  <xsl:param name="log-comments" as="xs:string*" required="yes"/>
  <xsl:param name="status" as="xs:string" required="yes"/>
  <xsl:param name="messages" as="xs:string+" required="yes"/>
  <xsl:param name="keep-entries" as="xs:integer" required="yes"/>
  <xsl:param name="additional-attributes" as="map(xs:QName, xs:string)?" required="yes"/>
  <xsl:param name="additional-elements" as="element()*" required="yes"/>
  
  <!-- ================================================================== -->
  
  <xsl:template match="/">
    
    <!-- Create the log entry: -->
    <xsl:variable name="new-log-entry" as="element()">
      <entry timestamp="{current-dateTime()}" status="{$status}">
        <xsl:if test="exists($additional-attributes)">
          <xsl:for-each select="map:keys($additional-attributes)">
            <xsl:attribute name="{.}" select="$additional-attributes(.)"/>
          </xsl:for-each>
        </xsl:if>
        <xsl:for-each select="$messages">
          <message>{.}</message>
        </xsl:for-each>
        <xsl:sequence select="$additional-elements"/>
      </entry>
    </xsl:variable>
    
    <!-- Log it: -->
    <xsl:choose>
      
      <!-- There is not a log file available. Create it: -->
      <xsl:when test="not(doc-available($href-log))">
        <log timestamp="{current-dateTime()}">
          <xsl:if test="exists($log-comments)">
            <xsl:comment>
              <xsl:text>&#10;</xsl:text>
              <xsl:for-each select="$log-comments">
                <xsl:value-of select=". || '&#10;'"/>
              </xsl:for-each>
            </xsl:comment>
          </xsl:if>
          <xsl:sequence select="$new-log-entry"/>
        </log>
      </xsl:when>
      
      <!-- Yes, there is already an existing log file, amend it: -->
      <xsl:otherwise>
        <xsl:for-each select="doc($href-log)/*">
          <xsl:copy>
            <xsl:sequence select="@* | comment()"/>
            <!-- Copy new message first: -->
            <xsl:sequence select="$new-log-entry"/>
            <!-- Copy existing messages: -->
            <xsl:choose>
              <xsl:when test="$keep-entries gt 0">
                <xsl:sequence select="entry[position() lt $keep-entries]"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="entry"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:copy>
        </xsl:for-each>
      </xsl:otherwise>
      
    </xsl:choose>
    
  </xsl:template>
  
</xsl:stylesheet>
