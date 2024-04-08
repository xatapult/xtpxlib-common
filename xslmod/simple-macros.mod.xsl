<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:local="#local.oxn_n4k_bzb" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Support code for simple macro expansion in strings, e.g. $NAME.
       To stop a macro from expanding, double the $ character ($$NAME becomes $NAME).
       
       What is expanded must be in a map formatted as map{macro: expansion}, e.g. map{'NAME': 'thenameofthething'}
       
       Macros in the string must start with the xtlc:simpleMacroStart character ($).
       
       DEPRECATED: Consider using macrodefs.mod.xsl instead! There are bugs in the macro expansion (that will not be solved for now).
  -->
  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="xtlc:simple-macro-start-character" as="xs:string" select="'$'"/>

  <!-- ======================================================================= -->

  <xsl:function name="xtlc:expand-simple-macros" as="xs:string">
    <!--~ Expands simple macro's in a string with values. All macros to expand must start with 
          $xtlc:simple-macro-start-character ($), for instance: $DATE.
          
          The substitution values are in a map. The keys must be the macro strings. 
          For instance: map{'DATE': '2023-04-04', 'TIME': '16:04:35'}
    -->
    <xsl:param name="in" as="xs:string">
      <!--~ The string to convert. -->
    </xsl:param>
    <xsl:param name="macros-map" as="map(xs:string, xs:string)">
      <!--~ The map with the macro/substitution values. -->
    </xsl:param>
    <xsl:param name="filename-safe" as="xs:boolean">
      <!--~ Whether to make all substitutions "filename safe", replacing all invalid characters for a 
            file/directory name with an underscore. Use this when replacing macros in file/directory name strings. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="not(contains($in, $xtlc:simple-macro-start-character)) or (map:size($macros-map) eq 0)">
        <!-- Nothing to do: -->
        <xsl:sequence select="$in"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- Handle the first key we can get (and recurse until the map is exhausted): -->
        <xsl:variable name="key" as="xs:string" select="map:keys($macros-map)[1]"/>
        <!-- Get the substitution value. This is not as straightforward as it may sound: The \ and $ character in 
             replacements have special meanings in regular expression replacements. So we need to escape these 
             with a \ in front. And since we're doing this with regular expression replacements, we have to make 
             sure the characters are escaped here also...
             - replace('\\', '\\\\') ==> Replace all occurrences of a \ with \\
             - replace('\$', '\\\$') ==> Replace all occurrences of a $ with \$
        -->
        <xsl:variable name="substitutionRaw" as="xs:string" select="$macros-map($key)"/>
        <xsl:variable name="substitutionSafe" as="xs:string" select="if ($filename-safe) then xtlc:str2filename-safe($substitutionRaw, '_') else $substitutionRaw"/>
        <xsl:variable name="substitution" as="xs:string" select="$substitutionSafe => replace('\\', '\\\\') => replace('\$', '\\\$')"/>

        <!-- Turn the $macro value into a regular expression. Since we have to deal with the $$macro variant as well,
             we create a regular expression for this too. -->
        <xsl:variable name="regexp-macro-expand" as="xs:string" select="xtlc:str2regexp($xtlc:simple-macro-start-character || $key, false())"/>
        <xsl:variable name="regexp-macro-no-expand" as="xs:string"
          select="xtlc:str2regexp($xtlc:simple-macro-start-character || $xtlc:simple-macro-start-character || $key, false())"/>

        <!-- Now go and substitute the macro: -->
        <xsl:variable name="out-parts" as="xs:string*">
          <xsl:analyze-string select="$in" regex="{$regexp-macro-no-expand}">
            <xsl:matching-substring>
              <!-- We found $$macro. Turn this into a single $:-->
              <xsl:sequence select="substring(., 2)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <!-- A part of the string that does not contain $$macro. Substitute $macro in this string:  -->
              <xsl:sequence select="replace(., $regexp-macro-expand, $substitution)"/>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:variable>
        <xsl:variable name="inSubstituted" as="xs:string" select="string-join($out-parts)"/>

        <!-- And now recurse to substitute the other macros: -->
        <xsl:sequence select="xtlc:expand-simple-macros($inSubstituted, map:remove($macros-map, $key), $filename-safe)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="xtlc:expand-simple-macros" as="xs:string">
    <!--~ Expands simple macro's in a string with values. See xtlc:expand-simple-macros#3 -->
    <xsl:param name="in" as="xs:string">
      <!--~ The string to convert. -->
    </xsl:param>
    <xsl:param name="macros-map" as="map(xs:string, xs:string)">
      <!--~ The map with the macro/substitution values. -->
    </xsl:param>
    
    <xsl:sequence select="xtlc:expand-simple-macros($in, $macros-map, false())"/>
  </xsl:function>
  
</xsl:stylesheet>
