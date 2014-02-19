# package and deploy the ipa file
xcrun -sdk iphoneos PackageApplication -v "build/Release-iphoneos/Player.app" -o "$DEPLOY_PATH/Player.ipa" --sign "$SIGN_WITH" --embed "$PROVISION_PATH"

# deploy the manifest
echo "BUILD_NUMBER=$BUILD_NUMBER" > "$DEPLOY_PATH/player.manifest"