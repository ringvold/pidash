statik --src=frontend/dist
gox -output="bin/{{.Dir}}_{{.OS}}_{{.Arch}}" -osarch="linux/386 linux/amd64 linux/arm linux/arm64 darwin/amd64"
