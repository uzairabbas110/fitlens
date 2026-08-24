import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/stylist_remote_data_source.dart';
import '../data/repositories/stylist_repository_impl.dart';
import '../domain/repositories/stylist_repository.dart';

final stylistRemoteDataSourceProvider = Provider<StylistRemoteDataSource>((ref) {
  return StylistRemoteDataSourceImpl();
});

final stylistRepositoryProvider = Provider<StylistRepository>((ref) {
  final remoteDataSource = ref.watch(stylistRemoteDataSourceProvider);
  return StylistRepositoryImpl(remoteDataSource: remoteDataSource);
});
