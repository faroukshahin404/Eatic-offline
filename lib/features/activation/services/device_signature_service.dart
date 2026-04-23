import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

class DeviceSignatureService {
  Future<String> buildSignatureHash() async {
    final cpuId = await _readCpuId();
    final motherboardId = await _readMotherboardId();
    final macAddress = await _readMacAddress();

    final rawSignature = [
      _normalizeFingerprintSegment(cpuId),
      _normalizeFingerprintSegment(motherboardId),
      _normalizeFingerprintSegment(macAddress),
    ].join('|');

    return sha256.convert(utf8.encode(rawSignature)).toString();
  }

  Future<String> _readCpuId() {
    return _readPowerShellValue(
      '(Get-CimInstance Win32_Processor | Select-Object -First 1 -ExpandProperty ProcessorId)',
    );
  }

  Future<String> _readMotherboardId() {
    return _readPowerShellValue(
      '(Get-CimInstance Win32_BaseBoard | Select-Object -First 1 -ExpandProperty SerialNumber)',
    );
  }

  Future<String> _readMacAddress() async {
    final value = await _readPowerShellValue(
      r"(Get-NetAdapter -Physical | Where-Object {$_.Status -eq 'Up'} | Select-Object -First 1 -ExpandProperty MacAddress)",
    );
    if (value.isNotEmpty) {
      return value;
    }

    final fallbackResult = await Process.run(
      'getmac',
      const [],
      runInShell: true,
    );
    if (fallbackResult.exitCode != 0) return '';
    final output = (fallbackResult.stdout as String?) ?? '';
    final regex = RegExp(r'([0-9A-Fa-f]{2}[-:]){5}[0-9A-Fa-f]{2}');
    final match = regex.firstMatch(output);
    return match?.group(0) ?? '';
  }

  Future<String> _readPowerShellValue(String command) async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        command,
      ], runInShell: true);
      if (result.exitCode != 0) return '';
      return ((result.stdout as String?) ?? '').trim();
    } catch (_) {
      return '';
    }
  }

  String _normalizeFingerprintSegment(String value) {
    final normalized = value.trim().toUpperCase().replaceAll(
      RegExp(r'\s+'),
      '',
    );
    if (normalized.isEmpty) return 'UNKNOWN';
    return normalized;
  }
}
