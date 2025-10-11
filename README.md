protoc \
 -I=app-proto \
 -I="$INCLUDE" \
 $(find app-proto -name '\*.proto') \
 --dart_out=grpc:lib/generated/ \
 google/protobuf/empty.proto \
 google/protobuf/timestamp.proto

protoc \  
 -I=app-proto \
 -I="$INCLUDE" \
 $(find app-proto -name '\*.proto') \
 --dart_out=grpc:lib/generated/ \
 google/protobuf/empty.proto \
 google/protobuf/timestamp.proto
