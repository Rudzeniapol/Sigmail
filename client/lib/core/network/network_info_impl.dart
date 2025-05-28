import 'package:connectivity_plus/connectivity_plus.dart';
import './network_info.dart';

class NetworkInfoImpl implements INetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl({Connectivity? connectivity}) 
      : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    // Проверяем, что это не ConnectivityResult.none и не ConnectivityResult.bluetooth
    // (если bluetooth не считается активным интернет-соединением)
    // В новой версии connectivity_plus, результат - это список.
    if (result.contains(ConnectivityResult.mobile) || 
        result.contains(ConnectivityResult.wifi) || 
        result.contains(ConnectivityResult.ethernet) ||
        result.contains(ConnectivityResult.vpn)) {
        // iOS может также вернуть other, если это активное соединение
        // Для простоты, пока считаем, что если список не пустой и не только bluetooth - то есть сеть
         if (result.contains(ConnectivityResult.other) && result.length == 1 && result.first == ConnectivityResult.other) {
            // Если только 'other', сложно сказать, есть ли интернет. Для безопасности вернем false, но это требует теста.
            // Или можно всегда возвращать true, если result не пустой и не только bluetooth. 
            // Зависит от того, как ConnectivityResult.other обрабатывается на конкретных платформах.
            // Пока будем считать `other` как валидное, если оно не единственное или если есть еще что-то
            return true; 
         }
         return true; 
    }
    return false;
  }
} 