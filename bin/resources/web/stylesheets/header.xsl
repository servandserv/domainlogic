<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:d="urn:docs:domain"
	xmlns:toc="urn:docs:toc"
	xmlns:uc="urn:docs:ucpackage"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	extension-element-prefixes="exsl"
    exclude-result-prefixes="xhtml xlink d uc toc xsl">
	
    <xsl:output 
		method="html"
		encoding="UTF-8"
		indent="yes"
		cdata-section-elements="script noscript"
		undeclare-namespaces="yes"
		omit-xml-declaration="yes"
		doctype-system="about:legacy-compat" />
	
	<xsl:template match="toc:chapter">
		<li>
			<a href="{@href}"><xsl:value-of select="@title" /></a>
			<xsl:if test="toc:chapter">
				<ul>
					<xsl:apply-templates select="toc:chapter" />
				</ul>
			</xsl:if>
		</li>
	</xsl:template>
	
	<xsl:template name="header">
		<xsl:variable name="menu" select="document('TOC.xml',/)/toc:toc" />
		<div id="header">
			<svg xmlns="http://www.w3.org/2000/svg" height="116px" width="24px" style="background:rgb(0,90,156);" viewBox="0 0 24 116">
				<g transform="translate(-3,116)">
					<text x="10" y="20" fill="white" 
						transform="rotate(-90)" style="font-size:16px;font-family:Avenir;">Domain logic</text>
				</g>
			</svg>
			<div>
				<p>Content</p>
				<ul>
					<xsl:apply-templates select="$menu/toc:chapter" />
				</ul>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template name="table-of-content">
		<xsl:variable name="menu" select="document('TOC.xml',/)/toc:toc" />
		<div id="toc">
			<h1>Документация</h1>
			<hr/>
			<ul>
				<xsl:apply-templates select="$menu/toc:chapter" />
			</ul>
		</div>
	</xsl:template>
	
</xsl:stylesheet>