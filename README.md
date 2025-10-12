# gRPC Study Repo

gRPC를 Dart/Flutter에서 어떻게 구현하고 사용할 수 있는지를 데모로 만들었습니다.
/app-proto 디렉토리에 proto를 작성해놨으며, 명령어를 통해 생성할 수 있습니다.

gRPC관련 통신 유틸 코드들은 lib/core/util/grpc디렉토리에 위치해 있습니다.
(grpc interceptor, grpc datasource base, grpc stream handler등이 위치해있습니다)

data layer에 있는 각 도메인/기능 별 datasource들은 gRPC module의 채널을 주입받아 일관된 프로세스를 갖도록
해놨습니다.

## 네트워크 계층 구조
- Presentation: ViewModel이 유스케이스를 통해 도메인 명령을 수행합니다.
- Domain: UseCase -> Repository 인터페이스를 통해 인프라 계층과 분리된 비즈니스 로직을 유지합니다.
- Data: Repository 구현체가 Datasource에 위임해 gRPC Stub을 호출하고, Mapper가 Proto ↔ Domain 모델을 변환합니다.
- Infrastructure: `GrpcModule`이 채널과 인터셉터를 생성해 공통 설정(보안, 압축, 메타데이터)을 제공합니다.

## gRPC 통신 플로우
### 1. 인증이 필요 없는 Unary 호출 (로그인/토큰 갱신)
1. UI에서 전달된 입력을 `LoginUsecase`가 검증한 뒤 `AuthRepository`로 전달합니다.
2. Repository는 `AuthDatasource`를 통해 gRPC Stub (`UserLoginServiceClient`, `TokenServiceClient`)을 호출합니다.
3. `GrpcOptions.defaultCallOptions()`가 타임아웃과 공용 메타데이터(`x-language-code`)를 적용합니다.
4. 응답을 `AuthGrpcMapper`가 `TokenEntity`로 변환하고, `SecureStorageUtil`이 토큰을 저장합니다.

### 2. 인증이 필요한 호출 (로그아웃, 채팅 스트리밍)
1. Repository/Datasource가 CallOptions에 `x-requires-auth: true`를 설정합니다.
2. `AuthInterceptor`가 Access Token을 Authorization 헤더로 주입하고, 401 응답 시 `TokenUsecase.refreshToken()`을 통해 한 번 재시도합니다.
3. `LoggingInterceptor`가 요청/응답 Proto를 JSON으로 직렬화해 디버깅 로그를 남깁니다.


### Unary Auth Intercepot
```mermaid
sequenceDiagram
    autonumber
    participant APP as App(호출부)
    participant INT as AuthInterceptor
    participant SEC as SecureStorageUtil
    participant TOK as TokenUsecase
    participant SRV as gRPC Server

    APP->>INT: interceptUnary(method, request, options)
    INT->>INT: _shouldInject(options.metadata)
    alt authFlagKey == "true"
        Note over INT: 토큰 주입을 위한 CallOptions 병합
        INT->>INT: options.mergedWith(providers:[_attachAccessToken])
        INT->>SEC: getAccessToken()
        SEC-->>INT: "Bearer <token>"
        INT->>SRV: invoker(method, request, mergedOptions + Authorization)
        SRV-->>INT: ResponseFuture<R> (headers/body/trailers)

        alt 응답 성공
            INT->>INT: _completeMetadata(response.headers/trailers)
            INT-->>APP: value (ResponseFuture 완료)
        else 에러 발생
            INT->>INT: _shouldRetryAfterRefreshingToken(error, hasRetried=false)
            alt error == UNAUTHENTICATED && hasRetried == false
                INT->>TOK: refreshToken()
                TOK-->>INT: success?
                alt refresh 성공
                    Note over INT: hasRetried = true<br/>같은 invoker로 재호출(루프)
                    INT->>SRV: invoker(method, request, mergedOptions) (재시도)
                    SRV-->>INT: ResponseFuture<R>
                    alt 재시도 성공
                        INT->>INT: _completeMetadata(response.headers/trailers)
                        INT-->>APP: value
                    else 재시도도 실패
                        INT->>INT: _completeMetadata(response.headers/trailers)
                        INT-->>APP: error
                    end
                else refresh 실패
                    INT->>INT: _completeMetadata(response.headers/trailers)
                    INT-->>APP: error
                end
            else 재시도 불가(다른 에러 또는 이미 재시도함)
                INT->>INT: _completeMetadata(response.headers/trailers)
                INT-->>APP: error
            end
        end
    else authFlagKey 미설정/false
        INT->>SRV: invoker(method, request, options) (토큰 주입 없음)
        SRV-->>INT: ResponseFuture<R>
        INT-->>APP: value/error
    end

    rect rgba(0,0,0,0.03)
    note over APP,INT: cancel() 흐름
    APP->>INT: cancel()
    INT->>INT: proxy.updateCancel(response.cancel)
    INT-->>APP: cancel 완료 (현재 response.cancel 위임)
    end
```

### 3. 채팅 양방향 스트리밍
```mermaid
sequenceDiagram
  participant UI as HomeViewModel
  participant Usecase as ChatUsecase
  participant Repo as ChatRepositoryImpl
  participant DS as ChatDatasource
  participant Stub as ChatServiceClient
  participant Server as ChatService

  UI->>Usecase: openSession(userName)
  Usecase->>Repo: openSession(userName)
  Repo->>DS: openChatConnection()
  DS->>Stub: openChatConnection(stream) + metadata
  Stub->>Server: HTTP/2 stream opened
  Server-->>DS: SendMessage(stream)
  DS-->>Repo: Result.ok(ChatMessage)
  Repo-->>UI: Stream<Result<ChatMessage>>
  UI-)UI: 메시지 표시
  UI->>Repo: sendUserMessage(text)
  Repo->>Stub: ReceiveMessage(stream)
  Stub->>Server: 전송
  note right of Server: 서버 응답이 끝나면 스트림 종료
```

`ChatDatasource`는 `GrpcDatasourceBase`를 상속받아 DI로 주입된 스트리밍 전용 채널(`@Named('stream_channel')`)과 인터셉터를 재사용합니다. 스트림 연결과 해제를 `GrpcBidirectionalStreamHandler`가 담당하며, 모든 응답을 `Result` 타입으로 래핑해 도메인이 통일된 오류 처리를 수행할 수 있게 합니다.

## 토큰 수명주기
- 로그인 성공 시 Access/Refresh Token을 `SecureStorageUtil`에 저장합니다.
- 앱 실행 시 `SplashViewModel`이 저장된 토큰 존재 여부를 확인하고 `TokenUsecase.refreshToken()`으로 세션을 연장합니다.
- 인증 API 실패 또는 강제 로그아웃 시 `LogoutUsecase`가 gRPC 로그아웃 요청 결과를 그대로 UI에 전달하고, 로컬 토큰은 항상 정리해 상태 불일치를 방지합니다.

## 참고: 공통 gRPC 유틸
- `GrpcOptions`: Unary/Streaming CallOptions에 타임아웃과 공통 메타데이터를 적용합니다.
- `GrpcBidirectionalStreamHandler`: 양방향 스트림을 열고, 응답 스트림을 `Result`로 변환하며, 구독/종료/에러 처리를 캡슐화합니다.
- `grpc/interceptor/*`: 인증 토큰 주입, 재시도, Proto JSON 로깅 등 클라이언트 공통 교차 관심사를 분리합니다.

# gRPC Proto 파일 생성 명령어

```bash
protoc \
 -I=app-proto \
 -I="$(brew --prefix)/include" \
 $(find app-proto -name '*.proto') \
 --dart_out=grpc:lib/generated/ \
 google/protobuf/empty.proto \
 google/protobuf/timestamp.proto

```
