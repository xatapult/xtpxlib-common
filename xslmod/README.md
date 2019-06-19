# `xtpxlib-common/xslmod` contents

This folder contains several XSLT libraries with templates/functions for common use.

For historic reasons some of these are still in XSLT V2.0. This was kept unchanged, maybe someone still needs them in an XSLT V2.0 context and it does no harm.

Some of the libraries depend on each other. Because of the XSLT mechanism for this you need to satisfy these dependencies when including a library (by adding the appropriate `<xsl:include href="..."/>`). Dependencies are documented in the module header comment.

| Module | Description | Remarks |
| ------ | ------ | ----- |
| `compare.mod.xsl` | Code for comparing two XML files with each other. |  |
| `date-time.mod.xsl` | Code for working with and formatting dates and times.  | Sometimes language dependent. |
| `format-output.mod.xsl` | Code for formatting amounts, durations, sizes, etc. into more user friendly formats. | Sometimes language dependent. |
| `general.mod.xsl` | General handy functions and templates. | Used by most other modules. |
| `href.mod.xsl` | Code for working with href-s (filenames, URL-s, etc.) |  |
| `message.mod.xsl` | Code for creating messages (in the format as prescribed by this library). | See also `/xsd/message.xsd` |
| `mimetypes.mod.xsl` | Code for working with MIME type codes and the accompanying file extensions. | See also `/data/mimetypes-table.xml` |
| `parameters.mod.xsl` | Code for working with parameters (in the format as prescribed by this library). | More information below. |
| `uuid.mod.xsl` | Code for generating UUID-s. | Separated because this needs Saxon PE or EE and does not work on the free HE edition. |

---

## xtpxlib parameters 

Working with parameters is quite common. Therefore xtpxlib has a custom mechanism for this. 

Parameters have a (string) name (without whitespace) and zero or more (string) values.

### Base parameter XML format

A schema of the XML format for parameters is in `/xsd/parameters.xsd`. Please notice that the processing of this format is *namespace agnostic*. As long as the local-names of the elements are correct (`<parameters>`, `<parameter>`, `<value>`, `<group>`), everything will work, regardless of what namespace the elements are in. 

A `<parameters>` element can be the root element of a document on its own or it can be embedded in something else if needed. Both situations can be handled by the code. 

Here is an example of XML specifying some parameters. 

```xml
<parameters>
  <parameter name="x">
    <value system="prd">value for prod</value>
    <value system="acc tst">value for acc and tst</value>
  </parameter>
</parameters>
```

If you run this through the code (unfiltered, see below) in `/xslmod/parameters.mod.xsl` you will get a *single* parameter called `x` with two values: `value for prod` and `value for acc and tst`.

### Filtering parameter

Parameter `<value>` elements can contain filters. Filters are expressed as attributes on the `<value>` elements. These attributes contain a whitespace separated list of filter values.

The code in `/xslmod/parameters.mod.xsl` can filter parameters based on values in a map. For instance in processing the example above, you could specify a filter `map{ 'system': 'tst' }`. This will cause only the  value `value for acc and tst` as a result for parameter `x`.

The rules are:
* If there are no filters, all `<value>` elements will be turned into parameter values.
* A filter applies if a key in the filters is the same as the local-name of an attribute on a `<value>` element.
* A value (after tokenizing on whitespace) of such an attribute matches if it has the same value as the filter specifies. 
* All applied filters must match before a value is included
* Please note that filters that have no corresponding attribute are not taken into account.

### Grouping parameters

Parameters can be grouped. Group names are prefixed to the rest of the parameter's name using a `.` separator. Groups can be nested.


Here is an example:

```xml
<parameters>
  <parameter name="x">
    <value>xvalue</value>
  </parameter>
  
  <group name="groupie">
    <parameter name="inthegroup">
      <value>blah</value>
    </parameter>
  </group>
  
</parameters>
```

This will result in two parameters: `x` and `groupie.inthegroup`.

### Referencing parameter values

In specifying a parameter's value(s) in `<value>` elements, you can reference another parameter by using a `{$parameter-name}` or `${parameter-name}` construction. Only the first value of a parameter will be used. 



### Processing parameters

The code for working with parameters is in `/xslmod/parameters.mod.xsl`. 

Its main function will take a `<parameters>` element (either in a document on its own or embedded) and an optional filter specification and turn this into a map with all the parameter names as keys. 

