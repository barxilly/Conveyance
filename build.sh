# Get version number
version=$(grep -oP 'game.version = "\K[^"]+' game.lua)
echo -e "\033[1mBuilding Conveyance\033[0m"
echo "Checking whether version should be updated"

# If files with $version already exist, update version number
if [ -f Build/Archive/$version/Conveyance-$version.exe ]; then
    echo "Files with version $version already exist. Updating version number."
    numeric_version=$(echo $version | grep -oP '^[0-9]+\.[0-9]+\.[0-9]+')
    echo "Version number: $numeric_version"
    suffix=$(echo $version | sed -E "s/^$numeric_version//")
    echo "Suffix: $suffix"
    versionup=$(echo $numeric_version | awk -F. '{$NF = $NF + 1;} 1' | sed 's/ /./g')
    versionup="$versionup$suffix"
    sed -i "s/game.version = \"$version\"/game.version = \"$versionup\"/g" game.lua
    version=$(grep -oP 'game.version = "\K[^"]+' game.lua)
    sleep 1
fi

echo -e "\033[1mVersion: $version\033[0m"
sleep 1

## Love File
echo -e "\033[1mBuilding .love file\033[0m"
zip -q -r Build/Conveyance.love . -x ".*" -x "*/.*" -x "Build/*" -x "build.sh" -x "README.md" -x "LICENSE"
echo ".love created"
sleep 1

## Windows
echo -e "\033[1mBuilding Windows\033[0m"
cat Build/love.exe Build/Conveyance.love > Build/Conveyance-$version.exe
echo ".exe created, zipping with DLLs"
zip -q -r Build/Conveyance-$version-Windows-x64.zip Build/Conveyance-$version.exe Build/*.dll
echo "Built Windows"
sleep 1

## Linux
echo -e "\033[1mBuilding Linux\033[0m"
cat Build/love Build/Conveyance.love > Build/squashfs-root/bin/Conveyance
cat Build/love Build/Conveyance.love > Build/Conveyance-$version
echo "Making AppImage"
sleep 1
chmod +x Build/squashfs-root/bin/Conveyance
 ./Build/aptool.AppImage Build/squashfs-root Build/Conveyance-$version-Linux.AppImage
echo "Built Linux"
sleep 1

## MacOS
echo -e "\033[1mBuilding MacOS\033[0m"
cp Build/Conveyance.love Build/Conveyance.app/Contents/Resources/
zip -q -r Build/Conveyance-$version-MacOS.zip Build/Conveyance.app
echo "Built MacOS"
sleep 1

## Android
echo -e "\033[1mBuilding Android\033[0m"
cp Build/Conveyance.love Build/love-android/app/src/embed/assets/game.love
cd Build/love-android
python3 -c "import re; f = open('gradle.properties', 'r'); contents = f.read(); f.close(); contents = re.sub(r'app.version_name=(.*)', 'app.version_name=$version', contents); f = open('gradle.properties', 'w'); f.write(contents); f.close()"
version_code=$(grep -oP 'app.version_code=\K[^ ]+' gradle.properties)
version_code=$(($version_code + 1))
python3 -c "import re; f = open('gradle.properties', 'r'); contents = f.read(); f.close(); contents = re.sub(r'app.version_code=(.*)', 'app.version_code=$version_code', contents); f = open('gradle.properties', 'w'); f.write(contents); f.close()"
echo "Please head to Android Studio to build the APK. Press Enter once completed."
read
cd ../../
cp Build/love-android/app/build/outputs/apk/embedNoRecord/debug/app-embed-noRecord-debug.apk Build/Conveyance-$version-Android.apk
echo "Built Android"        
sleep 1

## Stage, Commit, and Push
echo -e "\033[1mStaging, committing, and pushing changes\033[0m"
git add .
git commit -m "Build v$version"
git push

## Upload to GitHub Releases
read -p "Do you want to publish the release on GitHub? (y/N): " publish
if [ "$publish" = "y" ]; then
    gh release create v$version Build/Conveyance-$version-Windows-x64.zip Build/Conveyance-$version-MacOS.zip Build/Conveyance-$version-Android.apk Build/Conveyance-$version-Linux.AppImage
else
    echo "Release not published."
fi

## Put all from this version into Build/Archive/$version
mkdir -p Build/Archive/$version
mv Build/Conveyance-$version* Build/Archive/$version
mv Build/Conveyance.love Build/Archive/$version

echo -e "\033[1;32mBuild $version complete\033[0m"
sleep 1