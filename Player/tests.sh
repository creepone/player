/usr/local/bin/xctool -workspace Player.xcworkspace -scheme Player -sdk iphonesimulator build-tests
/usr/local/bin/xctool -workspace Player.xcworkspace -scheme Player -sdk iphonesimulator -reporter teamcity run-tests