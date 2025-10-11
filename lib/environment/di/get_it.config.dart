// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:go_router/go_router.dart' as _i583;
import 'package:grpc/grpc.dart' as _i1017;
import 'package:grpc_study/common/data/datasource/auth_datasource.dart'
    as _i410;
import 'package:grpc_study/common/data/grpc_mapper/auth_grpc_mapper.dart'
    as _i249;
import 'package:grpc_study/common/data/repository/auth_repository_impl.dart'
    as _i745;
import 'package:grpc_study/common/domain/repository/auth_repository.dart'
    as _i957;
import 'package:grpc_study/common/domain/usecase/logout_usecase.dart' as _i681;
import 'package:grpc_study/common/domain/usecase/token_usecase.dart' as _i910;
import 'package:grpc_study/core/router/go_router.dart' as _i524;
import 'package:grpc_study/core/util/grpc/grpc_module.dart' as _i311;
import 'package:grpc_study/core/util/grpc/interceptor/grpc_auth_interceptor.dart'
    as _i601;
import 'package:grpc_study/core/util/grpc/interceptor/grpc_logging_interceptor.dart'
    as _i869;
import 'package:grpc_study/core/util/secure_storage_util.dart' as _i406;
import 'package:grpc_study/feature/home/presentation/view_model/home_view_model.dart'
    as _i815;
import 'package:grpc_study/feature/login/domain/login_usecase.dart' as _i905;
import 'package:grpc_study/feature/login/presentation/view_model/login_view_model.dart'
    as _i511;
import 'package:injectable/injectable.dart' as _i526;
import 'package:talker_grpc_logger/talker_grpc_logger.dart' as _i27;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final secureStorageModule = _$SecureStorageModule();
    final goRouterModule = _$GoRouterModule();
    final grpcModule = _$GrpcModule();
    gh.factory<_i249.AuthGrpcMapper>(() => _i249.AuthGrpcMapper());
    gh.singleton<_i558.FlutterSecureStorage>(
      () => secureStorageModule.createSecureStorage(),
    );
    gh.singleton<_i583.GoRouter>(() => goRouterModule.router());
    gh.lazySingleton<_i869.LoggingInterceptor>(
      () => grpcModule.loggingInterceptor(),
    );
    gh.lazySingleton<_i27.TalkerGrpcLogger>(
      () => grpcModule.talkerGrpcLogger(),
    );
    gh.singleton<_i406.SecureStorageUtil>(
      () => _i406.SecureStorageUtil(gh<_i558.FlutterSecureStorage>()),
    );
    await gh.lazySingletonAsync<_i1017.ClientChannel>(
      () => grpcModule.defaultChannel(),
      instanceName: 'default_channel',
      preResolve: true,
    );
    await gh.lazySingletonAsync<_i1017.ClientChannel>(
      () => grpcModule.streamChannel(),
      instanceName: 'stream_channel',
      preResolve: true,
    );
    gh.lazySingleton<_i601.AuthInterceptor>(
      () => grpcModule.authInterceptor(gh<_i406.SecureStorageUtil>()),
    );
    gh.singleton<List<_i1017.ClientInterceptor>>(
      () => grpcModule.interceptors(
        gh<_i869.LoggingInterceptor>(),
        gh<_i601.AuthInterceptor>(),
        gh<_i27.TalkerGrpcLogger>(),
      ),
    );
    gh.singleton<_i410.AuthDatasource>(
      () => _i410.AuthDatasource(
        gh<_i1017.ClientChannel>(instanceName: 'default_channel'),
        gh<List<_i1017.ClientInterceptor>>(),
      ),
    );
    gh.lazySingleton<_i957.AuthRepository>(
      () => _i745.AuthRepositoryImpl(
        gh<_i410.AuthDatasource>(),
        gh<_i249.AuthGrpcMapper>(),
      ),
    );
    gh.lazySingleton<_i910.TokenUsecase>(
      () => _i910.TokenUsecase(
        gh<_i957.AuthRepository>(),
        gh<_i406.SecureStorageUtil>(),
      ),
    );
    gh.lazySingleton<_i905.LoginUsecase>(
      () => _i905.LoginUsecase(
        gh<_i957.AuthRepository>(),
        gh<_i910.TokenUsecase>(),
      ),
    );
    gh.lazySingleton<_i681.LogoutUsecase>(
      () => _i681.LogoutUsecase(
        gh<_i957.AuthRepository>(),
        gh<_i910.TokenUsecase>(),
      ),
    );
    gh.factory<_i815.HomeViewModel>(
      () => _i815.HomeViewModel(gh<_i681.LogoutUsecase>()),
    );
    gh.factory<_i511.LoginViewModel>(
      () => _i511.LoginViewModel(gh<_i905.LoginUsecase>()),
    );
    return this;
  }
}

class _$SecureStorageModule extends _i406.SecureStorageModule {}

class _$GoRouterModule extends _i524.GoRouterModule {}

class _$GrpcModule extends _i311.GrpcModule {}
