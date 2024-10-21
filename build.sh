# On the Mac with M1
docker buildx build --platform linux/arm64 -t nickzren/hetionet:latest-arm64 --push .

# On the Amazon Linux 2023
docker buildx build --platform linux/amd64 -t nickzren/hetionet:latest-amd64 --push .

# Create a multi-platform manifest to combine the two images
docker buildx imagetools create --tag nickzren/hetionet:latest \
    nickzren/hetionet:latest-arm64 \
    nickzren/hetionet:latest-amd64