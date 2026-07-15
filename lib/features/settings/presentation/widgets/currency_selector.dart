import 'package:flutter/material.dart';
import '../../data/currency_storage.dart';

class CurrencySelector extends StatefulWidget {
  const CurrencySelector({super.key, required Null Function() onTap});

  @override
  State<CurrencySelector> createState() => _CurrencySelectorState();
}

class _CurrencySelectorState extends State<CurrencySelector> {
  final CurrencyStorage storage = CurrencyStorage();

  final List<String> currencies = [
    "Rs.",
    "\$",
    "€",
    "£",
    "₹",
  ];

  late String currentCurrency;

  @override
  void initState() {
    super.initState();
    final saved = storage.getCurrency();

    if (currencies.contains(saved)) {
      currentCurrency = saved;
    } else {
      currentCurrency = "Rs.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.currency_exchange),
      title: const Text("Currency"),
      subtitle: Text(currentCurrency),
      trailing: DropdownButton<String>(
        value: currentCurrency,
        underline: const SizedBox(),
        items: currencies.map((currency) {
          return DropdownMenuItem(
            value: currency,
            child: Text(currency),
          );
        }).toList(),
        onChanged: (value) async {
          if (value == null) return;

          await storage.saveCurrency(value);

          setState(() {
            currentCurrency = value;
          });
        },
      ),
    );
  }
}
