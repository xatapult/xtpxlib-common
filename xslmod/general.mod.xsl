<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:local="#local.btj_4bn_zhb" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--~
        XSLT library module with general constants and code.
	-->
  <!-- ================================================================== -->
  <!-- GLOBAL CONSTANTS: -->

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Date time formatting: -->

  <xsl:variable name="xtlc:default-dt-format" as="xs:string" select="'[Y]-[M01]-[D01] [H01]:[m01]:[s01]'">
    <!--~ Default date/time format string (`yyyy-mm-dd …`). -->
  </xsl:variable>
  <xsl:variable name="xtlc:default-dt-format-nl" as="xs:string" select="'[D01]-[M01]-[Y] [H01]:[m01]:[s01]'">
    <!--~ Date/time format string (Dutch: `dd-mm-yyyy …`). -->
  </xsl:variable>
  <xsl:variable name="xtlc:default-dt-format-en" as="xs:string" select="'[M01]-[D01]-[Y] [H01]:[m01]:[s01]'">
    <!--~ Date/time format string (English: `mm-dd-yyyy …`). -->
  </xsl:variable>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Language codes: -->
  <!-- Remark: The library currently supports only Dutch and English. -->

  <xsl:variable name="xtlc:language-nl" as="xs:string" select="'nl'">
    <!--~ Language code for Dutch -->
  </xsl:variable>
  <xsl:variable name="xtlc:language-en" as="xs:string" select="'en'">
    <!--~ Language code for English -->
  </xsl:variable>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Generic status/severity codes: -->

  <xsl:variable name="xtlc:status-info" as="xs:string" select="'info'">
    <!--~ Generic info (a.k.a. OK) status/severity code. -->
  </xsl:variable>
  <xsl:variable name="xtlc:status-warning" as="xs:string" select="'warning'">
    <!--~ Generic warning status/severity code. -->
  </xsl:variable>
  <xsl:variable name="xtlc:status-error" as="xs:string" select="'error'">
    <!--~ Generic error status/severity code. -->
  </xsl:variable>
  <xsl:variable name="xtlc:status-debug" as="xs:string" select="'debug'">
    <!--~ Generic debug status/severity code. -->
  </xsl:variable>
  <xsl:variable name="xtlc:status-codes" as="xs:string+" select="($xtlc:status-info, $xtlc:status-warning, $xtlc:status-error, $xtlc:status-debug)">
    <!--~ Sequence with all valid status codes.  -->
  </xsl:variable>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Others: -->

  <xsl:variable name="xtlc:namespace-xtlc-common" as="xs:string" select="namespace-uri-for-prefix('xtlc', doc('')/*)">
    <!--~Namespace used for `xtpxlib-common`.  -->
  </xsl:variable>

  <xsl:variable name="xtlc:internal-error-prompt" as="xs:string" select="'Internal error: '">
    <!--~ Add this in front of any internal error raised. -->
  </xsl:variable>

  <!-- ================================================================== -->
  <!-- GENERAL STRING HANDLING: -->

  <xsl:function name="xtlc:char-repeat" as="xs:string" visibility="public">
    <!--~ Returns a string with a single character repeated a given number of times. -->
    <xsl:param name="char" as="xs:string">
      <!--~ The first character of this string is the character to repeat. If empty, an empty string is returned. -->
    </xsl:param>
    <xsl:param name="repeat" as="xs:integer">
      <!--~ The number of repeats. If <= `0`, an empty string is returned.  -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="$repeat le 0">
        <xsl:sequence select="''"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="char-to-use" as="xs:string" select="substring($char, 1, 1)"/>
        <xsl:sequence select="string-join(for $c in 1 to $repeat return $char-to-use, '')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:q" as="xs:string" visibility="public">
    <!--~ Returns the input string quoted (`"$in"`) -->
    <xsl:param name="in" as="xs:string?">
      <!--~ String to convert. -->
    </xsl:param>

    <xsl:sequence select="concat('&quot;', $in, '&quot;')"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:capitalize" as="xs:string" visibility="public">
    <!--~ Capitalizes a string (makes the first character uppercase). -->
    <xsl:param name="in" as="xs:string">
      <!--~ The string to work on. -->
    </xsl:param>

    <xsl:sequence select="concat(upper-case(substring($in, 1, 1)), substring($in, 2))"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:prefix-to-length" as="xs:string" visibility="public">
    <!--~ Prefixes a string with a given character so it will get at least a given length. -->
    <xsl:param name="in" as="xs:string">
      <!--~ String to prefix -->
    </xsl:param>
    <xsl:param name="prefix-char" as="xs:string">
      <!--~ String to prefix with. Only first character is used. If empty, `*` is used. -->
    </xsl:param>
    <xsl:param name="length" as="xs:integer">
      <!--~ The length to reach. -->
    </xsl:param>

    <xsl:variable name="prefix-char-to-use" as="xs:string" select="if (string-length($prefix-char) lt 1) then '*' else substring($prefix-char, 1, 1)"/>
    <xsl:choose>
      <xsl:when test="string-length($in) ge $length">
        <xsl:sequence select="$in"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="prefix-string" as="xs:string" select="xtlc:char-repeat($prefix-char-to-use, $length - string-length($in))"/>
        <xsl:sequence select="concat($prefix-string, $in)"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:str2regexp" as="xs:string" visibility="public">
    <!--~ Turns a string into a regular expression that matches the input exactly. Optionally anchors the regular expression so
      the match will be on this string *only* (result starts with `^` and ends with `$`). -->
    <xsl:param name="in" as="xs:string?">
      <!--~ String to convert  -->
    </xsl:param>
    <xsl:param name="anchor" as="xs:boolean">
      <!--~ If true, the resulting string will be anchored (start with `^` and ends with `$`)  -->
    </xsl:param>

    <xsl:variable name="regexp-string" as="xs:string" select="replace(string($in), '([.\\?*+|\^${}()\[\]])', '\\$1')"/>
    <xsl:sequence select="if ($anchor) then ('^'  || $regexp-string || '$') else $regexp-string"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:str2regexp" as="xs:string" visibility="public">
    <!--~ Turns a string into a regular expression that matches the input exactly. -->
    <xsl:param name="in" as="xs:string?">
      <!--~ String to convert  -->
    </xsl:param>
    <xsl:sequence select="xtlc:str2regexp($in, false())"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:str2filename-safe" as="xs:string" visibility="public">
    <!--~ Replaces all characters in a string that are not allowed in filenames with another character.  -->
    <xsl:param name="in" as="xs:string?">
      <!--~ String to convert  -->
    </xsl:param>
    <xsl:param name="replace-char" as="xs:string?">
      <!--~ String to replace invalid characters with. Only first character is used. If empty, `_` is used. -->
    </xsl:param>

    <xsl:variable name="replace-char-to-use" as="xs:string"
      select="if (string-length($replace-char) lt 1) then '_' else substring($replace-char, 1, 1)"/>
    <xsl:sequence select="replace($in, '[\\/:*?&quot;&lt;&gt;|]', $replace-char-to-use)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:str2filename-safe" as="xs:string" visibility="public">
    <!--~ Replaces all characters in a string that are not allowed in filenames with an underscore.  -->
    <xsl:param name="in" as="xs:string?">
      <!--~ String to convert  -->
    </xsl:param>
    <xsl:sequence select="xtlc:str2filename-safe($in, '_')"/>
  </xsl:function>

  <!-- ================================================================== -->
  <!-- CONTEXT: -->

  <xsl:function name="xtlc:item2element" as="element()?" visibility="public">
    <!--~ 
      Tries to find the element belonging to a given item.
      
      * When the item is of type `xs:string` or `xs:anyURI`, it is assumed to be a document reference. The root element of this is returned.
      * When the item is of type `document-node()`, the root element of this document is returned
      * When the item is of type `element()`, this is returned
      
      You can choose whether to produce an error message or `()` when the item cannot be resolved.
    -->
    <xsl:param name="item" as="item()">
      <!--~ The item to work on -->
    </xsl:param>
    <xsl:param name="error-on-non-resolve" as="xs:boolean">
      <!--~ Whether to generate an error when `$item` could not be resolved. Otherwise, the function will return `()`. -->
    </xsl:param>

    <xsl:variable name="function-name-prompt" as="xs:string" select="'item2element: '"/>
    <xsl:choose>

      <!-- String or URI: -->
      <xsl:when test="($item instance of xs:string) or ($item instance of xs:anyURI)">
        <xsl:choose>
          <xsl:when test="doc-available($item)">
            <xsl:sequence select="doc($item)/*"/>
          </xsl:when>
          <xsl:when test="$error-on-non-resolve">
            <xsl:call-template name="xtlc:raise-error">
              <xsl:with-param name="msg-parts" select="($function-name-prompt, 'Document ', xtlc:q(string($item)), ' not found')"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <!-- Document: -->
      <xsl:when test="$item instance of document-node()">
        <xsl:sequence select="$item/*"/>
      </xsl:when>

      <!-- Element: -->
      <xsl:when test="$item instance of element()">
        <xsl:sequence select="$item"/>
      </xsl:when>

      <!-- Nothing recognizable... -->
      <xsl:when test="$error-on-non-resolve">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="($function-name-prompt, 'Could not resolve item to element')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:function>

  <!-- ================================================================== -->
  <!-- CONVERSIONS FROM STRING: -->

  <xsl:function name="xtlc:str2bln" as="xs:boolean" visibility="public">
    <!--~ 
      Safe conversion of a string into a boolean.
      
      When `$in` is empty or not convertible into a boolean, `$default` is returned.
    -->
    <xsl:param name="in" as="xs:string?">
      <!--~ String to convert. -->
    </xsl:param>
    <xsl:param name="default" as="xs:boolean">
      <!--~ Default value to return when $in is empty or cannot be converted. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="empty($in)">
        <xsl:sequence select="$default"/>
      </xsl:when>
      <xsl:when test="$in castable as xs:boolean">
        <xsl:sequence select="xs:boolean($in)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$default"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:str2int" as="xs:integer" visibility="public">
    <!--~ 
      Safe conversion of a string to an integer.
      
      When `$in` is empty or not convertible to an integer, `$default` is returned.
    -->
    <xsl:param name="in" as="xs:string?">
      <!--~ String to convert. -->
    </xsl:param>
    <xsl:param name="default" as="xs:integer">
      <!--~ Default value to return when $in is empty or cannot be converted. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="empty($in)">
        <xsl:sequence select="$default"/>
      </xsl:when>
      <xsl:when test="$in castable as xs:integer">
        <xsl:sequence select="xs:integer($in)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$default"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:str2seq" as="xs:string*" visibility="public">
    <!--~ Converts a string with a list of words into a sequence of words. -->
    <xsl:param name="in" as="xs:string?">
      <!--~ String to convert. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="empty($in)">
        <xsl:sequence select="()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="tokenize($in, '\s+')[.]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:str2id" as="xs:string" visibility="public">
    <!--~ 
      Turns a string into a valid identifier, adding a prefix.
      
      All characters that are not allowed in an identifier are converted into underscores. 
      
      When the result does not start with a letter or underscore, the prefix `id-` is added.
    -->
    <xsl:param name="in" as="xs:string">
      <!--~ String to convert. -->
    </xsl:param>
    <xsl:param name="prefix" as="xs:string?">
      <!--~ Prefix to apply. -->
    </xsl:param>

    <xsl:variable name="id" as="xs:string" select="replace(concat($prefix, $in), '[^a-zA-Z0-9_\-\.]', '_')"/>
    <xsl:choose>
      <xsl:when test="matches(substring($id, 1, 1), '[a-zA-Z_]')">
        <xsl:sequence select="$id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="concat('id-', $id)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:str2id" as="xs:string" visibility="public">
    <!--~ 
      Turns a string into a valid identifier.
      
      All characters that are not allowed in an identifier are converted into underscores. 
      
      When the result does not start with a letter or underscore, the prefix `id-` is added.
    -->
    <xsl:param name="in" as="xs:string">
      <!--~ String to convert. -->
    </xsl:param>

    <xsl:sequence select="xtlc:str2id($in, ())"/>
  </xsl:function>

  <!-- ================================================================== -->
  <!-- CONVERSIONS TO STRING: -->

  <xsl:function name="xtlc:att2str" as="xs:string" visibility="public">
    <!--~ Turns an attribute into a string representation, suitable for display (e.g. `name="value"`). -->
    <xsl:param name="att" as="attribute()?">
      <!--~ Attribute to convert. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="empty($att)">
        <xsl:sequence select="''"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="concat(name($att), '=', xtlc:q($att))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:elm2str" as="xs:string" visibility="public">
    <!--~ Turns an element into a descriptive string (the element with all its attributes, excluding schema references). -->
    <xsl:param name="elm" as="element()?">
      <!--~ Element to convert  -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="empty($elm)">
        <xsl:sequence select="''"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="description-parts" as="xs:string+">
          <xsl:sequence select="'&lt;'"/>
          <xsl:sequence select="name($elm)"/>
          <xsl:for-each select="$elm/@*[namespace-uri(.) ne 'http://www.w3.org/2001/XMLSchema-instance']">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="xtlc:att2str(.)"/>
          </xsl:for-each>
          <xsl:sequence select="'&gt;'"/>
        </xsl:variable>
        <xsl:sequence select="string-join($description-parts, '')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:items2str" as="xs:string" visibility="public">
    <!--~ Creates a string from a sequence of items. 
      
      Useful for easy creation of messages consisting of multiple parts and pieces. -->
    <xsl:param name="items" as="item()*">
      <!--~ The message parts to combine  -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="empty($items)">
        <xsl:sequence select="''"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="string-parts" as="xs:string*">
          <xsl:for-each select="$items">
            <xsl:choose>
              <xsl:when test=". instance of element()">
                <xsl:sequence select="xtlc:elm2str(.)"/>
              </xsl:when>
              <xsl:when test=". instance of attribute()">
                <xsl:sequence select="xtlc:att2str(.)"/>
              </xsl:when>
              <xsl:when test=". castable as xs:string">
                <xsl:sequence select="string(.)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="''"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="string-join($string-parts, '')"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:text2lines" as="xs:string*" visibility="public">
    <!--~
      Converts text into separate lines.
      
      Uses the LF as separator; CRs are removed.
    -->
    <xsl:param name="text" as="xs:string?">
      <!--~ The text to convert.  -->
    </xsl:param>
    <xsl:param name="remove-empty-start-end-lines" as="xs:boolean">
      <!--~ When `true` any empty (containing whitespace only) lines at the beginning and end are removed. -->
    </xsl:param>
    <xsl:param name="normalize-indents" as="xs:boolean">
      <!--~ When `true` the indents of the lines are normalized: the indent of the non-whitespace line with the minimum leading whitespace 
        is removed from all other lines. Lines that contain only whitespace will become zero length. -->
    </xsl:param>

    <!-- Turn the block of text into individual lines: -->
    <xsl:variable name="fulltext-no-cr" as="xs:string" select="translate(string($text), '&#13;', '')"/>
    <xsl:variable name="textlines-1" as="xs:string*" select="tokenize($fulltext-no-cr, '&#10;')"/>

    <!-- Remove any empty start-end lines if requested: -->
    <xsl:variable name="textlines-2" as="xs:string*">
      <xsl:choose>
        <xsl:when test="$remove-empty-start-end-lines">
          <xsl:for-each-group select="$textlines-1" group-adjacent="normalize-space(.) eq ''">
            <xsl:if test="not(current-grouping-key()) or ((position() gt 1) and (position() lt last()))">
              <xsl:sequence select="current-group()"/>
            </xsl:if>
          </xsl:for-each-group>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$textlines-1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Normalize the indents if requested: -->
    <xsl:choose>
      <xsl:when test="$normalize-indents">
        <!-- Find the minimum indent: -->
        <xsl:variable name="minimum-leading-whitespace" as="xs:integer" select="if (empty($textlines-2)) 
            then 0 
            else min(for $markdown-line in $textlines-2[normalize-space(.) ne ''] return xtlc:count-leading-whitespace($markdown-line))"/>
        <xsl:for-each select="$textlines-2">
          <xsl:choose>
            <xsl:when test="normalize-space(.) eq ''">
              <xsl:sequence select="''"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="substring(., $minimum-leading-whitespace + 1)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$textlines-2"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:count-leading-whitespace" as="xs:integer" visibility="public">
    <!--~ Counts the number of whitespace characters at the beginning of a string  -->
    <xsl:param name="text" as="xs:string">
      <!--~ Text to work on. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="($text eq '')">
        <xsl:sequence select="0"/>
      </xsl:when>
      <xsl:when test="matches(substring($text, 1, 1), '\s')">
        <xsl:sequence select="xtlc:count-leading-whitespace(substring($text, 2)) + 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="0"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="xtlc:wrap-text" as="xs:string*">
    <!--~ Takes a string, converts this into words, and puts the words back together again, trying to keep the 
          maximum length of every line below `$line-length`. This is not guaranteed, because there may be words 
          that are longer than this!
          
          If `$line-length` is le 0, the function acts like normalize-space().
          
          Any leading and trailing whitespace gets lost. 
    -->
    <xsl:param name="in" as="xs:string">
      <!--~ The input string. An empty sequence returns an empty sequence. -->
    </xsl:param>
    <xsl:param name="line-length" as="xs:integer">
      <!--~ The maximum line length. If this is le 0, nothing is done beside normalizing the input. -->
    </xsl:param>
    
    <xsl:variable name="in-normalized" as="xs:string" select="normalize-space($in)"/>
    <xsl:choose>
      <xsl:when test="$line-length le 0">
        <!-- Nothing to do. -->
        <xsl:sequence select="$in-normalized"/>
      </xsl:when>
      <xsl:when test="empty($in)">
        <!-- No input, no output. -->
        <xsl:sequence select="()"/>
      </xsl:when>
      <xsl:when test="string-length($in-normalized) le $line-length">
        <!-- Line is already short enough. -->
        <xsl:sequence select="$in-normalized"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="local:wrap-text-helper($line-length, xtlc:str2seq($in-normalized), (), ())"/>
      </xsl:otherwise>  
    </xsl:choose>
  </xsl:function>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:function name="local:wrap-text-helper" as="xs:string*">
    <xsl:param name="line-length" as="xs:integer"/>
    <xsl:param name="remaining-words" as="xs:string*"/>
    <xsl:param name="lines-sofar" as="xs:string*" />
    <xsl:param name="current-line" as="xs:string?">
      <!-- The line we're currently building up -->
    </xsl:param>
    
    <xsl:choose>
      <xsl:when test="empty($remaining-words)">
        <!-- No more words, this is it. -->
        <xsl:sequence select="($lines-sofar, $current-line)"/>
      </xsl:when>
      <xsl:when test="empty($current-line)">
        <!-- This is the start of a line. There's always at least one word on a line. -->
        <xsl:sequence select="local:wrap-text-helper($line-length, subsequence($remaining-words, 2), $lines-sofar, $remaining-words[1])"/>
      </xsl:when>
      <xsl:when test="(string-length($current-line) + 1 + string-length($remaining-words[1])) gt $line-length">
        <!-- The next word does no longer fit. Start a new line. -->
        <xsl:sequence select="local:wrap-text-helper($line-length, $remaining-words, ($lines-sofar, $current-line), ())"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- The next word fits. -->
        <xsl:sequence select="local:wrap-text-helper($line-length, subsequence($remaining-words, 2), $lines-sofar, string-join(($current-line, $remaining-words[1]), ' '))"/>
      </xsl:otherwise>  
    </xsl:choose>
    
  </xsl:function>
  
  <!-- ================================================================== -->
  <!-- ERROR HANDLING/RAISING -->

  <xsl:template name="xtlc:raise-error">
    <!--~ Stops any processing by raising an error. -->
    <xsl:param name="msg-parts" as="item()+" required="yes">
      <!--~ Error message to show (in parts, all parts will be concatenated by `xtlc:items2str()`). -->
    </xsl:param>
    <xsl:param name="error-name" as="xs:string" required="no" select="$xtlc:status-error">
      <!--~ The (optional) name of the error. Must be an NCName. -->
    </xsl:param>

    <xsl:value-of select="error(QName($xtlc:namespace-xtlc-common, $error-name), xtlc:items2str($msg-parts))"/>
  </xsl:template>

</xsl:stylesheet>
