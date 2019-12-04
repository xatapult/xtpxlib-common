<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:local="#local.href.mod.xsl"
  exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--~
    XSLT library module with functions for the generic handling of href-s.
    (filenames/paths).
    
    Module dependencies: None
	-->
  <!-- ================================================================== -->
  <!-- GLOBAL CONSTANTS: -->

  <xsl:variable name="xtlc:protocol-file" as="xs:string" select="'file'">
    <!--~ File protocol specifier. -->
  </xsl:variable>

  <!-- ================================================================== -->
  <!-- BASIC FUNCTIONS:  -->

  <xsl:function name="xtlc:href-concat" as="xs:string">
    <!--~ 
      Performs a safe concatenation of href components: 
      - Translates all backslashes into slashes
			- Makes sure that all components are separated with a single slash
      - If somewhere in the list is an absolute path, the concatenation stops.
      
      Examples:
      - xtlc:href-concat(('a', 'b', 'c')) ==> a/b/c
      - xtlc:href-concat(('a', '/b', 'c')) ==> /b/c
		-->
    <xsl:param name="href-path-components" as="xs:string*">
      <!--~ The path components that will be concatenated into a full href. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="empty($href-path-components)">
        <xsl:sequence select="''"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- Take the last path in the list and translate all backslashes to slashes: -->
        <xsl:variable name="current-href" as="xs:string" select="translate($href-path-components[last()], '\', '/')"/>
        <xsl:choose>
          <xsl:when test="xtlc:href-is-absolute($current-href)">
            <xsl:sequence select="$current-href"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="prefix" as="xs:string" select="xtlc:href-concat(remove($href-path-components, count($href-path-components)))"/>
            <xsl:sequence
              select="if ($prefix eq '' or ends-with($prefix, '/')) then concat($prefix, $current-href) else concat($prefix, '/', $current-href)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:href-is-absolute" as="xs:boolean">
    <!--~ 
      Returns true if the href can be considered absolute.
      
      An href is considered absolute when it starts with a / or \, contains a protocol specifier (e.g. file://) or
      starts with a Windows drive letter (e.g. C:).
    -->
    <xsl:param name="href" as="xs:string">
      <!--~ href to work on. -->
    </xsl:param>

    <xsl:sequence select="starts-with($href, '/') or starts-with($href, '\') or contains($href, ':/') or matches($href, '^[a-zA-Z]:')"/>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:href-name" as="xs:string">
    <!--~ 
      Returns the (file)name part of an href. 
    
      Examples:
      - xtlc:href-name('a/b/c') ==> c
      - xtlc:href-name('c') ==> c
    -->
    <xsl:param name="href" as="xs:string">
      <!--~ href to work on. -->
    </xsl:param>

    <xsl:sequence select="replace($href, '.*[/\\]([^/\\]+)$', '$1')"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:href-noext" as="xs:string">
    <!--~ 
      Returns the complete href path but without its extension.
    
      Examples:
      - xtlc:href-noext('a/b/c.xml') ==> a/b/c
      - xtlc:href-noext('a/b/c') ==> a/b/c      
    -->
    <xsl:param name="href" as="xs:string">
      <!--~ href to work on. -->
    </xsl:param>

    <xsl:sequence select="replace($href, '\.[^\.]+$', '')"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:href-name-noext" as="xs:string">
    <!--~ 
      Returns the (file)name part of an href, but without its extension. 
    
      Examples:
      - xtlc:href-name-noext('a/b/c.xml') ==> c
      - xtlc:href-name-noext('a/b/c') ==> c   
    -->
    <xsl:param name="href" as="xs:string">
      <!--~ href to work on. -->
    </xsl:param>

    <xsl:sequence select="xtlc:href-noext(xtlc:href-name($href))"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:href-ext" as="xs:string">
    <!--~ 
      Returns the extension part of an href. 
    
      Examples:
      - xtlc:href-ext('a/b/c.xml') ==> xml
      - xtlc:href-ext('a/b/c') ==> ''
    -->
    <xsl:param name="href" as="xs:string">
      <!--~ href to work on. -->
    </xsl:param>

    <xsl:variable name="name-only" as="xs:string" select="xtlc:href-name($href)"/>
    <xsl:choose>
      <xsl:when test="contains($name-only, '.')">
        <xsl:sequence select="replace($name-only, '.*\.([^\.]+)$', '$1')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:href-path" as="xs:string">
    <!--~ 
      Returns the path part of an href.
    
      Examples:
      - xtlc:href-path('a/b/c') ==> a/b
      - xtlc:href-path('c') ==> ''
    -->
    <xsl:param name="href" as="xs:string">
      <!--~ href to work on. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="matches($href, '[/\\]')">
        <xsl:sequence select="replace($href, '(.*)[/\\][^/\\]+$', '$1')"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- No slash or backslash in name, so no base path: -->
        <xsl:sequence select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:href-result-doc" as="xs:string">
    <!--~ 
      Transforms an href into something <xsl:result-document> can use. 
      
      <xsl:result-document> instruction always needs a file:// in front and has some strict rules about the 
      formatting. Make sure the input is an absolute href! 
    -->
    <xsl:param name="href" as="xs:string">
      <!--~ href to work on. Must be absolute! -->
    </xsl:param>

    <xsl:sequence select="xtlc:href-protocol-add($href, $xtlc:protocol-file, true())"/>
  </xsl:function>

  <!-- ================================================================== -->
  <!-- CANONICALIZATION OF HREFs: -->

  <xsl:function name="xtlc:href-canonical" as="xs:string">
    <!--~ 
      Makes an href canonical (remove any .. and . directory specifiers).
      
      Examples:
      - href-canonical('a/b/../c') ==> a/c
    -->
    <xsl:param name="href" as="xs:string">
      <!--~ href to work on. -->
    </xsl:param>

    <!-- Split the href into parts: -->
    <xsl:variable name="protocol" as="xs:string" select="xtlc:href-protocol($href)"/>
    <xsl:variable name="href-no-protocol" as="xs:string" select="xtlc:href-protocol-remove($href)"/>
    <xsl:variable name="href-components" as="xs:string*" select="tokenize($href-no-protocol, '/')[. ne '']"/>

    <!-- Assemble it together again: -->
    <xsl:variable name="href-canonical-filename" as="xs:string"
      select="string-join(local:href-canonical-process-components($href-components, 0), '/')"/>
    <xsl:sequence select="xtlc:href-protocol-add($href-canonical-filename, $protocol, false())"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:href-canonical-process-components" as="xs:string*">
    <!-- Helper function for xtlc:href-canonical -->
    <xsl:param name="href-components-unprocessed" as="xs:string*"/>
    <xsl:param name="parent-directory-marker-count" as="xs:integer"/>

    <!-- Get the last href component to process here and get the remainder of the components: -->
    <xsl:variable name="component-to-process" as="xs:string?" select="$href-components-unprocessed[last()]"/>
    <xsl:variable name="remainder-components" as="xs:string*"
      select="subsequence($href-components-unprocessed, 1, count($href-components-unprocessed) - 1)"/>

    <xsl:choose>

      <!-- No input, no output: -->
      <xsl:when test="empty($component-to-process)">
        <xsl:sequence select="()"/>
      </xsl:when>

      <!-- On a parent directory marker (..) we output the remainder and increase the $parent-directory-marker-count. This will cause the
        next name-component of the remainders to be removed:-->
      <xsl:when test="$component-to-process eq '..'">
        <xsl:sequence select="local:href-canonical-process-components($remainder-components, $parent-directory-marker-count + 1)"/>
      </xsl:when>

      <!-- Ignore any current directory (.) markers: -->
      <xsl:when test="$component-to-process eq '.'">
        <xsl:sequence select="local:href-canonical-process-components($remainder-components, $parent-directory-marker-count)"/>
      </xsl:when>

      <!-- Check if $parent-directory-marker-count is >= 0. If so, do not take the current component into account: -->
      <xsl:when test="$parent-directory-marker-count gt 0">
        <xsl:sequence select="local:href-canonical-process-components($remainder-components, $parent-directory-marker-count - 1)"/>
      </xsl:when>

      <!-- Normal directory name and no $parent-directory-marker-count. This must be part of the output: -->
      <xsl:otherwise>
        <xsl:sequence select="(local:href-canonical-process-components($remainder-components, 0), $component-to-process)"/>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:function>

  <!-- ================================================================== -->
  <!-- RELATIVE HREFs: -->

  <xsl:function name="xtlc:href-relative" as="xs:string">
    <!--~ 
      Computes a relative href from one document to another.
      
      Examples:
      - href-relative('a/b/c/from.xml', 'a/b/to.xml') ==> ../to.xml
      - href-relative('a/b/c/from.xml', 'a/b/d/to.xml') ==> ../d/to.xml      
    -->
    <xsl:param name="from-href" as="xs:string">
      <!--~ href (of a document) of the starting point.  -->
    </xsl:param>
    <xsl:param name="to-href" as="xs:string">
      <!--~ href (of a document) of the target. -->
    </xsl:param>

    <xsl:sequence select="xtlc:href-relative-from-path(xtlc:href-path($from-href), $to-href)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:href-relative-from-path" as="xs:string">
    <!--~
      Computes a relative href from a path to a document.
      
      Examples:
      - href-relative-from-path('a/b/c', 'a/b/to.xml') ==> ../to.xml
      - href-relative-from-path('a/b/c', 'a/b/d/to.xml') ==> ../d/to.xml            
    -->
    <xsl:param name="from-href-path" as="xs:string">
      <!--~ href (of a directory) of the starting point. -->
    </xsl:param>
    <xsl:param name="to-href" as="xs:string">
      <!--~ href (of a document) of the target. -->
    </xsl:param>

    <!-- Get all the bits and pieces: -->
    <xsl:variable name="from-href-path-canonical" as="xs:string" select="xtlc:href-canonical($from-href-path)"/>
    <xsl:variable name="from-protocol" as="xs:string" select="xtlc:href-protocol($from-href-path-canonical, $xtlc:protocol-file)"/>
    <xsl:variable name="from-no-protocol" as="xs:string" select="xtlc:href-protocol-remove($from-href-path-canonical)"/>
    <xsl:variable name="from-components-no-filename" as="xs:string*" select="tokenize($from-no-protocol, '/')[. ne '']"/>

    <xsl:variable name="to-href-canonical" as="xs:string" select="xtlc:href-canonical($to-href)"/>
    <xsl:variable name="to-protocol" as="xs:string" select="xtlc:href-protocol($to-href-canonical, $xtlc:protocol-file)"/>
    <xsl:variable name="to-no-protocol" as="xs:string" select="xtlc:href-protocol-remove($to-href-canonical)"/>
    <xsl:variable name="to-components" as="xs:string*" select="tokenize($to-no-protocol, '/')[. ne '']"/>
    <xsl:variable name="to-components-no-filename" as="xs:string*" select="subsequence($to-components, 1, count($to-components) - 1)"/>
    <xsl:variable name="to-filename" as="xs:string" select="$to-components[last()]"/>

    <!-- Now find it out: -->
    <xsl:choose>

      <!-- Unequal protocols or no from-href/to-href means there is no relative path... -->
      <xsl:when test="empty($to-components-no-filename) or (lower-case($from-protocol) ne lower-case($to-protocol))">
        <xsl:sequence select="$to-href-canonical"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence
          select="xtlc:href-concat((local:relative-href-components-compare($from-components-no-filename, $to-components-no-filename), $to-filename))"
        />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:relative-href-components-compare" as="xs:string*">
    <!-- Local helper function for computing relative paths. -->
    <xsl:param name="from-components" as="xs:string*"/>
    <xsl:param name="to-components" as="xs:string*"/>

    <xsl:choose>
      <xsl:when test="$from-components[1] eq $to-components[1]">
        <xsl:sequence select="local:relative-href-components-compare(subsequence($from-components, 2), subsequence($to-components, 2))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="(for $p in (1 to count($from-components)) return '..', $to-components)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- ================================================================== -->
  <!-- PROTOCOL RELATED FUNCTIONS: -->

  <xsl:variable name="local:protocol-match-regexp" as="xs:string" select="'^[a-z]+://'"/>
  <xsl:variable name="local:protocol-file-special" as="xs:string" select="concat($xtlc:protocol-file, ':/')"/>

  <xsl:function name="xtlc:href-protocol-present" as="xs:boolean">
    <!--~ Returns true when an href has a protocol specifier (e.g. file:// or http://). -->
    <xsl:param name="href" as="xs:string">
      <!--~ href to work on. -->
    </xsl:param>

    <!-- Usually a protocol is something that ends with ://, e.g. http://, but for the file protocol we also encounter file:/ (single slash).
      We have to adjust for this.-->
    <xsl:sequence select="starts-with($href, $local:protocol-file-special) or matches($href, $local:protocol-match-regexp)"/>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:href-protocol-remove" as="xs:string">
    <!--~ 
      Removes the protocol part from an href.  
    
      Examples (it is tricky and inconsistent!)
      - xtlc:protocol-remove('file:///a/b/c') ==> /a/b/c
      Weird exceptions:
      - xtlc:protocol-remove('file:/a/b/c') ==> /a/b/c
      - xtlc:protocol-remove('file:/C:/a/b/c') ==> C:/a/b/c
    -->
    <xsl:param name="href" as="xs:string">
      <!--~ href to work on. -->
    </xsl:param>

    <xsl:variable name="protocol-windows-special" as="xs:string" select="concat('^', $local:protocol-file-special, '[a-zA-Z]:/')"/>

    <!-- First remove any protocol specifier: -->
    <xsl:variable name="ref-0" as="xs:string" select="translate($href, '\', '/')"/>
    <xsl:variable name="ref-1" as="xs:string">
      <xsl:choose>
        <!-- Normal case, anything starting with protocol:// -->
        <xsl:when test="matches($ref-0, $local:protocol-match-regexp)">
          <xsl:sequence select="replace($href, $local:protocol-match-regexp, '')"/>
        </xsl:when>
        <!-- Windows file:/ exception, single slash, drive letter (file:/C:/bla/bleh):  -->
        <xsl:when test="matches($ref-0, $protocol-windows-special)">
          <xsl:sequence select="substring-after($ref-0, $local:protocol-file-special)"/>
        </xsl:when>
        <!-- Unix file:/ exception, single slash but absolute path (file:/home/beheer): -->
        <xsl:when test="starts-with($ref-0, $local:protocol-file-special)">
          <xsl:sequence select="concat('/', substring-after($ref-0, $local:protocol-file-special))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$ref-0"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Check for a Windows absolute path with a slash in front. That must be removed: -->
    <xsl:sequence select="if (matches($ref-1, '^/[a-zA-Z]:/')) then substring($ref-1, 2) else $ref-1"/>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:href-protocol-add" as="xs:string">
    <!--~ Adds a protocol part (written without the trailing ://) to an href. -->
    <xsl:param name="href" as="xs:string">
      <!--~ href to work on. -->
    </xsl:param>
    <xsl:param name="protocol" as="xs:string">
      <!--~ The protocol to add, without a leading :// part (e.g. just 'file' or 'http'). -->
    </xsl:param>
    <xsl:param name="force" as="xs:boolean">
      <!--~ When true an existing protocol is removed first. When false, a reference with an existing protocol is left unchanged.  -->
    </xsl:param>

    <xsl:variable name="ref-1" as="xs:string" select="if ($force) then xtlc:href-protocol-remove($href) else translate($href, '\', '/')"/>
    <xsl:choose>

      <!-- When $force is false, do not add a protocol when one is present already: -->
      <xsl:when test="not($force) and xtlc:href-protocol-present($ref-1)">
        <xsl:sequence select="$ref-1"/>
      </xsl:when>

      <!-- When this is a Windows file href, make sure to add an extra / : -->
      <xsl:when test="($protocol eq $xtlc:protocol-file) and matches($ref-1, '^[a-zA-Z]:/')">
        <xsl:sequence select="concat($protocol, ':///', $ref-1)"/>
      </xsl:when>

      <xsl:when test="($protocol ne '')">
        <xsl:sequence select="concat($protocol, '://', $ref-1)"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:sequence select="$ref-1"/>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:href-protocol" as="xs:string">
    <!--~ Returns the protocol part of an href (without the ://). -->
    <xsl:param name="href" as="xs:string">
      <!--~ href to work on. -->
    </xsl:param>

    <xsl:sequence select="xtlc:href-protocol($href, '')"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:href-protocol" as="xs:string">
    <!--~ Returns the protocol part of an href (without the ://) or a default value when none present. -->
    <xsl:param name="href" as="xs:string">
      <!--~ href to work on. -->
    </xsl:param>
    <xsl:param name="default-protocol" as="xs:string">
      <!--~ Default protocol to return when $ref contains none. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="xtlc:href-protocol-present($href)">
        <xsl:sequence select="replace($href, '(^[a-z]+):/.*$', '$1')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$default-protocol"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:href-add-encoding" as="xs:string">
    <!--~ 
      Encodes all "strange" characters with %xx. Any existing %xx parts will be kept as is.
    -->
    <xsl:param name="href" as="xs:string">
      <!--~ href to work on. -->
    </xsl:param>

    <xsl:variable name="protocol" as="xs:string" select="xtlc:href-protocol($href)"/>
    <xsl:variable name="href-no-protocol" as="xs:string" select="xtlc:href-protocol-remove($href)"/>
    <xsl:variable name="href-parts" as="xs:string*" select="tokenize($href-no-protocol, '/')"/>

    <xsl:variable name="href-parts-uri" as="xs:string*">
      <xsl:for-each select="$href-parts">
        <xsl:choose>
          <xsl:when test="(position() eq 1) and matches(., '^[a-zA-Z]:$')">
            <!-- Windows drive letter, just keep: -->
            <xsl:sequence select="."/>
          </xsl:when>
          <xsl:otherwise>
            <!-- Encode the part: -->
            <xsl:variable name="href-part-parts" as="xs:string*">
              <xsl:analyze-string select="." regex="%[0-9][0-9]">
                <xsl:matching-substring>
                  <xsl:sequence select="."/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                  <xsl:sequence select="encode-for-uri(.)"/>
                </xsl:non-matching-substring>
              </xsl:analyze-string>
            </xsl:variable>
            <xsl:sequence select="string-join($href-part-parts, '')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>

    <xsl:sequence select="xtlc:href-protocol-add(string-join($href-parts-uri, '/'), $protocol, false())"/>
  </xsl:function>
 
</xsl:stylesheet>
