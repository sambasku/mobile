import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/comment_data_providers.dart';
import '../usecases/create_comment_audio_use_case.dart';
import '../usecases/create_comment_use_case.dart';
import '../usecases/delete_comment_use_case.dart';
import '../usecases/list_word_comments_use_case.dart';

part 'comment_domain_providers.g.dart';

@riverpod
ListWordCommentsUseCase listWordCommentsUseCase(Ref ref) =>
    ListWordCommentsUseCase(ref.watch(commentRepositoryProvider));

@riverpod
CreateCommentUseCase createCommentUseCase(Ref ref) =>
    CreateCommentUseCase(ref.watch(commentRepositoryProvider));

@riverpod
CreateCommentAudioUseCase createCommentAudioUseCase(Ref ref) =>
    CreateCommentAudioUseCase(ref.watch(commentRepositoryProvider));

@riverpod
DeleteCommentUseCase deleteCommentUseCase(Ref ref) =>
    DeleteCommentUseCase(ref.watch(commentRepositoryProvider));
