/// How long to wait before reconnect attempt [attempt] (0 is the first):
/// 1, 2, 4, 8, 16, then 30 seconds.
int reconnectDelayMs(int attempt) {
  final step = attempt < 6 ? attempt : 6;
  final delayMs = 1000 * (1 << step);
  return delayMs > 30000 ? 30000 : delayMs;
}
