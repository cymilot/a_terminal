import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class LData<T> extends ValueNotifier<T> {
  LData(this._value, this._onChange) : super(_value);

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

class LList<E> extends DelegatingList<E> implements ValueNotifier<List<E>> {
  LList([List<E>? v]) : super(v ?? <E>[]);

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
  void add(E value) {
    super.add(value);
    notifyListeners();
  }

  @override
  void addAll(Iterable<E> iterable) {
    super.addAll(iterable);
    notifyListeners();
  }

  @override
  void insert(int index, E element) {
    super.insert(index, element);
    notifyListeners();
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    super.insertAll(index, iterable);
    notifyListeners();
  }

  @override
  bool remove(Object? value) {
    final result = super.remove(value);
    notifyListeners();
    return result;
  }

  @override
  E removeAt(int index) {
    final result = super.removeAt(index);
    notifyListeners();
    return result;
  }

  @override
  void clear() {
    super.clear();
    notifyListeners();
  }
}
