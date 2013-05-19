<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
                xmlns:cve="http://cve.mitre.org/cve/downloads" >
<xsl:output method="text"/>

 <!-- main template -->

  <xsl:template match="//cve"> 
     <xsl:apply-templates   select="//cve:item"/> 
  </xsl:template> 
<xsl:template match="//cve:item">
insert into cves (name,desc,ref) 
values( '<xsl:call-template name="sql-escape"><xsl:with-param name="text"
             select="@name"/></xsl:call-template>',
'<xsl:call-template name="sql-escape"><xsl:with-param name="text"
select="cve:desc"/></xsl:call-template>',
'<xsl:for-each select="cve:refs/cve:ref">
<xsl:call-template name="sql-escape"><xsl:with-param name="text"
             select="@source"/></xsl:call-template>,<xsl:call-template
             name="sql-escape"><xsl:with-param name="text"
             select="@url"/></xsl:call-template>,<xsl:call-template
             name="sql-escape"><xsl:with-param name="text"
             select="."/></xsl:call-template>|</xsl:for-each>'
);
</xsl:template>
 <!-- utility functions -->

  <xsl:template name="sql-escape">
    <xsl:param name="text"/>
    <xsl:variable name="tmp">
      <xsl:call-template name="replace-substring">
        <xsl:with-param name="from">'</xsl:with-param>
        <xsl:with-param name="to">''</xsl:with-param>
        <xsl:with-param name="value" select="$text"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="$tmp"/>
  </xsl:template>

  <xsl:template name="replace-substring">
    <xsl:param name="value" />
    <xsl:param name="from" />
    <xsl:param name="to" />
    <xsl:choose>
      <xsl:when test="contains($value,$from)">
        <xsl:value-of select="substring-before($value,$from)" />
        <xsl:value-of select="$to" />
        <xsl:call-template name="replace-substring">
          <xsl:with-param name="value" select="substring-after($value,$from)" />
          <xsl:with-param name="from" select="$from" />
          <xsl:with-param name="to" select="$to" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
