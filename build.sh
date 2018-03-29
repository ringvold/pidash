echo "Start building pidash"
echo ""
echo "Building frontend"
(cd frontend && yarn run build)
echo ""
echo "Embeding frontend into Go app"
statik --src=frontend/dist
echo ""
echo "Building go binaries to ./build"
gox -output="build/{{.Dir}}_{{.OS}}_{{.Arch}}" \
    -osarch="linux/386 linux/amd64 linux/arm linux/arm64 darwin/amd64" \
    ./cmd/*
echo ""
echo "ALL DONE! :D"
