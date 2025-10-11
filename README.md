# gRPC Study Repo

gRPC를 Dart/Flutter에서 어떻게 구현하고 사용할 수 있는지를 데모로 만들었습니다.
/app-proto 디렉토리에 proto를 작성해놨으며, 명령어를 통해 생성할 수 있습니다.

gRPC관련 통신 유틸 코드들은 lib/core/util/grpc디렉토리에 위치해 있습니다.
(grpc interceptor, grpc datasource base, grpc stream handler등이 위치해있습니다)

data layer에 있는 각 도메인/기능 별 datasource들은 gRPC module의 채널을 주입받아 일관된 프로세스를 갖도록
해놨습니다.

# gRPC Proto 파일 생성 명령어

---bash
protoc \
 -I=app-proto \
 -I="$(brew --prefix)/include" \
 $(find app-proto -name '\*.proto') \
 --dart_out=grpc:lib/generated/ \
 google/protobuf/empty.proto \
 google/protobuf/timestamp.proto

---
