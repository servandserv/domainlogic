<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:d="urn:com:servandserv:domainlogic:domain"
	xmlns:toc="urn:com:servandserv:domainlogic:toc"
	xmlns:uc="urn:com:servandserv:domainlogic:ucpackage"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	extension-element-prefixes="exsl"
    exclude-result-prefixes="xhtml xlink d uc toc xsl">
	
	<xsl:output method="html" omit-xml-declaration="yes" indent="yes" />
	<!--xsl:output method="text" omit-xml-declaration="yes" indent="no"/-->
	
	<xsl:variable name="TOC" select="document('TOC.xml')/toc:toc" />
	<xsl:variable name="DOMAINS" select="document('domains.xml')//d:domain" />
	<xsl:variable name="ENTITIES" select="document('domains.xml')//d:entity" />
	<xsl:variable name="UCPACKAGES" select="document('ucpackage.xml')//uc:ucpackage" />
	
	<xsl:template match="toc:chapter">
		<xsl:variable name="href">
		    <xsl:call-template name="get-href">
		        <xsl:with-param name="urn" select="@id" />
		    </xsl:call-template>
		</xsl:variable>
		<li>
			<a href="{$href}"><xsl:value-of select="@title" /></a>
			<xsl:if test="toc:chapter">
				<ul>
					<xsl:apply-templates select="toc:chapter" />
				</ul>
			</xsl:if>
		</li>
	</xsl:template>
	
	<xsl:template name="header">
		<xsl:param name="path" select="''" />
		<div class="header">
			<a href="#" alt="Меню">
			    <svg xmlns="http://www.w3.org/2000/svg" height="120px" width="32px" style="background:#00385F;" viewBox="0 0 32 120">
				    <g transform="translate(-12,120)">
					    <text x="10" y="32" fill="white" 
						    transform="rotate(-90)" style="font-size:16px;font-family:Verdana;"><xsl:value-of select="$APPNAME" /></text>
				    </g>
			    </svg>
			</a>
			<div>
				<ul>
					<xsl:apply-templates select="$TOC/toc:chapter" />
				</ul>
			</div>
		</div>
	</xsl:template>
	
	<!--xsl:template name="table-of-content">
		<xsl:variable name="menu" select="document('TOC.xml',/)/toc:toc" />
		<div id="toc">
			<h1>CCRM Документация</h1>
			<hr/>
			<ul>
				<xsl:apply-templates select="$menu/toc:chapter" />
			</ul>
		</div>
	</xsl:template-->
	
	<xsl:template name="get-href">
	    <xsl:param name="urn" />
	    <xsl:param name="path" select="''"/>
	    <xsl:choose>
	        <xsl:when test="substring($urn,1,4) = 'http' or substring($urn,1,2) = '..'">
	            <!-- foreign links -->
	            <xsl:value-of select="$urn" />
	        </xsl:when>
	        <xsl:when test="substring($urn,1,1) = '#'">
	            <!-- local domain/ucpackage links -->
	            <xsl:variable name="anchor">
	                <xsl:value-of select="substring-after($urn,'#')" />
	            </xsl:variable>
	            <!-- построим из него адрес -->
	            <xsl:variable name="href">
	                <xsl:call-template name="get-href">
	                    <xsl:with-param name="urn" select="$anchor" />
	                </xsl:call-template>
	            </xsl:variable>
	            <xsl:choose>
	                <xsl:when test="substring($href,1,4) = 'html#'">
	                    <xsl:value-of select="$urn" />
	                </xsl:when>
	                <xsl:otherwise>
	                    <xsl:value-of select="$href" />
	                </xsl:otherwise>
	            </xsl:choose>
	        </xsl:when>
	        <xsl:when test="substring-before($urn,':')">
	            <!--в urn есть еще несколько узлов-->
	            <xsl:variable name="before" select="substring-before($urn,':')" />
	            <xsl:choose>
	                <xsl:when test="not(substring-after($path,'domain:')) and $DOMAINS[@URN = concat('comain:',$path,$before)]">
	                    <!--и следующий узел тоже указывает на пакет-->
	                    <xsl:call-template name="get-href">
	                        <xsl:with-param name="urn" select="substring-after($urn,concat($before,':'))" />
	                        <xsl:with-param name="path" select="concat($path,$before,':')" />
	                    </xsl:call-template>
	                </xsl:when>
	                <xsl:when test="not(substring-after($path,'ucpackage:')) and $UCPACKAGES[@URN = concat($path,$before)]">
	                    <!--и следующий узел тоже указывает на пакет-->
	                    <xsl:call-template name="get-href">
	                        <xsl:with-param name="urn" select="substring-after($urn,concat($before,':'))" />
	                        <xsl:with-param name="path" select="concat($path,$before,':')" />
	                    </xsl:call-template>
	                </xsl:when>
	                <xsl:when test="$DOMAINS[@URN = concat($path,$before)] or $UCPACKAGES[@URN = concat($path,$before)]">
	                    <!--и следующий узел тоже указывает на пакет-->
	                    <xsl:call-template name="get-href">
	                        <xsl:with-param name="urn" select="substring-after($urn,concat($before,':'))" />
	                        <xsl:with-param name="path" select="concat($path,$before,':')" />
	                    </xsl:call-template>
	                </xsl:when>
	                <xsl:otherwise>
	                    <!--остановимся, следующий кусок относится к якорю вида id:subid внутри страницы-->
	                    <xsl:value-of select="translate($path,':','.')" />
	                    <xsl:text>html#</xsl:text>
	                    <xsl:value-of select="$urn" />
	                </xsl:otherwise>
	            </xsl:choose>
	        </xsl:when>
	        <xsl:otherwise>
	            <!--остался один узел-->
	            <xsl:choose>
	                <xsl:when test="not(substring-after($path,'domain:')) and $DOMAINS[@URN = concat('domain:',$path,$urn)]">
	                    <!--и следующий узел тоже указывает на пакет -->
	                    <xsl:value-of select="concat('domain.',translate($path,':','.'),$urn)" />
	                    <xsl:text>.html</xsl:text>
	                </xsl:when>
	                <xsl:when test="not(substring-after($path,'ucpackage:')) and $UCPACKAGES[@URN = concat('ucpackage:',$path,$urn)]">
	                    <!--и следующий узел тоже указывает на пакет -->
	                    <xsl:value-of select="concat('ucpackage.',translate($path,':','.'),$urn)" />
	                    <xsl:text>.html</xsl:text>
	                </xsl:when>
	                <xsl:when test="$DOMAINS[@URN = concat($path,$urn)] or $UCPACKAGES[@URN = concat($path,$urn)]">
	                    <!--и следующий узел тоже указывает на пакет -->
	                    <xsl:value-of select="concat(translate($path,':','.'),$urn)" />
	                    <xsl:text>.html</xsl:text>
	                </xsl:when>
	                <xsl:otherwise>
	                    <!-- якорь внутри страницы -->
	                    <xsl:value-of select="translate($path,':','.')" />
	                    <xsl:text>html#</xsl:text>
	                    <xsl:value-of select="$urn" />
	                </xsl:otherwise>
	            </xsl:choose>
	        </xsl:otherwise>
	    </xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>