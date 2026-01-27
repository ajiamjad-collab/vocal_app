/*import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

// Isar
//import 'package:isar/isar.dart';
import 'package:isar_community/isar.dart';

import 'package:path_provider/path_provider.dart';

import '../storage/local_storage.dart';
import '../network/network_info.dart';

import '../theme/theme_cubit.dart';
import '../theme/theme_storage.dart';

import '../offline/offline_queue.dart';
import '../auth/token_refresh_service.dart';

import '../cache/cache_store.dart';
import '../cache/isar_cache_store.dart';
import '../cache/models/cache_entry.dart';

import '../firebase/functions_client.dart';

// Auth / Profile
import 'package:vocal_app/features/presentation/bloc/auth_bloc.dart';

import '../../features/auth/data/datasources/auth_remote_ds.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_email.dart';
import '../../features/auth/domain/usecases/sign_in_google.dart';
import '../../features/auth/domain/usecases/sign_up_email.dart';
import '../../features/auth/domain/usecases/send_verification.dart';
import '../../features/auth/domain/usecases/reset_password.dart';
import '../../features/auth/domain/usecases/reload_user.dart';
import '../../features/auth/domain/usecases/reauthenticate.dart';
import '../../features/auth/domain/usecases/delete_account.dart';
import '../../features/auth/domain/usecases/sign_out.dart';

import '../../features/profile/data/datasources/user_profile_remote_ds.dart';
import 'package:vocal_app/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:vocal_app/features/profile/domain/repositories/user_profile_repository_impl.dart';
import 'package:vocal_app/features/profile/domain/usecases/create_user_profile.dart';

import 'package:vocal_app/features/brands/data/datasources/brand_remote_ds.dart';
import 'package:vocal_app/features/brands/data/repositories/brand_repository_impl.dart';
import 'package:vocal_app/features/brands/domain/repositories/brand_repository.dart';

import 'package:firebase_storage/firebase_storage.dart';

// Brands
import 'package:vocal_app/features/brands/domain/usecases/create_brand.dart';
import 'package:vocal_app/features/brands/domain/usecases/get_brands_page.dart';
import 'package:vocal_app/features/brands/domain/usecases/watch_brand.dart';
import 'package:vocal_app/features/brands/domain/usecases/increment_brand_visit.dart';
import 'package:vocal_app/features/brands/presentation/bloc/brands_bloc.dart';
import 'package:vocal_app/features/brands/presentation/bloc/brand_create_cubit.dart';
import 'package:vocal_app/features/brands/presentation/bloc/brand_detail_cubit.dart';

const String? kWebClientId = null;

const String kFunctionsRegion = 'asia-south1';
const String kFirestoreDatabaseId = 'default';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Firebase
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn(clientId: kWebClientId));

  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: kFirestoreDatabaseId,
    ),
  );

  sl.registerLazySingleton<FirebaseFunctions>(() {
    return FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: kFunctionsRegion,
    );
  });

  // ✅ Functions wrapper (use this everywhere instead of FirebaseFunctions directly)
  sl.registerLazySingleton(() => FunctionsClient(sl<FirebaseFunctions>()));

  // Core libs
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Theme
  sl.registerLazySingleton<ThemeStorage>(() => ThemeStorage(sl<SharedPreferences>()));
  sl.registerFactory<ThemeCubit>(() => ThemeCubit(sl<ThemeStorage>()));

  // Core
  sl.registerLazySingleton<LocalStorage>(() => LocalStorage(sl<SharedPreferences>()));

  // ✅ NetworkInfo (keeps your existing usage)
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfo(sl<Connectivity>()));

  // ✅ Offline Queue (Cloud Functions runner)
  sl.registerLazySingleton<OfflineQueue>(
    () => OfflineQueue(
      prefs: sl<SharedPreferences>(),
      connectivity: sl<Connectivity>(),
      runner: (task) async {
        if (task.type == "sync_email_verified") {
          await sl<FirebaseFunctions>()
              .httpsCallable("syncEmailVerificationStatus")
              .call(task.payload.isEmpty ? {} : task.payload);
          return;
        }
        throw Exception("Unknown offline task type: ${task.type}");
      },
    ),
  );

  // ✅ Token refresh handling
  sl.registerLazySingleton<TokenRefreshService>(() => TokenRefreshService(sl<FirebaseAuth>()));

  // ✅ Auth Remote DS
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      auth: sl<FirebaseAuth>(),
      googleSignIn: sl<GoogleSignIn>(),
      functions: sl<FirebaseFunctions>(),
      offlineQueue: sl<OfflineQueue>(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl<AuthRemoteDataSource>()),
  );

  // ✅ User Profile DS + Repo
  sl.registerLazySingleton<UserProfileRemoteDataSource>(
    () => UserProfileRemoteDataSourceImpl(
      functions: sl<FirebaseFunctions>(),
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
    ),
  );

  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(remote: sl<UserProfileRemoteDataSource>()),
  );

  // Firebase Storage
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // -----------------------
  // Brands
  // -----------------------
  sl.registerLazySingleton<BrandRemoteDataSource>(() => BrandRemoteDataSourceImpl(
        firestore: sl<FirebaseFirestore>(),
        functions: sl<FunctionsClient>(),
        storage: sl<FirebaseStorage>(),
        auth: sl<FirebaseAuth>(),
      ));

  sl.registerLazySingleton<BrandRepository>(() => BrandRepositoryImpl(remote: sl<BrandRemoteDataSource>()));

  sl.registerLazySingleton(() => GetBrandsPage(sl<BrandRepository>()));
  sl.registerLazySingleton(() => WatchBrand(sl<BrandRepository>()));
  sl.registerLazySingleton(() => CreateBrand(sl<BrandRepository>()));
  sl.registerLazySingleton(() => IncrementBrandVisit(sl<BrandRepository>()));

  sl.registerFactory(() => BrandsBloc(getBrandsPage: sl<GetBrandsPage>()));
  sl.registerFactory(() => BrandCreateCubit(createBrand: sl<CreateBrand>()));
  sl.registerFactory(() => BrandDetailCubit(
        watchBrand: sl<WatchBrand>(),
        incrementBrandVisit: sl<IncrementBrandVisit>(),
      ));

  // Usecases
  sl.registerLazySingleton(() => SignInEmail(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignInGoogle(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignUpEmail(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SendVerification(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPassword(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ReloadUser(sl<AuthRepository>()));
  sl.registerLazySingleton(() => Reauthenticate(sl<AuthRepository>()));
  sl.registerLazySingleton(() => DeleteAccount(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignOut(sl<AuthRepository>()));

  sl.registerLazySingleton(() => CreateUserProfile(sl<UserProfileRepository>()));

  // ✅ Optional app cache (Isar) - KEEP only if you use it elsewhere
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [CacheEntrySchema],
    directory: dir.path,
    inspector: true,
  );
  sl.registerLazySingleton<Isar>(() => isar);
  sl.registerLazySingleton<CacheStore>(() => IsarCacheStore(sl<Isar>()));

  // Bloc
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      signInEmail: sl(),
      signInGoogle: sl(),
      signUpEmail: sl(),
      sendVerification: sl(),
      resetPassword: sl(),
      reloadUser: sl(),
      reauthenticate: sl(),
      deleteAccount: sl(),
      signOut: sl(),
      localStorage: sl<LocalStorage>(),
      createUserProfile: sl<CreateUserProfile>(),
    ),
  );
}
*/
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Isar
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../storage/local_storage.dart';
import '../network/network_info.dart';
import '../theme/theme_cubit.dart';
import '../theme/theme_storage.dart';
import '../offline/offline_queue.dart';
import '../auth/token_refresh_service.dart';
import '../cache/cache_store.dart';
import '../cache/isar_cache_store.dart';
import '../cache/models/cache_entry.dart';

import '../firebase/functions_client.dart';

// Auth / Profile
import 'package:vocal_app/features/presentation/bloc/auth_bloc.dart';
import '../../features/auth/data/datasources/auth_remote_ds.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_email.dart';
import '../../features/auth/domain/usecases/sign_in_google.dart';
import '../../features/auth/domain/usecases/sign_up_email.dart';
import '../../features/auth/domain/usecases/send_verification.dart';
import '../../features/auth/domain/usecases/reset_password.dart';
import '../../features/auth/domain/usecases/reload_user.dart';
import '../../features/auth/domain/usecases/reauthenticate.dart';
import '../../features/auth/domain/usecases/delete_account.dart';
import '../../features/auth/domain/usecases/sign_out.dart';

import '../../features/profile/data/datasources/user_profile_remote_ds.dart';
import 'package:vocal_app/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:vocal_app/features/profile/domain/repositories/user_profile_repository_impl.dart';
import 'package:vocal_app/features/profile/domain/usecases/create_user_profile.dart';

import 'package:vocal_app/features/brands/data/datasources/brand_remote_ds.dart';
import 'package:vocal_app/features/brands/data/repositories/brand_repository_impl.dart';
import 'package:vocal_app/features/brands/domain/repositories/brand_repository.dart';

import 'package:vocal_app/features/brands/domain/usecases/create_brand.dart';
import 'package:vocal_app/features/brands/domain/usecases/get_brands_page.dart';
import 'package:vocal_app/features/brands/domain/usecases/watch_brand.dart';
import 'package:vocal_app/features/brands/domain/usecases/increment_brand_visit.dart';
import 'package:vocal_app/features/brands/presentation/bloc/brands_bloc.dart';
import 'package:vocal_app/features/brands/presentation/bloc/brand_create_cubit.dart';
import 'package:vocal_app/features/brands/presentation/bloc/brand_detail_cubit.dart';

const String? kWebClientId = null;

const String kFunctionsRegion = 'asia-south1';
const String kFirestoreDatabaseId = 'default';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // IMPORTANT: ensure Firebase is initialized before this
  // await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Firebase core services
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn(clientId: kWebClientId));

  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: kFirestoreDatabaseId,
    ),
  );

  // ✅ CRITICAL: Force region for Cloud Functions
  sl.registerLazySingleton<FirebaseFunctions>(
    () => FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: kFunctionsRegion,
    ),
  );

  // ✅ Storage on same Firebase app
  sl.registerLazySingleton<FirebaseStorage>(
    () => FirebaseStorage.instanceFor(app: Firebase.app()),
  );

  // Optional wrapper (fine to keep)
  sl.registerLazySingleton(() => FunctionsClient(sl<FirebaseFunctions>()));

  // Core libs
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Theme
  sl.registerLazySingleton<ThemeStorage>(() => ThemeStorage(sl<SharedPreferences>()));
  sl.registerFactory<ThemeCubit>(() => ThemeCubit(sl<ThemeStorage>()));

  // Core
  sl.registerLazySingleton<LocalStorage>(() => LocalStorage(sl<SharedPreferences>()));
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfo(sl<Connectivity>()));

  // Offline Queue (functions runner)
  sl.registerLazySingleton<OfflineQueue>(
    () => OfflineQueue(
      prefs: sl<SharedPreferences>(),
      connectivity: sl<Connectivity>(),
      runner: (task) async {
        final functions = sl<FirebaseFunctions>();
        if (task.type == "sync_email_verified") {
          await functions
              .httpsCallable("syncEmailVerificationStatus")
              .call(task.payload.isEmpty ? {} : task.payload);
          return;
        }
        throw Exception("Unknown offline task type: ${task.type}");
      },
    ),
  );

  sl.registerLazySingleton<TokenRefreshService>(() => TokenRefreshService(sl<FirebaseAuth>()));

  // Auth Remote DS
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      auth: sl<FirebaseAuth>(),
      googleSignIn: sl<GoogleSignIn>(),
      functions: sl<FirebaseFunctions>(),
      offlineQueue: sl<OfflineQueue>(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl<AuthRemoteDataSource>()),
  );

  // ✅ User Profile DS + Repo
  sl.registerLazySingleton<UserProfileRemoteDataSource>(
    () => UserProfileRemoteDataSourceImpl(
      functions: sl<FirebaseFunctions>(),      // regioned
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
    ),
  );

  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(remote: sl<UserProfileRemoteDataSource>()),
  );

  // Brands
  sl.registerLazySingleton<BrandRemoteDataSource>(
    () => BrandRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
      functions: sl<FunctionsClient>(),
      storage: sl<FirebaseStorage>(),
      auth: sl<FirebaseAuth>(),
    ),
  );

  sl.registerLazySingleton<BrandRepository>(
    () => BrandRepositoryImpl(remote: sl<BrandRemoteDataSource>()),
  );

  sl.registerLazySingleton(() => GetBrandsPage(sl<BrandRepository>()));
  sl.registerLazySingleton(() => WatchBrand(sl<BrandRepository>()));
  sl.registerLazySingleton(() => CreateBrand(sl<BrandRepository>()));
  sl.registerLazySingleton(() => IncrementBrandVisit(sl<BrandRepository>()));

  sl.registerFactory(() => BrandsBloc(getBrandsPage: sl<GetBrandsPage>()));
  sl.registerFactory(() => BrandCreateCubit(createBrand: sl<CreateBrand>()));
  sl.registerFactory(() => BrandDetailCubit(
        watchBrand: sl<WatchBrand>(),
        incrementBrandVisit: sl<IncrementBrandVisit>(),
      ));

  // Usecases
  sl.registerLazySingleton(() => SignInEmail(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignInGoogle(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignUpEmail(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SendVerification(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPassword(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ReloadUser(sl<AuthRepository>()));
  sl.registerLazySingleton(() => Reauthenticate(sl<AuthRepository>()));
  sl.registerLazySingleton(() => DeleteAccount(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignOut(sl<AuthRepository>()));

  sl.registerLazySingleton(() => CreateUserProfile(sl<UserProfileRepository>()));

  // Isar cache (optional)
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [CacheEntrySchema],
    directory: dir.path,
    inspector: true,
  );
  sl.registerLazySingleton<Isar>(() => isar);
  sl.registerLazySingleton<CacheStore>(() => IsarCacheStore(sl<Isar>()));

  // Bloc
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      signInEmail: sl(),
      signInGoogle: sl(),
      signUpEmail: sl(),
      sendVerification: sl(),
      resetPassword: sl(),
      reloadUser: sl(),
      reauthenticate: sl(),
      deleteAccount: sl(),
      signOut: sl(),
      localStorage: sl<LocalStorage>(),
      createUserProfile: sl<CreateUserProfile>(),
    ),
  );
}
