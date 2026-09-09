/// MODEL
/// A single billing option on the "Go Pro" paywall screen.
class SubscriptionPlanModel {
  final String id; // 'yearly' | 'monthly'
  final String label;
  final String priceLabel;
  final String? badge;

  const SubscriptionPlanModel({
    required this.id,
    required this.label,
    required this.priceLabel,
    this.badge,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ??
            json['plan_id'] ??
            json['planId'] ??
            json['code'] ??
            'plan')
        .toString();

    final label = (json['label'] ??
            json['name'] ??
            json['title'] ??
            json['plan_name'] ??
            json['planName'] ??
            id)
        .toString();

    String priceLabel = '';
    if (json['price_label'] != null && json['price_label'].toString().isNotEmpty) {
      priceLabel = json['price_label'].toString();
    } else if (json['priceLabel'] != null && json['priceLabel'].toString().isNotEmpty) {
      priceLabel = json['priceLabel'].toString();
    } else if (json['price'] != null) {
      final p = json['price'];
      final cycle = json['interval'] ??
          json['period'] ??
          json['billing_cycle'] ??
          json['billingCycle'] ??
          json['duration'];
      final cycleText = cycle != null ? ' / $cycle' : '';
      if (p is num || double.tryParse(p.toString()) != null) {
        priceLabel = '\$$p$cycleText';
      } else {
        priceLabel = '$p$cycleText';
      }
    } else if (json['amount'] != null) {
      final a = json['amount'];
      final cycle = json['interval'] ?? json['period'] ?? json['billing_cycle'];
      final cycleText = cycle != null ? ' / $cycle' : '';
      priceLabel = '\$$a$cycleText';
    } else {
      priceLabel = '\$0.00';
    }

    final badge = json['badge'] ??
        json['tag'] ??
        json['discount'] ??
        json['save_text'] ??
        json['saveText'] ??
        json['offer'];

    return SubscriptionPlanModel(
      id: id,
      label: label,
      priceLabel: priceLabel,
      badge: badge?.toString(),
    );
  }
}
