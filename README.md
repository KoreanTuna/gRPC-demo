INCLUDE="$(brew --prefix)/include"
protoc \
-I=proto-directory \
-I="$INCLUDE" \
$(find proto-directory '\*.proto') \
--dart_out=grpc:lib/generated/ \
google/protobuf/empty.proto \
google/protobuf/timestamp.proto
