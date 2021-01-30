ver=${1:?Must provide version string}

make -j8

if test -d dist; then
    rm -r dist
fi

mkdir dist
mkdir dist/zshelf

cp -r backend dist/zshelf
cp zshelf dist/zshelf
cp config.json dist/zshelf
cp README.md dist/zshelf

cd dist
zip -r "zshelf-reMarkable-${ver}.zip" ./zshelf/