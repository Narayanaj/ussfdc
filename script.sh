# Test commit updated updated again deploy test
export WSPACE=${WORKSPACE}
dos2unix $WSPACE/version.txt 2>>/dev/null
        cd $WSPACE/manifest
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
echo $NEWPKGXML > $WSPACE/manifest/package.xml
cd $WSPACE
version=$(cat $WSPACE/version.txt)
git diff --oneline --name-only $version HEAD | grep -v version.txt |grep -v "Referenced Packages" > $WSPACE/modified_files
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
      *object*) TYPENAME="CustomObject";;
      *tab*) TYPENAME="CustomTab";;
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
      if grep -Fq "$TYPENAME" $WSPACE/manifest/package.xml
      then
      echo Generating new member for $ENTITY
      xmlstarlet ed -L -s "/Package/types[name='$TYPENAME']" -t elem -n members -v "$ENTITY" $WSPACE/manifest/package.xml
      else
      echo Generating new $TYPENAME type
      xmlstarlet ed -L -s /Package -t elem -n types -v "" $WSPACE/manifest/package.xml
      xmlstarlet ed -L -s '/Package/types[not(*)]' -t elem -n name -v "$TYPENAME" $WSPACE/manifest/package.xml
      echo Generating new member for $ENTITY
      xmlstarlet ed -L -s "/Package/types[name='$TYPENAME']" -t elem -n members -v "$ENTITY" $WSPACE/manifest/package.xml
      fi
      else
      echo ERROR: UNKNOWN FILE TYPE $CFILE
      fi
      done
      Cleaning up Package.xml
      xmlstarlet ed -L -s /Package -t elem -n version -v "44.0" $WSPACE/manifest/package.xml
      xmlstarlet ed -L -i /Package -t attr -n xmlns -v "http://soap.sforce.com/2006/04/metadata" $WSPACE/manifest/package.xml
     # list updated files
     cat $WSPACE/manifest/package.xml
