import 'package:flutter/material.dart';
import 'package:mediapark/samorzad_service.dart';
import 'package:mediapark/selecting_samorzad.dart';

class MainWindow extends StatefulWidget {
  final Set<Samorzad> wybraneSamorzady;

  const MainWindow({super.key, required this.wybraneSamorzady});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  Samorzad? aktywnySamorzad;
  bool showPanel = false;

  @override
  void initState() {
    super.initState();
    aktywnySamorzad = widget.wybraneSamorzady.first;
  }

  void onSettingsClick() {}

  void onHerbClick(Samorzad samorzad) {
    setState(() {
      aktywnySamorzad = samorzad;
      showPanel = false;
    });
  }

  void otworzWybieranie(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectingSamorzad()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const appBarColor = Color.fromARGB(255, 45, 45, 45);
    final lista = widget.wybraneSamorzady.toList();
    final panelHeight = (lista.length * 70.0).clamp(0, 370);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      body: Stack(
        children: [
          //główny ekran
          Column(
            children: [
              AppBar(
                backgroundColor: appBarColor,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showPanel = !showPanel;
                        });
                      },
                      child:
                          aktywnySamorzad != null
                              ? Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Image.network(
                                    aktywnySamorzad!.herb,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              )
                              : Icon(
                                Icons.account_balance,
                                color: Colors.white,
                              ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        aktywnySamorzad?.nazwa ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Center(
                    child: Ink(
                      height: 40,
                      decoration: const ShapeDecoration(
                        color: Colors.white,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        onPressed: onSettingsClick,
                        icon: const Icon(Icons.settings, color: appBarColor),
                      ),
                    ),
                  ),
                ],
              ),
              // konsultacje box
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  child: aktywnySamorzad?.konsultacje == true ? 
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'KONSULTACJE',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ): const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          // panel przełączania samorządów
          if (showPanel)
            Positioned(
              top: kToolbarHeight,
              left: 15,
              right: 15,
              child: Material(
                elevation: 6,
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: panelHeight.toDouble(),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: lista.length,
                          itemBuilder: (context, index) {
                            final samorzad = lista[index];
                            return ListTile(
                              leading: Image.network(
                                samorzad.herb,
                                width: 30,
                                height: 30,
                              ),
                              title: Text(samorzad.nazwa),
                              onTap: () => onHerbClick(samorzad),
                            );
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => showPanel = false);
                            otworzWybieranie(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                            "Pokaż wszystkie",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
