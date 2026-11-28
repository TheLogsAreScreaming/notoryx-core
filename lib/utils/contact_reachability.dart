import '../models/message.dart';

enum ReachabilityVerdict { twoWay, theyHeardYou, noAnswerYet }

/// Infers whether two-way communication with a contact is established,
/// based solely on the local message history and direct-RF neighbour data.
/// Returns null when there is no evidence of any interaction at all.
ReachabilityVerdict? contactReachability(
  List<Message> messages, {
  bool heardDirectly = false,
}) {
  final hasDelivered = messages.any(
    (m) => m.isOutgoing && m.status == MessageStatus.delivered,
  );
  final hasIncoming = messages.any((m) => !m.isOutgoing);

  if (hasDelivered || hasIncoming) return ReachabilityVerdict.twoWay;
  if (heardDirectly) return ReachabilityVerdict.theyHeardYou;
  if (messages.any((m) => m.isOutgoing)) return ReachabilityVerdict.noAnswerYet;

  return null;
}
