#  make sure that the revision.prefix file is updated so that it contains the actual build number
echo "#define BUILD_NUMBER $BUILD_NUMBER" > Player/revision.prefix
touch Player/Info.plist