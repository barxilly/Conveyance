# Get version number
version=$(grep -oP 'game.version = "\K[^"]+' game.lua)
echo "Building Conveyance v$version"

## Love File
# Zip ~/Games/Conveyance into Build/Conveyance.love
zip -r Build/Conveyance.love . -x ".*" -x "*/.*" -x "Build/*" -x "build.sh" -x "README.md" -x "LICENSE"

## Windows
# Fuse with love.exe
cat Build/love.exe Build/Conveyance.love > Build/Conveyance-$version.exe

# Add Conveyance-*.exe and any dlls in Build to Conveyance-Windows-x64-$version.zip
zip -r Build/Conveyance-$version-Windows-x64.zip Build/Conveyance-$version.exe Build/*.dll

## Linux
# Fuse with love
cat Build/love Build/Conveyance.love > Build/squashfs-root/bin/Conveyance
cat Build/love Build/Conveyance.love > Build/Conveyance-$version

# Build AppImage
chmod +x Build/squashfs-root/bin/Conveyance
./Build/aptool.AppImage Build/squashfs-root Build/Conveyance-$version.AppImage

## MacOS
cp Build/Conveyance.love Build/Conveyance.app/Contents/Resources/
# Build .zip
zip -r Build/Conveyance-$version-MacOS.zip Build/Conveyance.app
