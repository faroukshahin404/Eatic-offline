import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class WindowsPrinterService {
  Future<List<String>> getActivePrinterNames() async {
    if (!Platform.isWindows) return const [];

    final neededBytes = calloc<Uint32>();
    final returnedCount = calloc<Uint32>();
    Pointer<Uint8>? buffer;

    try {
      const flags = PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS;

      EnumPrinters(flags, nullptr, 4, nullptr, 0, neededBytes, returnedCount);

      if (neededBytes.value <= 0) return const [];

      buffer = calloc<Uint8>(neededBytes.value);
      final ok = EnumPrinters(
        flags,
        nullptr,
        4,
        buffer,
        neededBytes.value,
        neededBytes,
        returnedCount,
      );
      if (ok == 0 || returnedCount.value == 0) return const [];

      final printers = <String>{};
      final infos = buffer.cast<PRINTER_INFO_4>();
      for (var i = 0; i < returnedCount.value; i++) {
        final namePtr = (infos + i).ref.pPrinterName;
        if (namePtr == nullptr) continue;
        final name = namePtr.toDartString().trim();
        if (name.isNotEmpty) printers.add(name);
      }

      final list = printers.toList()..sort();
      return list;
    } catch (_) {
      return const [];
    } finally {
      free(neededBytes);
      free(returnedCount);
      if (buffer != null) free(buffer);
    }
  }
}
