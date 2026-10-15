import 'package:flutter/material.dart';

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: IcecreamApp()),
);

class IcecreamApp extends StatefulWidget {
  const IcecreamApp({super.key});

  @override
  State<IcecreamApp> createState() => _IcecreamAppState();
}

class _IcecreamAppState extends State<IcecreamApp> {
  static const foods = {'🍿 ポップコーン': 350, '🍗 ナゲット': 400};
  static const colaPrice = 150;
  static const setDiscount = 50;
  static const napkinPrice = 10;

  String? food = foods.keys.first;
  final sauces = <String>{};
  bool cola = false, spoon = false, napkin = false;
  int order = 0;
  String receipt = '';

  Widget supply(String label, bool value, void Function(bool) change) => Row(
    children: [
      Checkbox(
        value: value,
        onChanged: (v) => setState(() => change(v ?? false)),
      ),
      Expanded(child: Text(label)),
    ],
  );

  void selectFood(String? value) => setState(() {
    food = value;
    if (value == null) sauces.clear();
  });

  @override
  Widget build(BuildContext context) {
    final foodPrice = food == null ? 0 : foods[food]!;
    final discount = food != null && cola ? setDiscount : 0;
    final subtotal =
        foodPrice +
        (cola ? colaPrice : 0) +
        (napkin ? napkinPrice : 0) -
        discount;
    final tax = subtotal ~/ 10;
    final total = subtotal + tax;
    final canOrder = food != null || cola;

    final products = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ChoiceChip(
          label: const Text('フードなし（ドリンク単品）'),
          selected: food == null,
          onSelected: (_) => selectFood(null),
        ),
        for (final product in foods.entries)
          ChoiceChip(
            label: Text('${product.key} ${product.value}円'),
            selected: food == product.key,
            onSelected: (_) => selectFood(product.key),
          ),
      ],
    );
    final toppings = Wrap(
      spacing: 6,
      children: [
        for (final sauce in ['マヨネーズ', 'ケチャップ'])
          FilterChip(
            label: Text('$sauce（無料）'),
            selected: sauces.contains(sauce),
            onSelected: food == null
                ? null
                : (selected) => setState(() {
                    if (selected) {
                      sauces.add(sauce);
                    } else {
                      sauces.remove(sauce);
                    }
                  }),
          ),
      ],
    );
    final bill = Column(
      children: [
        if (discount > 0) Text('セットドリンク割引 −$discount 円'),
        Text('税抜 $subtotal 円 / 消費税 $tax 円'),
        Text('合計 $total 円', style: const TextStyle(fontSize: 28)),
      ],
    );
    final submit = Center(
      child: FilledButton(
        onPressed: !canOrder
            ? null
            : () => setState(() {
                order++;
                receipt = [
                  if (food != null) '$food $foodPrice円',
                  if (food != null)
                    'トッピング: ${sauces.isEmpty ? 'なし' : '${sauces.join('・')}（無料）'}',
                  if (cola) '🥤 コーラ $colaPrice円',
                  if (discount > 0) 'セットドリンク割引: −$discount円',
                  '🥄 スプーン: ${spoon ? 'あり（無料）' : 'なし'}',
                  '🧻 紙ナプキン: ${napkin ? 'あり（税抜$napkinPrice円）' : 'なし'}',
                  '税抜: $subtotal 円 / 消費税（10%）: $tax 円',
                  '合計: $total 円',
                ].join('\n');
              }),
        child: const Text('注文する'),
      ),
    );
    final ticket = order == 0
        ? const SizedBox.shrink()
        : Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('注文番号 #$order', style: const TextStyle(fontSize: 26)),
                  Text(receipt),
                ],
              ),
            ),
          );

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('🍿 屋台注文アプリ')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Text(
                  '${food == null ? '' : food!.split(' ').first}${cola ? '🥤' : ''}',
                  style: const TextStyle(fontSize: 90),
                ),
              ),
              const Text('商品を選ぶ（価格は税抜）'),
              products,
              const SizedBox(height: 16),
              const Text('トッピング（無料）'),
              toppings,
              const SizedBox(height: 16),
              const Text('ドリンク'),
              supply('🥤 コーラ（税抜$colaPrice円）', cola, (v) => cola = v),
              const Text('フードとコーラを一緒に注文すると50円引き'),
              const SizedBox(height: 16),
              const Text('備品'),
              supply('🥄 スプーン（無料）', spoon, (v) => spoon = v),
              supply('🧻 紙ナプキン（税抜$napkinPrice円）', napkin, (v) => napkin = v),
              const Divider(),
              bill,
              if (!canOrder) const Center(child: Text('フードかドリンクを選んでください')),
              submit,
              ticket,
            ],
          ),
        ),
      ),
    );
  }
}
