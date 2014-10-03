# make sure we fail on non-zero exit code of commands
set -e
set -o pipefail

# package and deploy the ipa file
xcrun -sdk iphoneos PackageApplication -v "build/Baladeur.app" -o "$DEPLOY_PATH/Baladeur.ipa" --sign "$SIGN_WITH" --embed "$PROVISION_PATH"

# deploy the manifest
echo "BUILD_NUMBER=$BUILD_NUMBER" > "$DEPLOY_PATH/baladeur.manifest"