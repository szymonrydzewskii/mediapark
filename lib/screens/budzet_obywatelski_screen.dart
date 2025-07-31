import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediapark/models/samorzad_details.dart';
import '../services/budzet_obywatelski_service.dart';
import '../models/budzet_obywatelski.dart';
import 'budzet_obywatelski_details_screen.dart';
import 'package:mediapark/screens/bo_harmonogram_screen.dart';

class BudzetObywatelskiScreen extends StatelessWidget {
  final SamorzadModule modul;
  final SamorzadSzczegoly samorzad;

  const BudzetObywatelskiScreen({
    super.key,
    required this.modul,
    required this.samorzad,
  });

  @override
  Widget build(BuildContext context) {
    final String idInstytucji = modul.idInstytucji;

    return Scaffold(
      backgroundColor: const Color(0xFFBCE1EB),
      appBar: AppBar(
        elevation: 0,
        forceMaterialTransparency: true,
        backgroundColor: const Color(0xFFBCE1EB),
        centerTitle: true,
        title: Text(
          "Budżet Obywatelski",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => BOHarmonogramScreen(
                        idInstytucji: samorzad.idBoInstitution,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<BudzetObywatelski>>(
        future: fetchProjekty(idInstytucji),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Brak projektów'));
          }

          final projekty = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(10.w),
            itemCount: projekty.length,
            itemBuilder: (context, index) {
              final projekt = projekty[index];
              return _buildProjektCard(context, projekt);
            },
          );
        },
      ),
    );
  }

  Widget _buildProjektCard(BuildContext context, BudzetObywatelski projekt) {
    String shorterDescription(String desc) =>
        desc.length > 300 ? '${desc.substring(0, 200)}...' : desc;

    final shortDesc = projekt.shortDescription.replaceAll('\r\n', '\n');

    return Card(
      color: const Color(0xFFCAECF4),
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BudzetObywatelskiDetailsScreen(
                    projectId: projekt.idProject,
                  ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 4.h,
                        horizontal: 8.w,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[800],
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                      child: Text(
                        projekt.statusName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      projekt.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (projekt.typeVisible)
                      Row(
                        children: [
                          Text("Rodzaj: ", style: _boldLabelStyle()),
                          Text(projekt.typeValue, style: _valueStyle()),
                        ],
                      ),
                    if (projekt.quartersVisible &&
                        projekt.quartersValue.isNotEmpty)
                      Row(
                        children: [
                          Text("Osiedle: ", style: _boldLabelStyle()),
                          Text(projekt.quartersValue, style: _valueStyle()),
                        ],
                      ),
                    if (projekt.costVisible)
                      Row(
                        children: [
                          Text("Koszt: ", style: _boldLabelStyle()),
                          Text(
                            projekt.costValue.replaceAll('&nbsp;', ' '),
                            style: _valueStyle(),
                          ),
                        ],
                      ),
                    SizedBox(height: 8.h),
                    if (shortDesc.isNotEmpty)
                      Text(
                        shorterDescription(shortDesc),
                        textAlign: TextAlign.justify,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _boldLabelStyle() =>
      TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp);
  TextStyle _valueStyle() => TextStyle(fontSize: 14.sp);
}
