#!/bin/sh

realp() {
    echo `perl -e 'use Cwd "abs_path";print abs_path(shift)' $1`
}

f="/dev/null"
mkfile() {
    f=$2
    mkdir -p `dirname $f`
    echo "" >$f
    chmod 775 $f
}

set -e

# realpath to ini file
iniPath=$(dirname $(realp $1))
invokePath=$(pwd)
dlPath=$(dirname $(realp $0))

cd $iniPath

appName=$(sed -n -e 's/^\s*appName\s*=\s*//p' $1)
if [ -z "${appName}" ]; then
    echo "Error: app name variable not found" >&2
    exit 1
fi

# tmp builf directory realpath
tmpBuildPath=$(sed -n -e 's/^\s*tmpBuildPath\s*=\s*//p' $1)
printf "%-50s [OK] %s\n" "tmp build path" ${iniPath}/${tmpBuildPath}
mkdir -p $tmpBuildPath

tmpXml=$(realp ${iniPath}/${tmpBuildPath})/temp.xml

# tmp clean flag
tmpClean=$(sed -n -e 's/^\s*tmpClean\s*=\s*//p' $1)
if [ "${tmpClean}" == 1 ]; then
    #  clean tmp dir
    trap 'rm -rf -- $tmpBuildPath' EXIT
fi

sourcePath=$(sed -n -e 's/^\s*sourcePath\s*=\s*//p' $1)
if [ -z "${sourcePath}" ]; then
    echo "Error: source files path variable not found" >&2
    exit 1
fi
if [ ! -d "${sourcePath}" ]; then
    echo "Error: source dir not found" >&2
    exit 1
fi
printf "%-50s [OK] %s\n" "source files path" ${iniPath}/${sourcePath}

docsPath=$(sed -n -e 's/^\s*docsPath\s*=\s*//p' $1)
if [ -z "${docsPath}" ]; then
    echo "Error: docs path variable not found" >&2
    exit 1
fi
if [ -d "${docsPath}" ]; then
    rm -rf ${docsPath}
fi
printf "%-50s [OK] %s\n" "html documents files path" ${iniPath}/${docsPath}
mkdir -p ${docsPath}
cp -R "${dlPath}/resources/css" "${docsPath}"
cp -R "${dlPath}/resources/js" "${docsPath}"

# stylesheets
domain2Docs="${dlPath}/resources/stylesheets/domain2docs.xsl";
ucpackage2Docs="${dlPath}/resources/stylesheets/ucpackage2docs.xsl";
domain2Dot="${dlPath}/resources/stylesheets/domain2dot.xsl";
ucpackage2Dot="${dlPath}/resources/stylesheets/ucpackage2dot.xsl";
domain2HTML="${dlPath}/resources/stylesheets/domain2html.xsl";
ucpackage2HTML="${dlPath}/resources/stylesheets/ucpackage2html.xsl";
docs2TOC="${dlPath}/resources/stylesheets/docs2TOC.xsl";

find ${iniPath}/${sourcePath}/domain -type f | while read j; do
    xmllint --noout --schema ${dlPath}/resources/schemas/com/servandserv/domainlogic/domain.xsd ${j}
done

find ${iniPath}/${sourcePath}/ucpackage -type f | while read j; do
    xmllint --noout --schema ${dlPath}/resources/schemas/com/servandserv/domainlogic/ucpackage.xsd ${j}
done

# copy stickman svg to tmp build dir
cp "${dlPath}/resources/images/stickman.svg" ${iniPath}/${tmpBuildPath}

echo "<?xml version='1.0' encoding='utf-8'?><empty/>" > ${tmpBuildPath}/empty.xml
# all domain model description files
echo "<?xml version='1.0' encoding='utf-8'?>\n<d:domain ID='domain' base='${iniPath}/${sourcePath}' xlink:title='Domain models' xmlns:d='urn:com:servandserv:domainlogic:domain' xmlns:xlink='http://www.w3.org/1999/xlink'>" > $tmpXml
cd ${sourcePath}/domain
for j in *.xml; do
	echo "<d:domain xlink:type='locator' xlink:href='${j}' />" >> $tmpXml
done
echo "</d:domain>" >> $tmpXml

# build domain models xml
xsltproc --path . ${domain2Docs} $tmpXml > ${iniPath}/${tmpBuildPath}/domains.xml
printf "%-50s [OK] %s\n" "concatenate all domain models in one file"

# build domain model diagramms
find ${iniPath}/${sourcePath}/domain -type f | while read j; do
	pack="${j%.xml}"
	pack="${pack#${iniPath}/${sourcePath}/domain/}"
    package=$(echo "domain:$pack" | tr '/' ':')
    
	mkdir -p ${iniPath}/${tmpBuildPath}/graphviz/$pack
	mkdir -p ${iniPath}/${tmpBuildPath}/images/$pack
	
	xsltproc  --stringparam PACKAGE "$package" ${domain2Dot} ${iniPath}/${tmpBuildPath}/domains.xml > ${iniPath}/${tmpBuildPath}/graphviz/$pack/domain.dot
	printf "%-50s [OK] %s\n" "build ${package} dot"
	dot -Tsvg -o${iniPath}/${tmpBuildPath}/images/$pack/domain.svg ${iniPath}/${tmpBuildPath}/graphviz/$pack/domain.dot
	printf "%-50s [OK] %s\n" "build ${package} svg images"
done

cd ${iniPath}/${sourcePath}/ucpackage
# all use cases packages
echo "<?xml version='1.0' encoding='utf-8'?>\n<uc:ucpackage ID='ucpackage' xlink:title='Usecases package' xmlns:uc='urn:com:servandserv:domainlogic:ucpackage' xmlns:xlink='http://www.w3.org/1999/xlink' dir='${dlPath}'>" > $tmpXml
for j in *.xml; do
	echo "<uc:ucpackage xlink:type='locator' xlink:href='${j}' />" >> $tmpXml
done
echo "</uc:ucpackage>" >> $tmpXml

xsltproc --path . ${ucpackage2Docs} $tmpXml > ${iniPath}/${tmpBuildPath}/ucpackage.xml
printf "%-50s [OK] %s\n" "concatenate all use case packages in one file"

# build use cases diagramms
find ${iniPath}/${sourcePath}/ucpackage -type f | while read j; do
	pack="${j%.xml}"
	pack="${pack#${iniPath}/${sourcePath}/ucpackage/}"
	package=$(echo "ucpackage:$pack" | tr '/' ':')

    mkdir -p ${iniPath}/${tmpBuildPath}/graphviz/$pack
	mkdir -p ${iniPath}/${tmpBuildPath}/images/$pack

	xsltproc  --stringparam PACKAGE "$package" ${ucpackage2Dot} ${iniPath}/${tmpBuildPath}/ucpackage.xml > ${iniPath}/${tmpBuildPath}/graphviz/$pack/ucpackage.dot
	printf "%-50s [OK] %s\n" "build ${package} dot"
	dot -Tsvg -o${iniPath}/${tmpBuildPath}/images/$pack/ucpackage.svg ${iniPath}/${tmpBuildPath}/graphviz/$pack/ucpackage.dot
	printf "%-50s [OK] %s\n" "build ${package} svg images"
done

# все пакеты интерфейсов проекта
#echo "<?xml version='1.0' encoding='utf-8'?><interface ID='interface' xlink:title='Интерфейсы' xmlns='urn:ru:ilb:meta:glossary:interface' xmlns:xlink='http://www.w3.org/1999/xlink'>" > temp.xml
#for j in interface/*.xml; do
#	echo "<interface xlink:type='locator' xlink:href='${j}' />" >> temp.xml
#done
#echo "</interface>" >> temp.xml

# собираем вcе прецеденты проекта
#xsltproc stylesheets/glossary/interface2docs.xsl temp.xml > interface.xml
#chmod 777 interface.xml

cd $iniPath
# prepare documentation table of contents
xsltproc --stringparam APPNAME "${appName}" --path ${iniPath}/${tmpBuildPath} ${docs2TOC} ${tmpBuildPath}/empty.xml > ${tmpBuildPath}/TOC.xml
printf "%-50s [OK] %s\n" "prepare table of contents xml file"

# generate html views
echo "<?php header('Location: domain.html');"  > ${docsPath}/index.php
echo "" > ${tmpBuildPath}/html.txt
docsPath=$(realp $docsPath)
xsltproc --path ${iniPath}/${tmpBuildPath} --stringparam APPNAME "$appName" --stringparam DEST "${docsPath}" --novalid ${domain2HTML} ${tmpBuildPath}/domains.xml >> ${tmpBuildPath}/html.txt
printf "%-50s [OK] %s\n" "prepare domain model html code"
xsltproc --path ${iniPath}/${tmpBuildPath} --stringparam APPNAME "$appName" --stringparam DEST "${docsPath}" --novalid ${ucpackage2HTML} ${tmpBuildPath}/ucpackage.xml >> ${tmpBuildPath}/html.txt
printf "%-50s [OK] %s\n" "prepare ucpackage html code"

cat ${tmpBuildPath}/html.txt | while IFS= read -r s; do
    if [[ "$s" = "#path:"* ]]
    then
        mkfile $s
    else
        echo "$s" >>$f
    fi
done
printf "%-50s [OK] %s\n" "generate html files"