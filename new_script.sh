# generate_package_xml.sh <workspace directory>
#get list of modified files
#script updated with commit


#export WSPACE=$1
export WSPACE=${WORKSPACE}

dos2unix $WSPACE/version.txt 2>>/dev/null


        cd $WSPACE/src
        echo changing directoy to $WSPACE
        cp package.xml{,.bak} &&
        echo Backing up package.xml to package.xml.bak
read -d '' NEWPKGXML << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Package>
</Package>
EOF

        echo ===PKGXML===
        echo $NEWPKGXML
        echo Creating new package.xml
        echo $NEWPKGXML > $WSPACE/src/package.xml

cd $WSPACE
version=$(cat $WSPACE/version.txt)
git diff --oneline --name-only $version HEAD | grep -v version.txt |grep -v "Referenced Packages" > $WSPACE/modified_files
mkdir dist

for CFILE in `cat modified_files`
do
        echo Analyzing file `basename $CFILE`

        case "$CFILE"
                in
                        *.cls*) TYPENAME="ApexClass";;
                        *.page*) TYPENAME="ApexPage";;
                        *.component*) TYPENAME="ApexComponent";;
                        *.trigger*) TYPENAME="ApexTrigger";;
                        *.app*) TYPENAME="CustomApplication";;
                        *.labels*) TYPENAME="CustomLabels";;
						*.object*) TYPENAME="CustomObject";;
                        *.tab*) TYPENAME="CustomTab";;
                        *.resource*) TYPENAME="StaticResource";;
                        *.workflow*) TYPENAME="Workflow";;
                        *.remoteSite*) TYPENAME="RemoteSiteSettings";;
                        *.pagelayout*) TYPENAME="Layout";;
                        *) TYPENAME="UNKNOWN TYPE";;
        esac

                if [[ "$TYPENAME" != "UNKNOWN TYPE" ]]
                then
                        ENTITY=$(basename "$CFILE")
                        ENTITY="${ENTITY%.*}"
                        echo ENTITY NAME: $ENTITY

                        if grep -Fq "$TYPENAME" $WSPACE/src/package.xml
                        then
                                echo Generating new member for $ENTITY
                                xmlstarlet ed -L -s "/Package/types[name='$TYPENAME']" -t elem -n members -v "$ENTITY" $WSPACE/src/package.xml
                        else
                                echo Generating new $TYPENAME type
                                xmlstarlet ed -L -s /Package -t elem -n types -v "" $WSPACE/src/package.xml
                                xmlstarlet ed -L -s '/Package/types[not(*)]' -t elem -n name -v "$TYPENAME" $WSPACE/src/package.xml
                                echo Generating new member for $ENTITY
                                xmlstarlet ed -L -s "/Package/types[name='$TYPENAME']" -t elem -n members -v "$ENTITY" $WSPACE/src/package.xml
                        fi
                else
                        echo ERROR: UNKNOWN FILE TYPE $CFILE
                fi

                echo Analyzing file `basename $CFILE`
                cp --parents -R $CFILE $WSPACE/dist
done
echo Cleaning up Package.xml
        xmlstarlet ed -L -s /Package -t elem -n version -v "44.0" $WSPACE/src/package.xml
        xmlstarlet ed -L -i /Package -t attr -n xmlns -v "http://soap.sforce.com/2006/04/metadata" $WSPACE/src/package.xml


echo ====UPDATED PACKAGE.XML====
sed -i '/cls-meta/d' $WSPACE/src/package.xml
cat $WSPACE/src/package.xml

echo ====DELTA TEST CLASSES=====
grep -i test $WSPACE/modified_files | grep -v meta.xml | awk -F '/' '{print $NF}' > $WPACE/modified_test
cat $WPACE/modified_test

echo ===COPY REQUIRED FILES TO DIST===
cp $WSPACE/src/package.xml $WSPACE/dist/package.xml
cp $WSPACE/modified_files $WSPACE/dist/modified_files
cp $WPACE/modified_test $WSPACE/dist/modified_test
