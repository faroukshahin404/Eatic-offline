import 'dart:convert';
import 'dart:io';

class WindowsThermalPrinterService {
  Future<bool> printText({
    required String printerName,
    required String text,
    int copies = 1,
    double fontSize = 12,
    int paperWidthMm = 80,
    bool rightToLeft = true,
    String? headerImagePath,
    String? footerImagePath,
    int headerImageMaxHeightPx = 160,
    int footerImageMaxHeightPx = 120,
  }) async {
    if (!Platform.isWindows) return false;
    if (printerName.trim().isEmpty || text.trim().isEmpty) return false;
    final safeCopies = copies < 1 ? 1 : copies;
    final encodedText = base64Encode(utf8.encode(text));
    final escapedPrinter = printerName.replaceAll("'", "''");
    final safeFontSize = fontSize < 8 ? 8 : fontSize;
    final safeWidthMm = paperWidthMm < 58 ? 58 : paperWidthMm;
    final rtlValue = rightToLeft ? 'true' : 'false';
    final safeHeaderHeight =
        headerImageMaxHeightPx < 40 ? 40 : headerImageMaxHeightPx;
    final safeFooterHeight =
        footerImageMaxHeightPx < 30 ? 30 : footerImageMaxHeightPx;
    final escapedHeaderImage = (headerImagePath ?? '').replaceAll("'", "''");
    final escapedFooterImage = (footerImagePath ?? '').replaceAll("'", "''");
    final script = '''
Add-Type -AssemblyName System.Drawing
\$content = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$encodedText'))
\$lines = \$content -split "`n"
\$font = New-Object System.Drawing.Font('Arial', $safeFontSize)
\$doc = New-Object System.Drawing.Printing.PrintDocument
\$doc.PrinterSettings.PrinterName = '$escapedPrinter'
\$widthPx = [int](($safeWidthMm / 25.4) * 100)
\$doc.DefaultPageSettings.PaperSize = New-Object System.Drawing.Printing.PaperSize('Thermal', \$widthPx, 6000)
\$doc.DefaultPageSettings.Margins = New-Object System.Drawing.Printing.Margins(5, 5, 5, 5)
\$lineIndex = 0
\$headerImagePath = '$escapedHeaderImage'
\$footerImagePath = '$escapedFooterImage'
\$headerImageMaxHeight = $safeHeaderHeight
\$footerImageMaxHeight = $safeFooterHeight
\$stringFormat = New-Object System.Drawing.StringFormat
if ($rtlValue) {
  \$stringFormat.FormatFlags = [System.Drawing.StringFormatFlags]::DirectionRightToLeft
  \$stringFormat.Alignment = [System.Drawing.StringAlignment]::Far
  \$stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Near
} else {
  \$stringFormat.Alignment = [System.Drawing.StringAlignment]::Near
  \$stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Near
}
\$handler = [System.Drawing.Printing.PrintPageEventHandler]{
  param(\$sender, \$e)
  \$lineHeight = [int]\$font.GetHeight(\$e.Graphics) + 2
  \$y = \$e.MarginBounds.Top
  if (\$lineIndex -eq 0 -and \$headerImagePath -ne '' -and (Test-Path \$headerImagePath)) {
    try {
      \$img = [System.Drawing.Image]::FromFile(\$headerImagePath)
      \$maxWidth = \$e.MarginBounds.Width
      \$imgHeightByWidth = [int](\$img.Height * (\$maxWidth / \$img.Width))
      \$imgHeight = [Math]::Min(\$imgHeightByWidth, \$headerImageMaxHeight)
      \$imgWidth = [int](\$img.Width * (\$imgHeight / \$img.Height))
      if (\$imgWidth -gt \$maxWidth) {
        \$imgWidth = [int]\$maxWidth
      }
      \$x = \$e.MarginBounds.Left + [int]((\$maxWidth - \$imgWidth) / 2)
      \$e.Graphics.DrawImage(\$img, \$x, \$y, \$imgWidth, \$imgHeight)
      \$y += \$imgHeight + 6
      \$img.Dispose()
    } catch {}
  }
  while (\$lineIndex -lt \$lines.Length) {
    \$line = \$lines[\$lineIndex].TrimEnd("`r")
    \$rect = New-Object System.Drawing.RectangleF([float]\$e.MarginBounds.Left, [float]\$y, [float]\$e.MarginBounds.Width, [float]\$lineHeight)
    \$e.Graphics.DrawString(\$line, \$font, [System.Drawing.Brushes]::Black, \$rect, \$stringFormat)
    \$lineIndex++
    \$y += \$lineHeight
    if (\$y + \$lineHeight -gt \$e.MarginBounds.Bottom) {
      \$e.HasMorePages = \$true
      return
    }
  }
  if (\$footerImagePath -ne '' -and (Test-Path \$footerImagePath)) {
    try {
      \$img2 = [System.Drawing.Image]::FromFile(\$footerImagePath)
      \$maxWidth2 = \$e.MarginBounds.Width
      \$imgHeightByWidth2 = [int](\$img2.Height * (\$maxWidth2 / \$img2.Width))
      \$imgHeight2 = [Math]::Min(\$imgHeightByWidth2, \$footerImageMaxHeight)
      \$imgWidth2 = [int](\$img2.Width * (\$imgHeight2 / \$img2.Height))
      if (\$imgWidth2 -gt \$maxWidth2) {
        \$imgWidth2 = [int]\$maxWidth2
      }
      \$yAfter = \$y + 6
      if (\$yAfter + \$imgHeight2 -lt \$e.MarginBounds.Bottom) {
        \$x2 = \$e.MarginBounds.Left + [int]((\$maxWidth2 - \$imgWidth2) / 2)
        \$e.Graphics.DrawImage(\$img2, \$x2, \$yAfter, \$imgWidth2, \$imgHeight2)
      }
      \$img2.Dispose()
    } catch {}
  }
  \$e.HasMorePages = \$false
}
\$doc.add_PrintPage(\$handler)
for (\$i = 0; \$i -lt $safeCopies; \$i++) {
  \$lineIndex = 0
  \$doc.Print()
}
''';

    try {
      final result = await Process.run('powershell', [
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        script,
      ]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
