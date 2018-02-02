(cd frontend && yarn run build)
statik --src=frontend/dist
gox -output="build/{{.Dir}}_{{.OS}}_{{.Arch}}" -osarch="linux/386 linux/amd64 linux/arm linux/arm64 darwin/amd64" ./cmd/*
