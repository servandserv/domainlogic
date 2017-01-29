<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns="urn:com:servandserv:domainlogic:ucpackage"
	xmlns:uc="urn:com:servandserv:domainlogic:ucpackage"
	xmlns:toc="urn:com:servandserv:domainlogic:toc"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:wadl="http://wadl.dev.java.net/2009/02"
	
	extension-element-prefixes="exsl"
	exclude-result-prefixes="">
	
    <xsl:output
        media-type="application/xml"
        method="xml"
        encoding="UTF-8"
        indent="yes"
        omit-xml-declaration="no" />
	
	
	<xsl:variable name="ROOT" select="/uc:ucpackage" />
	<xsl:variable name="UCPACKAGE-ID" select="/uc:ucpackage/@ID" />
	<xsl:variable name="UCPACKAGE-TITLE" select="/uc:ucpackage/@xlink:title" />
	<xsl:variable name="UCPACKAGE-HREF" select="/uc:ucpackage/@xlink:href" />
	
	<!-- package path  -->
	<!--xsl:variable name="PROJECT-BASE">
		<xsl:call-template name="get-base">
			<xsl:with-param name="path" select="$UCPACKAGE-ID"/>
		</xsl:call-template>
	</xsl:variable-->
	
	<xsl:variable name="UCPACKAGES">
		<!--xsl:variable name="ucpackage" select="document(concat($PROJECT-BASE,'temp.xml'), /)/uc:ucpackage"></xsl:variable-->
		<xsl:element name="uc:ucpackage">
			<!--xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="$ROOT/@xlink:title"/>
			</xsl:attribute>
			<xsl:attribute name="ID">
				<xsl:value-of select="$ucpackage/@ID"/>
			</xsl:attribute-->
			<xsl:copy-of select="$ROOT/@*" />
			<xsl:attribute name="URN">
				<xsl:value-of select="$ROOT/@ID"/>
			</xsl:attribute>
			<xsl:apply-templates select="$ROOT/uc:ucpackage[@xlink:type='locator']" mode="include">
			    <xsl:with-param name="package-urn" select="$ROOT/@ID" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:variable>
	
	<xsl:template match="uc:ucpackage" mode="include">
	    <xsl:param name="package-urn" />
		<xsl:variable name="ucpackage-path" select="@xlink:href" />
		<xsl:variable name="included" select="document($ucpackage-path,/)/uc:ucpackage"></xsl:variable>
		<xsl:element name="uc:ucpackage">
		    <xsl:variable name="URN" select="concat($package-urn,':',$included/@ID)" />
			<xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="$included/@xlink:title"/>
			</xsl:attribute>
			<xsl:attribute name="ID">
				<xsl:value-of select="$included/@ID"/>
			</xsl:attribute>
			<xsl:attribute name="PACKAGE-URN">
			    <xsl:value-of select="$package-urn" />
			</xsl:attribute>
			<xsl:attribute name="URN">
				<xsl:value-of select="$URN" />
			</xsl:attribute>
			<xsl:apply-templates select="$included/uc:*" mode="include" >
				<xsl:with-param name="package-urn" select="$URN" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="uc:usecase" mode="include">
		<xsl:param name="package-urn" />
		<xsl:element name="uc:usecase">
			<xsl:attribute name="ID">
			    <xsl:value-of select="@xlink:label"/>
			</xsl:attribute>
			<xsl:attribute name="URN">
			    <xsl:value-of select="concat($package-urn,':',@xlink:label)"/>
			</xsl:attribute>
			<xsl:attribute name="PACKAGE-URN">
			    <xsl:value-of select="$package-urn"/>
			</xsl:attribute>
			<xsl:attribute name="xlink:label" namespace="http://www.w3.org/1999/xlink">
			    <xsl:value-of select="concat($package-urn,':',@xlink:label)"/>
			</xsl:attribute>
			<xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="@xlink:title"/>
			</xsl:attribute>
			<xsl:copy-of select="node()" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="uc:actor" mode="include">
		<xsl:param name="package-urn" />
		<xsl:element name="uc:actor">
		    <xsl:attribute name="ID">
			    <xsl:value-of select="@xlink:label"/>
			</xsl:attribute>
			<xsl:attribute name="URN">
			    <xsl:value-of select="concat($package-urn,':',@xlink:label)"/>
			</xsl:attribute>
			<xsl:attribute name="PACKAGE-URN">
			    <xsl:value-of select="$package-urn"/>
			</xsl:attribute>
			<xsl:attribute name="xlink:label" namespace="http://www.w3.org/1999/xlink">
			    <xsl:value-of select="concat($package-urn,':',@xlink:label)"/>
			</xsl:attribute>
			<xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">
			    <xsl:value-of select="@xlink:href"/>
			</xsl:attribute>
			<xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
				<xsl:value-of select="@xlink:title"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>
	
	<!--js scripts diagramm -->
	<xsl:template match="uc:script" mode="include">
	    <xsl:element name="script" namespace="http://www.w3.org/1999/xhtml">
	        <xsl:attribute name="type">
	            <xsl:value-of select="@type" />
	        </xsl:attribute>
	        <xsl:value-of select="." disable-output-escaping="yes" />
	    </xsl:element> 
	</xsl:template>
	
	<!-- docs for project api with wadl -->
	<xsl:template match="uc:wadl[@xlink:type='locator']" mode="include">
		<xsl:param name="package-urn" />
		<xsl:variable name="included" select="document(@xlink:href, /)/wadl:application"></xsl:variable>
		<xsl:for-each select="$included//wadl:resource">
			<xsl:element name="uc:usecase">
				<xsl:attribute name="ID">
				    <xsl:value-of select="@id"/>
				</xsl:attribute>
				<xsl:attribute name="URN">
				    <xsl:value-of select="concat($package-urn,':',@id)"/>
				</xsl:attribute>
				<xsl:attribute name="PACKAGE-URN">
				    <xsl:value-of select="$package-urn" />
				</xsl:attribute>
				<xsl:attribute name="xlink:title" namespace="http://www.w3.org/1999/xlink">
					<xsl:value-of select="wadl:doc/@title"/>
				</xsl:attribute>
				<xsl:attribute name="xlink:label" namespace="http://www.w3.org/1999/xlink">
					<xsl:value-of select="concat($package-urn,':',@id)"/>
				</xsl:attribute>
				<xsl:copy-of select="wadl:doc" />
				<xsl:for-each select="wadl:method">
					<xsl:element name="h4" namespace="http://www.w3.org/1999/xhtml">Method <xsl:value-of select="@name" /></xsl:element>
					<xsl:copy-of select="wadl:request/wadl:doc" />
					<xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
						<xsl:for-each select="wadl:response">
							<xsl:element name="p"  namespace="http://www.w3.org/1999/xhtml">
								<xsl:if test="substring(@status,1,1) &gt; 3">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:if>
								(Status <xsl:value-of select="@status" />)
								<xsl:copy-of select="./wadl:representation/wadl:doc"/>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="uc:*" mode="include">
		<xsl:copy-of select="." />
	</xsl:template>
	
	<xsl:variable name="UCPACKAGES-SET" select="exsl:node-set($UCPACKAGES)" />
	
	<xsl:template match="uc:ucpackage">
		<!--xsl:processing-instruction name="xml-stylesheet">
			<xsl:text>href="stylesheets/glossary/ucpackage.xsl" type="text/xsl"</xsl:text>
		</xsl:processing-instruction-->
		<xsl:copy-of select="$UCPACKAGES-SET" />
	</xsl:template>
	
	<!-- utils -->
	<!--xsl:template name="get-base">
		<xsl:param name="path" />
		<xsl:if test="contains($path, ':')">
			<xsl:text>../</xsl:text>
			<xsl:call-template name="get-base">
				<xsl:with-param name="path" select="substring-after($path,':')" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template-->
	
</xsl:stylesheet>
