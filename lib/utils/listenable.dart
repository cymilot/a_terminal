import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class ListenableList<E> extends DelegatingList<E>
    implements ValueListenable<List<E>> {
  ListenableList([List<E>? v]) : super(v ?? <E>[]);

  @override
  List<E> get value => this;
  set value(List<E> newValue) {
    if (this == newValue) {
      return;
    }
    super.clear();
    super.addAll(newValue);
    notifyListeners();
  }

  @override
  void add(E value, {bool notify = true}) {
    super.add(value);
    if (notify) notifyListeners();
  }

  @override
  void addAll(Iterable<E> iterable, {bool notify = true}) {
    super.addAll(iterable);
    if (notify) notifyListeners();
  }

  @override
  void insert(int index, E element, {bool notify = true}) {
    super.insert(index, element);
    if (notify) notifyListeners();
  }

  @override
  void insertAll(int index, Iterable<E> iterable, {bool notify = true}) {
    super.insertAll(index, iterable);
    if (notify) notifyListeners();
  }

  @override
  bool remove(Object? value, {bool notify = true}) {
    final result = super.remove(value);
    if (notify) notifyListeners();
    return result;
  }

  @override
  E removeAt(int index, {bool notify = true}) {
    final result = super.removeAt(index);
    if (notify) notifyListeners();
    return result;
  }

  @override
  void clear({bool notify = true}) {
    super.clear();
    if (notify) notifyListeners();
  }

  final _listeners = <VoidCallback>[];

  bool get hasListeners => _listeners.isNotEmpty;

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (final listener in _listeners) {
      listener.call();
    }
  }

  void dispose() {
    super.clear();
    _listeners.clear();
  }
}
