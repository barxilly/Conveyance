# Zip ~/Games/Conveyance into Build/Conveyance.love
zip -r Build/Conveyance.love . -x ".*" -x "*/.*" -x "Build/*" -x "build.sh" -x "README.md" -x "LICENSE"

# Fuse with love.exe
cat Build/love.exe Build/Conveyance.love > Build/Conveyance.exe

# Fuse with love
cat Build/love Build/Conveyance.love > Build/squashfs-root/bin/Conveyance

# Build AppImage
chmod +x Build/squashfs-root/bin/Conveyance
./Build/aptool.AppImage Build/squashfs-root Build/Conveyance.AppImage

# Zip exe and appimage into Build/Conveyance.zip
zip -r Build/Conveyance.zip Build/Conveyance.exe Build/Conveyance.AppImage