<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:wadl="http://wadl.dev.java.net/2009/02"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:toc="urn:com:servandserv:domainlogic:toc"
	xmlns:d="urn:com:servandserv:domainlogic:domain"
	xmlns:uc="urn:com:servandserv:domainlogic:ucpackage"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	extension-element-prefixes="exsl"
    exclude-result-prefixes="xlink toc d uc xsl wadl">

    <!--xsl:output
		media-type="text/xml"
		method="xml"
		encoding="UTF-8"
		indent="yes"
		omit-xml-declaration="no" /-->
	<xsl:output method="html" omit-xml-declaration="yes" indent="yes" />
	<!--xsl:output method="text" omit-xml-declaration="yes" indent="no"/-->
    
	<xsl:include href="common2html.xsl" />
	
	<xsl:param name="DEST" />
	<xsl:variable name="STICKMAN" select="document('images/stickman.svg',/)/svg:svg" />
	
	<xsl:template match="uc:ucpackage">
		<xsl:apply-templates select="." mode="content" />
	</xsl:template>
	
	<xsl:template match="uc:ucpackage" mode="content">
	<xsl:text disable-output-escaping="yes">
#path: </xsl:text><xsl:value-of select="$DEST" /><xsl:text>/</xsl:text>
        <xsl:value-of select="translate(@URN,':','.')" />
        <xsl:text disable-output-escaping="yes">.html
&lt;!DOCTYPE html&gt;
        </xsl:text>
	    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ru">
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
				<meta name="keywords" content="crm glossary"/>
				<link rel="stylesheet" type="text/css" href="css/domainlogic.css" />
				<title><xsl:value-of select="@xlink:title" />| Usecases</title>
				<script src='js/jquery-2.1.0.min.js'>;</script>
                <script src='js/coffee-script-1.7.1.js'>;</script>
                <script src='js/jumly.min.js'>;</script>
			</head>
			<body>
			    <xsl:call-template name="header" />
		        <xsl:variable name="level" select="count(ancestor-or-self::uc:ucpackage)" />
		        <xsl:if test="parent::uc:ucpackage">
		            <h6>
		                <xsl:for-each select="ancestor::uc:ucpackage">
		                    <xsl:variable name="href">
			                    <xsl:call-template name="get-href">
			                        <xsl:with-param name="urn" select="@URN" />
			                    </xsl:call-template>
			                </xsl:variable>
		                    /<a href="{$href}"><xsl:value-of select="@xlink:title" /></a>
		                </xsl:for-each>
			        </h6>
			    </xsl:if>
		        <h2 id="{substring-after(@URN,'ucpackage:')}" style="position:relative;">
			        <xsl:apply-templates select="." mode="autonum" />
			        <xsl:text>.&#160;</xsl:text>
			        <xsl:value-of select="@xlink:title" />
		        </h2>
		    <hr/>
		    <xsl:if test="not($level = '1')">
		        <xsl:variable name="graph" select="document(concat('images/',translate(substring-after(@URN,'ucpackage:'),':','/'),'/ucpackage.svg'),/)/svg:svg" />
		        <xsl:if test="$graph">
			        <p>
				        <xsl:apply-templates select="$graph" />
			        </p>
		        </xsl:if>
		    </xsl:if>
		    <xsl:if test="uc:ucpackage">
		        <div class="ucpackages">Packages</div>
			    <ul class="contents">
				    <xsl:apply-templates select="uc:ucpackage" mode="ToC" />
			    </ul>
		    </xsl:if>
		    <xsl:if test="html:script">
		        <h3>Package scheme</h3>
		        <xsl:apply-templates select="html:script" mode="DIA" />
		    </xsl:if>
		    <!--xsl:if test="uc:actor">
			    <div class="actors">Actors</div>
			    <ul class="contents">
				    <xsl:for-each select="uc:actor">
					    <xsl:variable name="link">
						    <xsl:call-template name="get-href">
							    <xsl:with-param name="urn" select="@xlink:href" />
						    </xsl:call-template>
					    </xsl:variable>
					    <li><a href="{$link}" ><xsl:value-of select="@xlink:title" /></a></li>
				    </xsl:for-each>
			    </ul>
		    </xsl:if-->
		    <xsl:if test="uc:usecase">
			    <div class="usecases">Usecases</div>
			    <ul class="contents">
				    <xsl:apply-templates select="uc:usecase" mode="ToC" />
			    </ul>
		    </xsl:if>
		    <xsl:apply-templates select="uc:usecase" mode="content"  />
		    <xsl:apply-templates select="uc:ucpackage" mode="content"  />
		    </body>
		</html>
	</xsl:template>
	
	<xsl:template match="uc:ucpackage" mode="ToC">
		<li>
			<a href="{translate(@URN,':','.')}.html">
				<xsl:apply-templates select="." mode="autonum" />
				<xsl:text>.&#160;</xsl:text>
				<xsl:value-of select="@xlink:title" />
			</a>
			<xsl:if test="uc:ucpackage">
				<ul>
					<xsl:apply-templates select="uc:ucpackage" mode="ToC" />
				</ul>
			</xsl:if>
		</li>
	</xsl:template>
	
	<xsl:template match="uc:ucpackage" mode="autonum">
		<xsl:apply-templates select="parent::uc:ucpackage[parent::uc:ucpackage]" mode="autonum" />
		<xsl:if test="parent::uc:ucpackage[parent::uc:ucpackage]">.</xsl:if>
		<xsl:value-of select="count(preceding-sibling::uc:ucpackage) + 1" />
	</xsl:template>
	
	<xsl:template match="uc:usecase" mode="ToC">
	    <xsl:variable name="href">
	        <xsl:call-template name="get-href">
	            <xsl:with-param name="urn" select="@URN" />
	        </xsl:call-template>
	    </xsl:variable>
		<li>
			<a href="{$href}"><xsl:value-of select="@xlink:title" /></a>
		</li>
	</xsl:template>
	
	<xsl:template match="uc:usecase" mode="content">
		<dt class="usecase">
			<xsl:attribute name="id">
				<xsl:value-of select="@ID" />
			</xsl:attribute>
			<xsl:value-of select="@xlink:title" />
		</dt>
		<dd>
			<p><small>URN: <xsl:value-of select="@URN" /></small></p>
			<p>	
				<small>
					<xsl:apply-templates  />
				</small>
			</p>
			<xsl:apply-templates select="html:script[@type='text/jumly+sequence']" mode="DIA" />
			<xsl:apply-templates select="html:script[@type = 'text/jumly+robustness']" mode="DIA" />
		</dd>
	</xsl:template>
	
	<xsl:template match="html:script[@type='text/jumly+sequence'] | html:script[@type='text/jumly+robustness']" />
	
	<xsl:template match="html:script[@type='text/jumly+sequence']" mode="DIA">
	    <p><small><strong>Sequence Diagramm</strong></small></p>
	    <xsl:element name="{local-name()}">
			<xsl:for-each select="@*">
				<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
			</xsl:for-each>
			<xsl:apply-templates select="node()" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="html:script[@type='text/jumly+robustness']" mode="DIA">
	    <p><small><strong>Robustness Diagramm</strong></small></p>
	    <xsl:element name="{local-name()}">
			<xsl:for-each select="@*">
				<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
			</xsl:for-each>
			<xsl:apply-templates select="node()" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="*[@xlink:href]">
		<xsl:variable name="urn">
			<xsl:choose>
				<xsl:when test="substring-after(@xlink:href,'#')">
					<xsl:value-of select="concat(ancestor::uc:ucpackage[1]/@URN,':',substring-after(@xlink:href,'#'))" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@xlink:href" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="link">
			<xsl:call-template name="get-href">
				<xsl:with-param name="urn" select="$urn" />
			</xsl:call-template>
		</xsl:variable>
		
		<a href="{$link}" title="{@xlink:title}">
			<xsl:value-of select="text()" />
		</a>
	</xsl:template>
	
	<!-- copy HTML for display -->
	<xsl:template match="html:*">
		<!-- remove the prefix on HTML elements -->
		<xsl:element name="{local-name()}">
			<xsl:for-each select="@*">
				<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
			</xsl:for-each>
			<xsl:apply-templates select="node()" />
		</xsl:element>
	</xsl:template>
	
	<!-- copy SVG for display -->
	<xsl:template match="svg:*">
		<xsl:element name="{local-name()}" namespace="http://www.w3.org/2000/svg">
			<xsl:for-each select="@*">
			    <xsl:choose>
			        <xsl:when test="local-name()='id'"></xsl:when>
			        <xsl:otherwise>
				        <xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
				    </xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="svg:image[@xlink:href]">
		<xsl:element name="g" namespace="http://www.w3.org/2000/svg">
			<xsl:attribute name="transform">
				<xsl:text>translate(</xsl:text>
				<xsl:value-of select="@x" />,<xsl:value-of select="@y" />
				<xsl:text>) scale(0.1)</xsl:text>
			</xsl:attribute>
			<xsl:copy-of select="$STICKMAN/svg:g/child::*" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="svg:svg">
		<svg xmlns="http://www.w3.org/2000/svg">
		    <xsl:for-each select="@*">
				<xsl:choose>
					<xsl:when test="local-name()='width'">
						<xsl:variable name="width" select="substring-before(.,'pt')" />
						<xsl:if test="$width &lt; 1000">
							<xsl:attribute name="{local-name()}">
								<xsl:value-of select="."/>
							</xsl:attribute>
						</xsl:if>
					</xsl:when>
					<!--xsl:when test="local-name()='height'"></xsl:when-->
					<xsl:otherwise>
						<xsl:attribute name="{local-name()}">
							<xsl:value-of select="."/>
						</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			<xsl:apply-templates select="node()" />
		</svg>
	</xsl:template>
	
	<xsl:template match="svg:a[@xlink:href]">
	    <xsl:apply-templates select="svg:*" />
	</xsl:template>
	
	<xsl:template match="svg:text[parent::svg:a/@xlink:href]">
		<xsl:variable name="term_id" select="." />
		<xsl:variable name="href">
			<xsl:call-template name="get-href">
				<xsl:with-param name="urn" select="parent::svg:a/@xlink:href" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:element name="{local-name()}" namespace="http://www.w3.org/2000/svg">
			<xsl:for-each select="@*">
				<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
			</xsl:for-each>
			<xsl:attribute name="fill">#005B9C</xsl:attribute>
			<xsl:attribute name="style">text-decoration:underline;font-family:Tahoma,serif;</xsl:attribute>
			<a xlink:href="{$href}" xlink:title="{$href}"><xsl:apply-templates select="node()" /></a>
		</xsl:element>
	</xsl:template>
	
	<!--xsl:template name="get-link">
		<xsl:param name="urn" />
		<xsl:choose>
			<xsl:when test="starts-with($urn,'glossary:')"><xsl:value-of select="concat('glossary.xml#',substring-after($urn,'glossary:'))" /></xsl:when>
			<xsl:when test="starts-with($urn,'ucpackage:')"><xsl:value-of select="concat('ucpackage.xml#',substring-after($urn,'ucpackage:'))" /></xsl:when>
		</xsl:choose>
	</xsl:template-->
	
</xsl:stylesheet>
