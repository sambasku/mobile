import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/comment_repository.dart';
import '../comment_image_upload_service.dart';
import '../datasources/comment_remote_datasource.dart';
import '../repositories/comment_repository_impl.dart';

part 'comment_data_providers.g.dart';

@riverpod
CommentRemoteDatasource commentRemoteDatasource(Ref ref) =>
    CommentRemoteDatasource(ref.watch(dioProvider));

@riverpod
CommentRepository commentRepository(Ref ref) => CommentRepositoryImpl(
      ref.watch(commentRemoteDatasourceProvider),
      ref.watch(dioProvider),
    );

@riverpod
CommentImageUploadService commentImageUploadService(Ref ref) =>
    CommentImageUploadService(ref.watch(commentRepositoryProvider));