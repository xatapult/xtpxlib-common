# `xtpxlib-common`: Xatapult XML Library - Common component: Shared libraries and IDE support

**Xatapult Content Engineering - [`http://www.xatapult.com`](http://www.xatapult.com)**

---------- 

`xtpxlib-common` is `xtpxlib`'s communal component. Most other `xtpxlib` components rely on it. It contains:
* XSLT libraries, with functionality for handling parameters, manipulating filenames/URIs, MIME types, etc.
* Parts of the functionality of the XSLT libraries were translated into XQuery. 
* XProc (1.0) steps, implementing things like recursive directory lists, tee, creating ZIP files from directories, etc.
* Templates (empty XSLT, XProc, XQuery, etc. files) for use in the oXygen IDE.

## Technical information

Component version: V1.3.1 - 2020-08-18

Documentation: [`https://common.xtpxlib.org`](https://common.xtpxlib.org)

Git URI: `git@github.com:xatapult/xtpxlib-common.git`

Git site: [`https://github.com/xatapult/xtpxlib-common`](https://github.com/xatapult/xtpxlib-common)
      


## Version history

**V1.3.1 - 2020-08-18 (current)**

Some bugfixes for `xtlc:log-write`

**V1.3 - 2020-08-18**

Added `xtlc:write-log` XProc 3.0 step

**V1.2 - 2020-08-13**

Several enhancements:
* Added `str2regexp()` function to `xslmod/general.mod.xsl`
* Added URI decoding function to `xslmod/href.mod.xsl`
* Added the option to get decoded URIs in `xpl3mod/recursive-directory-list/recursive-directory-list.xpl`

**V1.1.1 - 2020-06-16**

Fixed bug in creating canonical filenames on Unix

**V1.1 - 2020-06-08**

Added first XProc 3.0 support. Fixed some minor issues in templates.

**V1.0.A - 2020-02-16**

New logo and minor fixes

**V1.0 - 2019-12-18**

Initial release

**V0.9 - 2019-12-10**

Pre-release to test GitHub pages functionality


