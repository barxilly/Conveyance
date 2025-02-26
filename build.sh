# Get version number
version=$(grep -oP 'game.version = "\K[^"]+' game.lua)
echo "Building Conveyance v$version"

# If files with $version already exist, update version number
if [ -f Build/Archive/$version/Conveyance-$version.exe ]; then
    # Extract numeric part and suffix
    numeric_version=$(echo $version | grep -oP '^[0-9]+\.[0-9]+\.[0-9]+')
    echo "Version number: $numeric_version"
    suffix=$(echo $version | sed -E "s/^$numeric_version//")
    echo "Suffix: $suffix"

    # Increment version number
    versionup=$(echo $numeric_version | awk -F. '{$NF = $NF + 1;} 1' | sed 's/ /./g')
    versionup="$versionup$suffix"

    # Edit game.lua
    sed -i "s/game.version = \"$version\"/game.version = \"$versionup\"/g" game.lua

    # Get new version number
    version=$(grep -oP 'game.version = "\K[^"]+' game.lua)
    echo "Building Conveyance v$version"
    sleep 3
fi

echo "Building .love file"
## Love File
# Zip ~/Games/Conveyance into Build/Conveyance.love
zip -r Build/Conveyance.love . -x ".*" -x "*/.*" -x "Build/*" -x "build.sh" -x "README.md" -x "LICENSE"
echo ".love created"
sleep 1

echo "Building Windows"
## Windows
# Fuse with love.exe
cat Build/love.exe Build/Conveyance.love > Build/Conveyance-$version.exe

# Add Conveyance-*.exe and any dlls in Build to Conveyance-Windows-x64-$version.zip
zip -r Build/Conveyance-$version-Windows-x64.zip Build/Conveyance-$version.exe Build/*.dll
echo "Built Windows"
sleep 1

echo "Building Linux"
## Linux
# Fuse with love
cat Build/love Build/Conveyance.love > Build/squashfs-root/bin/Conveyance
cat Build/love Build/Conveyance.love > Build/Conveyance-$version

# Build AppImage
chmod +x Build/squashfs-root/bin/Conveyance
 ./Build/aptool.AppImage Build/squashfs-root Build/Conveyance-$version.AppImage
echo "Built Linux"
sleep 1

echo "Building MacOS"
## MacOS
cp Build/Conveyance.love Build/Conveyance.app/Contents/Resources/
# Build .zip
zip -r Build/Conveyance-$version-MacOS.zip Build/Conveyance.app
echo "Built MacOS"
sleep 1

echo "Building Android"
## Android
cp Build/Conveyance.love Build/love-android/app/src/embed/assets/game.love
cd Build/love-android
# Change version number in gradle.properties
python3 -c "import re; f = open('gradle.properties', 'r'); contents = f.read(); f.close(); contents = re.sub(r'app.version_name=(.*)', 'app.version_name=$version', contents); f = open('gradle.properties', 'w'); f.write(contents); f.close()"
# Up version code by 1 in gradle.properties
version_code=$(grep -oP 'app.version_code=\K[^ ]+' gradle.properties)
version_code=$(($version_code + 1))
python3 -c "import re; f = open('gradle.properties', 'r'); contents = f.read(); f.close(); contents = re.sub(r'app.version_code=(.*)', 'app.version_code=$version_code', contents); f = open('gradle.properties', 'w'); f.write(contents); f.close()"
#sudo ./gradlew build
echo "Please head to Android Studio to build the APK. Press Enter once completed."
read
cd ../../
cp Build/love-android/app/build/outputs/apk/embedNoRecord/debug/app-embed-noRecord-debug.apk Build/Conveyance-$version-Android.apk
echo "Built Android"        
sleep 1

## Stage, Commit, and Push
git add .
git commit -m "Build v$version"
git push

## Upload to GitHub Releases
read -p "Do you want to publish the release on GitHub? (y/N): " publish
if [ "$publish" = "y" ]; then
    gh release create v$version Build/Conveyance-$version-Windows-x64.zip Build/Conveyance-$version-MacOS.zip Build/Conveyance-$version-Android.apk
else
    echo "Release not published."
fi


## Put all from this version into Build/Archive/$version
mkdir -p Build/Archive/$version
mv Build/Conveyance-$version* Build/Archive/$version
mv Build/Conveyance.love Build/Archive/$version