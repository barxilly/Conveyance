# Get version number
version=$(grep -oP 'game.version = "\K[^"]+' game.lua)
echo "Building Conveyance v$version"

# Zip ~/Games/Conveyance into Build/Conveyance.love
zip -r Build/Conveyance.love . -x ".*" -x "*/.*" -x "Build/*" -x "build.sh" -x "README.md" -x "LICENSE"

# Fuse with love.exe
cat Build/love.exe Build/Conveyance.love > Build/Conveyance-$version.exe

# Add Conveyance-*.exe and any dlls in Build to Conveyance-Windows-x64-$version.zip
zip -r Build/Conveyance-$version-Windows-x64.zip Build/Conveyance-$version.exe Build/*.dll

# Fuse with love
cat Build/love Build/Conveyance.love > Build/squashfs-root/bin/Conveyance

# Build AppImage
chmod +x Build/squashfs-root/bin/Conveyance
./Build/aptool.AppImage Build/squashfs-root Build/Conveyance-$version.AppImage

# Name the love
mv Build/Conveyance.love Build/Conveyance-$version.love