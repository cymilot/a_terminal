import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class ListenableData<T> extends ValueNotifier<T> {
  ListenableData(this._value, this._onChange) : super(_value);

  final void Function(T)? _onChange;

  T _value;
  @override
  T get value => _value;
  @override
  set value(T newValue) {
    if (_value == newValue) {
      return;
    }
    _value = newValue;
    _onChange?.call(newValue);
    notifyListeners();
  }

  @override
  String toString() => _value.toString();
}

class ListenableList<E> extends DelegatingList<E>
    implements ValueNotifier<List<E>> {
  ListenableList([List<E>? v]) : super(v ?? <E>[]);

  @override
  List<E> get value => this;
  @override
  set value(List<E> newValue) {
    if (this == newValue) {
      return;
    }
    super.clear();
    super.addAll(newValue);
    notifyListeners();
  }

  final List<VoidCallback> _listeners = [];

  @override
  bool get hasListeners => _listeners.isNotEmpty;

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  @override
  void notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  @override
  void dispose() {
    _listeners.clear();
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
}
