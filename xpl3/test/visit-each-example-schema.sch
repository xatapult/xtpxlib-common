<schema xmlns="http://purl.oclc.org/dsdl/schematron" schematronEdition="2025">
  <ns prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>
  <pattern>
    <rule context="description" visit-each="tokenize(., '\s+')[starts-with(., 'CD')]">
      <assert test="substring(., 3) castable as xs:integer">Invalid code: {.} or <value-of select="."/></assert>
    </rule>
  </pattern>
  
</schema>