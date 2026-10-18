import 'dart:async';

/// Deep link OAuth GitHub bisa masuk via GoRouter (flutter deep link)
/// tanpa melewati [AppLinks.uriLinkStream]. Bus ini menjembatani keduanya.
class GithubOauthCallbackBus {
  GithubOauthCallbackBus._();

  static final StreamController<Uri> _controller =
      StreamController<Uri>.broadcast();

  static Stream<Uri> get stream => _controller.stream;

  static void emit(Uri uri) {
    if (!_controller.isClosed) _controller.add(uri);
  }
}
