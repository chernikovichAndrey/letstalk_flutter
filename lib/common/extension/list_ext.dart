extension IterableExt<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  T firstWhereOrElse(
      bool Function(T element) test, {
        required T Function() orElse,
      }) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return orElse();
  }
}