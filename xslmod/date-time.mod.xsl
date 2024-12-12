<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:local="#local.format-output.mod.xsl" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--~
    XSLT library module containing functions for working with dates and times.
    
    When language based, it only distinguishes between Dutch and non-Dutch (which now means: English).
	-->
  <!-- ================================================================== -->
  <!-- GLOBAL DECLARTIONS: -->

  <xsl:variable name="xtlc:month-names-nl" as="xs:string+"
    select="('januari', 'februari', 'maart', 'april', 'mei', 'juni', 'juli', 'augustus', 'september', 'oktober', 'november', 'december')">
    <!--~ Sequence with the names of the months in Dutch -->
  </xsl:variable>

  <xsl:variable name="xtlc:month-names-en" as="xs:string+"
    select="('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')">
    <!--~ Sequence with the names of the months in English -->
  </xsl:variable>

  <xsl:variable name="xtlc:day-names-nl" as="xs:string+" select="('maandag', 'dinsdag', 'woensdag', 'donderdag', 'vrijdag', 'zaterdag', 'zondag')">
    <!--~ Sequence with the names of the days in Dutch -->
  </xsl:variable>

  <xsl:variable name="xtlc:day-names-en" as="xs:string+" select="('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saterday', 'Sunday')">
    <!--~ Sequence with the names of the days in English -->
  </xsl:variable>

  <!-- ======================================================================= -->
  <!-- LOCAL DECLARATIONS: -->

  <xsl:variable name="local:base-monthdays" as="xs:integer+" select="(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)">
    <!-- Number of days in each month, uncorrected for leap years. -->
  </xsl:variable>

  <xsl:variable name="local:day-in-year-computation-monthdays-base" as="xs:integer+">
    <!-- For every month, how much days are there in the months before (uncorrected for leap years). -->
    <xsl:sequence select="0"/>
    <xsl:for-each select="2 to 12">
      <xsl:variable name="month" as="xs:integer" select="."/>
      <xsl:sequence select="sum(for $m in (1 to ($month - 1)) return $local:base-monthdays[$m])"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="local:february" as="xs:integer" select="2"/>

  <!-- ================================================================== -->

  <xsl:function name="xtlc:month-name" as="xs:string" visibility="public">
    <!--~ Returns the name of a month. -->
    <xsl:param name="month-number" as="xs:integer">
      <!--~ The month number (1-12). -->
    </xsl:param>
    <xsl:param name="lang" as="xs:string">
      <!--~ The language you want the month name in. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="($month-number lt 1) or ($month-number gt 12)">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="('Invalid month number: ', $month-number)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$lang eq $xtlc:language-nl">
        <xsl:sequence select="$xtlc:month-names-nl[$month-number]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$xtlc:month-names-en[$month-number]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:month-name-short" as="xs:string" visibility="public">
    <!--~ Returns the name of a month in short (abbreviated to 3 characters). -->
    <xsl:param name="month-number" as="xs:integer">
      <!--~ The month number (1-12). -->
    </xsl:param>
    <xsl:param name="lang" as="xs:string">
      <!--~ The language you want the month name in. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="($lang eq $xtlc:language-nl) and ($month-number eq 3)">
        <xsl:sequence select="'mrt'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="substring(xtlc:month-name($month-number, $lang), 1, 3)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:format-date-as-text" as="xs:string" visibility="public">
    <!--~ Formats a date as a string with the month name in full.  -->
    <xsl:param name="date" as="xs:date">
      <!--~ The date to format. -->
    </xsl:param>
    <xsl:param name="lang" as="xs:string">
      <!--~ The language for the conversion. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="$lang eq $xtlc:language-nl">
        <xsl:sequence
          select="concat(day-from-date($date), '&#xa0;', xtlc:month-name(month-from-date($date), $xtlc:language-nl), '&#xa0;', year-from-date($date))"
        />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence
          select="concat(xtlc:month-name(month-from-date($date), $xtlc:language-en), '&#xa0;', day-from-date($date), ',&#xa0;', year-from-date($date))"
        />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:format-date-as-text-short" as="xs:string" visibility="public">
    <!--~ Formats a date as a string with the month name in short.  -->
    <xsl:param name="date" as="xs:date">
      <!--~ The date to format. -->
    </xsl:param>
    <xsl:param name="lang" as="xs:string">
      <!--~ The language for the conversion. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="$lang eq $xtlc:language-nl">
        <xsl:sequence select="concat(day-from-date($date), '&#xa0;', xtlc:month-name-short(month-from-date($date), $lang))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="concat(xtlc:month-name-short(month-from-date($date), $lang), '&#xa0;', day-from-date($date))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:days-in-month" as="xs:integer" visibility="public">
    <!--~ Computes the number of days in a particular month. If values are out of range it returns 0. -->
    <xsl:param name="month-number" as="xs:integer">
      <!--~ The month to calculate the number of days for.  -->
    </xsl:param>
    <xsl:param name="year" as="xs:integer">
      <!--~ The year this month is in (important because of leap years). -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="($month-number lt 1) or ($month-number gt 12)">
        <xsl:sequence select="0"/>
      </xsl:when>
      <xsl:when test="($month-number ne $local:february) or not(xtlc:is-leap-year($year))">
        <xsl:sequence select="$local:base-monthdays[$month-number]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$local:base-monthdays[$local:february] + 1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:is-leap-year" as="xs:boolean" visibility="public">
    <!--~ Returns true when a given year is a leap year  -->
    <xsl:param name="year" as="xs:integer">
      <!--~ The year to check. -->
    </xsl:param>

    <xsl:sequence select="((($year mod 4) eq 0) and (($year mod 100) ne 0)) or (($year mod 400) eq 0)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:day-in-year-number" as="xs:integer" visibility="public">
    <!--~ 
      Computes the day number in the year: January 1 is 1, December 31 is 365 (or 366 in leap years).
    -->
    <xsl:param name="date" as="xs:date">
      <!--~ Date to use. -->
    </xsl:param>

    <xsl:variable name="day" as="xs:integer" select="day-from-date($date)"/>
    <xsl:variable name="month" as="xs:integer" select="month-from-date($date)"/>
    <xsl:variable name="year" as="xs:integer" select="year-from-date($date)"/>
    <xsl:variable name="leap-year-correction" as="xs:integer" select="if (($month gt $local:february) and xtlc:is-leap-year($year)) then 1 else 0"/>
    <xsl:sequence select="$local:day-in-year-computation-monthdays-base[$month] + $day + $leap-year-correction"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:week-number" as="xs:integer" visibility="public">
    <!--~ 
      Computes the ISO week number for a given date.
    -->
    <xsl:param name="date" as="xs:date">
      <!--~ Date to use. -->
    </xsl:param>

    <!-- Inspired by https://home.hccnet.nl/s.f.boukes/html-1/html-188.htm -->

    <xsl:variable name="days-since-january-1" as="xs:integer" select="xtlc:day-in-year-number($date)">
      <!-- Remark: This is not truly the "days since", since for January 1 itself it is 1, not 0... 
        (I would have expected it to be 0 if named like this, but anyway, whatever works) -->
    </xsl:variable>
    <xsl:variable name="week-number-raw" as="xs:integer" select="($days-since-january-1 + 10 - xtlc:weekday-number($date)) idiv 7"/>

    <!--<xsl:message xml:space="preserve">xtlc:week-number: date=<xsl:value-of select="$date"/> - days-since-january-1=<xsl:value-of select="$days-since-january-1"/> - weekday-number=<xsl:value-of select="xtlc:weekday-number($date)"/> - week-number-raw=<xsl:value-of select="$week-number-raw"/></xsl:message>-->

    <xsl:choose>
      <xsl:when test="$week-number-raw le 0">
        <!-- We need the week number of the last week of the previous year. -->
        <xsl:sequence select="xtlc:week-number(xs:date((year-from-date($date) - 1) || '-12-31'))"/>
      </xsl:when>
      <xsl:when test="$week-number-raw eq 53">
        <!-- We might have to adjust: if December 31 of this year is a Monday, Tuesday or Wednesday. -->
        <xsl:variable name="weekday-number-last-day-of-year" as="xs:integer" select="xtlc:weekday-number(xs:date(year-from-date($date) || '-12-31'))"/>
        <xsl:sequence select="if ($weekday-number-last-day-of-year le 3) then 1 else $week-number-raw"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$week-number-raw"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:weekday-name" as="xs:string" visibility="public">
    <!--~ Returns the name of a month. -->
    <xsl:param name="day-number" as="xs:integer">
      <!--~ The day number (1-7). -->
    </xsl:param>
    <xsl:param name="lang" as="xs:string">
      <!--~ The language you want the month name in. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="($day-number lt 1) or ($day-number gt 7)">
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="('Invalid day number: ', $day-number)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$lang eq $xtlc:language-nl">
        <xsl:sequence select="$xtlc:day-names-nl[$day-number]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$xtlc:day-names-en[$day-number]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:weekday-number" as="xs:integer" visibility="public">
    <!--~ The number of the weekday (1=Monday, 7=Sunday). -->
    <xsl:param name="date" as="xs:date">
      <!--~ Date to use. -->
    </xsl:param>

    <!-- We use Zeller's rule, see: https://beginnersbook.com/2013/04/calculating-day-given-date/ -->

    <xsl:variable name="k" as="xs:integer" select="day-from-date($date)"/>

    <!-- Month numbering starts in March. -->
    <xsl:variable name="m-base" as="xs:integer" select="month-from-date($date)"/>
    <xsl:variable name="month-jan-or-feb" as="xs:boolean" select="$m-base le $local:february"/>
    <xsl:variable name="m" as="xs:integer" select="if ($month-jan-or-feb) then ($m-base + 10) else ($m-base - 2)"/>

    <!-- In this calculation the year starts in March. -->
    <xsl:variable name="year-base" as="xs:integer" select="year-from-date($date)"/>
    <xsl:variable name="year" as="xs:integer" select="if ($month-jan-or-feb) then ($year-base - 1) else $year-base"/>

    <!-- First and last two digits of the year -->
    <xsl:variable name="C" as="xs:integer" select="$year idiv 100"/>
    <xsl:variable name="D" as="xs:integer" select="$year - ($C * 100)"/>

    <!-- Now the complex and mysterious calculation: -->
    <xsl:variable name="F" as="xs:integer"
      select="$k + xs:integer(((13 * $m) - 1) div 5) + $D + xs:integer($D div 4) + xs:integer($C div 4) - (2 * $C)"/>
    <!-- This can become negative, adjust for that: -->
    <xsl:variable name="day-of-week-base" as="xs:integer" select="if ($F lt 0) then (7 + ($F mod 7)) else ($F mod 7)"/>

    <!--<xsl:message xml:space="preserve">xtlc:weekday-number: date=<xsl:value-of select="$date"/> - k=<xsl:value-of select="$k"/> - m=<xsl:value-of select="$m"/> - D=<xsl:value-of select="$D"/> - C=<xsl:value-of select="$C"/> - F=<xsl:value-of select="$F"/> - dwb=<xsl:value-of select="$day-of-week-base"/></xsl:message>-->

    <xsl:sequence select="if ($day-of-week-base eq 0) then 7 else $day-of-week-base"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:to-date" as="xs:date" visibility="public">
    <!--~ Creates a date from its components. -->
    <xsl:param name="day" as="xs:integer">
      <!--~ Day number to use. -->
    </xsl:param>
    <xsl:param name="month" as="xs:integer">
      <!--~ Month number to use. -->
    </xsl:param>
    <xsl:param name="year" as="xs:integer">
      <!--~ Year to use. -->
    </xsl:param>

    <xsl:variable name="date-string" as="xs:string" select="concat(xtlc:prefix-to-length(string($year), '0', 4), '-', 
        xtlc:prefix-to-length(string($month), '0', 2), '-', 
        xtlc:prefix-to-length(string($day), '0', 2))"/>
    <xsl:choose>
      <xsl:when test="$date-string castable as xs:date">
        <xsl:sequence select="xs:date($date-string)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="('Invalid year/month/day combination: ', $date-string)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="xtlc:unix-epoch" as="xs:decimal" visibility="public">
    <!--~ Computes the UNIX "epoch" code (number of seconds since 1-1-1970) for a given date/time.  -->
    <xsl:param name="datetime" as="xs:dateTime">
      <!--~ The date/time to compute the epoch code for. -->
    </xsl:param>

    <xsl:sequence select="round((current-dateTime() - xs:dateTime('1970-01-01T00:00:00')) 
      div xs:dayTimeDuration('PT1S'))"/>
  </xsl:function>

</xsl:stylesheet>
