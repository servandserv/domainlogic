<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:wadl="http://wadl.dev.java.net/2009/02"
	xmlns:d="urn:com:servandserv:domainlogic:domain"
	xmlns:uc="urn:com:servandserv:domainlogic:ucpackage"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	extension-element-prefixes="exsl"
    exclude-result-prefixes="html xlink d uc xsl">
	
    <xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
	
	<xsl:param name="PACKAGE" />
	<xsl:variable name="ROOT" select="/uc:ucpackage" />
	<xsl:variable name="UCPACKAGE-URN" select="$PACKAGE" />
	
	<xsl:variable name="UCPACKAGE" select="$ROOT//uc:ucpackage[@URN = $UCPACKAGE-URN]" />
	<xsl:variable name="USECASES" select="$ROOT//uc:usecase" />
	
	<!-- dot -->
	<xsl:template match="uc:ucpackage">
digraph usecase_<xsl:value-of select="translate($UCPACKAGE-URN,':','_')" /> {
		<xsl:for-each select="$UCPACKAGE/uc:actor">
			<xsl:text>
	subgraph cluster</xsl:text>
			<xsl:variable name="urn">
			    <xsl:call-template name="get-urn">
				    <xsl:with-param name="label" select="@xlink:label" />
				    <xsl:with-param name="node" select="." />
			    </xsl:call-template>
			</xsl:variable>
			<xsl:value-of select="translate($urn,':','_')" />
			<xsl:text> {
		label="</xsl:text>
			<xsl:call-template name="split-spaces">
				<xsl:with-param name="str" select="@xlink:title" />
				<xsl:with-param name="splitter" select="' '" />
			</xsl:call-template>
			<xsl:text>";labelloc="b";peripheries=0;margin=0;pad=0;fontname=Tahoma;fontsize=10;URL="</xsl:text>
			<xsl:value-of select="@xlink:href"/>
			<xsl:text>";</xsl:text>
			<xsl:value-of select="translate($urn,':','_')" />
			<xsl:text>
	};
	
	"</xsl:text>
	    <xsl:value-of select="translate($urn,':','_')" />
	    <xsl:text>" [label="",shapefile="</xsl:text><xsl:value-of select="$ROOT/@dir" /><xsl:text>/resources/images/stickman.svg",peripheries=0,margin=0];</xsl:text>
		</xsl:for-each>
		<xsl:text>
	subgraph cluster_package {
		style="dashed,bold";
		label="</xsl:text><xsl:value-of select="$UCPACKAGE-URN" /><xsl:text>";
		node [shape=ellipse,style="bold",color=grey,fontname=Tahoma,fontsize=12,height=.5];</xsl:text>
		
		<xsl:for-each select="$UCPACKAGE/uc:usecase">
			<xsl:apply-templates select="." mode="node" />
		</xsl:for-each>
		<xsl:text>
	}
	// use
	edge [fontname=Tahoma,fontsize=10]
	edge [arrowhead="none",color=grey];</xsl:text>
		<xsl:for-each select="$UCPACKAGE/uc:use">
			<xsl:variable name="tail_urn">
				<xsl:call-template name="get-urn">
					<xsl:with-param name="label" select="@xlink:from" />
					<xsl:with-param name="node" select="." />
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="head_urn">
				<xsl:call-template name="get-urn">
					<xsl:with-param name="label" select="@xlink:to" />
					<xsl:with-param name="node" select="." />
				</xsl:call-template>
			</xsl:variable>
			<xsl:text>
	</xsl:text>
			<xsl:value-of select="translate($tail_urn,':','_')" />
			<xsl:text> -&gt; </xsl:text>
			<xsl:value-of select="translate($head_urn,':','_')" />
			<xsl:if test="@xlink:label">[label="<xsl:value-of select="@xlink:label" />"]</xsl:if>
			<xsl:text>;</xsl:text>
		</xsl:for-each>
		<xsl:text>
	// proceed
	node [shape=ellipse,style="bold,filled",height=.5,fillcolor=yellow,color=grey];
	edge [arrowhead="vee",style="dashed,bold",label="&#171;proceed&#187;",color=red];</xsl:text>
	<xsl:apply-templates select="$UCPACKAGE/uc:proceed" mode="edge" />
	<xsl:apply-templates select="$UCPACKAGE/uc:proceed-mand" mode="edge" />
	<xsl:text>
	edge [arrowhead="vee",style="dashed,bold",label="&#171;proceed&#187;",color=grey];</xsl:text>
	<xsl:apply-templates select="$UCPACKAGE/uc:proceed-opt" mode="edge" />
	<xsl:text>
	// invoke
	edge [arrowhead="vee",style="dashed,bold",label="&#171;invoke&#187;",color=grey];</xsl:text>
	<xsl:apply-templates select="$UCPACKAGE/uc:invoke-opt" mode="edge" />
	<xsl:text>
	edge [arrowhead="vee",style="dashed,bold",label="&#171;invoke&#187;",color=blue];</xsl:text>
	<xsl:apply-templates select="$UCPACKAGE/uc:invoke" mode="edge" />
	<xsl:apply-templates select="$UCPACKAGE/uc:invoke-mand" mode="edge" />
	<xsl:text>
	// extend
	edge [arrowhead="vee",style="dashed,bold",label="&#171;extend&#187;",color=green];</xsl:text>
	<xsl:apply-templates select="$UCPACKAGE/uc:extend" mode="edge" />
	<xsl:text>
	labelloc=t;
	rankdir=LR;
	compound=true;
	color=grey;
	fontsize=12;

}</xsl:text>
	</xsl:template>

	<xsl:template name="split-spaces">
		<xsl:param name="str" />
		<xsl:param name="splitter" />
		<xsl:choose>
			<xsl:when test="contains($str,$splitter)">
				<xsl:variable name="before" select="substring-before($str,$splitter)" />
				<xsl:value-of select="$before" />
				<!--  делаем перенос строки только на словах длиной более 3-х символов
				-->
				<xsl:choose>
					<xsl:when test="string-length($before) &gt; 3">
						<xsl:text>\n</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="split-spaces">
					<xsl:with-param name="str" select="substring-after($str,$splitter)" />
					<xsl:with-param name="splitter" select="$splitter" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$str" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="uc:usecase" mode="node">
		<xsl:variable name="urn">
			<xsl:call-template name="get-urn">
				<xsl:with-param name="label" select="@URN" />
				<xsl:with-param name="node" select="." />
			</xsl:call-template>
		</xsl:variable>
		<xsl:text>
	    </xsl:text>
		<xsl:value-of select="translate($urn,':','_')" />
		<xsl:text> [label="</xsl:text>
		<xsl:call-template name="split-spaces">
			<xsl:with-param name="str" select="@xlink:title" />
			<xsl:with-param name="splitter" select="' '" />
		</xsl:call-template>
		<xsl:text>",tooltip="</xsl:text>
		<xsl:value-of select="$urn" />
		<xsl:text>",URL="</xsl:text>
		<xsl:value-of select="$urn" />
		<xsl:text>",fontname=Tahoma,fontsize=12];</xsl:text>
	</xsl:template>
	
	<xsl:template match="uc:proceed | uc:proceed-opt | uc:proceed-mand | uc:invoke | uc:invoke-opt | uc:invoke-mand | uc:extend" mode="edge">
	    <xsl:variable name="label">
	        <xsl:choose>
	            <xsl:when test="substring-before(name(),'proceed')">&#171;proceed&#187;</xsl:when>
	            <xsl:when test="substring-before(name(),'extend')">&#171;extend&#187;</xsl:when>
	            <xsl:otherwise>&#171;invoke&#187;</xsl:otherwise>
	        </xsl:choose>
	    </xsl:variable>
		<xsl:variable name="tail_urn">
			<xsl:call-template name="get-urn">
				<xsl:with-param name="label" select="@xlink:from" />
				<xsl:with-param name="node" select="." />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="head_urn">
			<xsl:call-template name="get-urn">
				<xsl:with-param name="label" select="@xlink:to" />
				<xsl:with-param name="node" select="." />
			</xsl:call-template>
		</xsl:variable>
		
		<!--  добавим узлы прецедентов из других пакетов  -->
		<xsl:if test="not($UCPACKAGE/uc:usecase[@URN=$tail_urn])">
			<xsl:apply-templates select="$USECASES[@URN=$tail_urn]" mode="node" />
		</xsl:if>
		
		<xsl:if test="not($UCPACKAGE/uc:usecase[@URN=$head_urn])">
			<xsl:apply-templates select="$USECASES[@URN=$head_urn]" mode="node" />
		</xsl:if>
		<xsl:text>
	</xsl:text>
		<xsl:value-of select="translate($tail_urn,':','_')" />
		<xsl:text> -&gt; </xsl:text>
		<xsl:value-of select="translate($head_urn,':','_')" />
		<xsl:if test="@xlink:label">[label="<xsl:value-of select="$label" />\n<xsl:value-of select="@xlink:label" />"]</xsl:if>
		<xsl:text>;</xsl:text>
	</xsl:template>
	
	<!-- utils -->
	<xsl:template name="get-urn">
		<xsl:param name="label" />
		<xsl:param name="node" />
		<xsl:choose>
			<xsl:when test="substring-after($label,'#')">
				<xsl:value-of select="concat($node/ancestor::uc:ucpackage[1]/@URN,':',substring-after($label,'#'))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$label" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>