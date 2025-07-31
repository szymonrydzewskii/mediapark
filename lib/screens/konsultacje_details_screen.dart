import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/konsultacje.dart';
import '../helpers/prettify.dart';

class KonsultacjeDetailsPage extends StatelessWidget {
  final Konsultacje konsultacja;

  const KonsultacjeDetailsPage({super.key, required this.konsultacja});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBCE1EB),
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: const Color(0xFFBCE1EB),
        elevation: 0,
        foregroundColor: Colors.black,
        leading: Transform.translate(
          offset: Offset(8.w, 0),
          child: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/back_button.svg',
              width: 40.w,
              height: 40.w,
            ),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 345.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: -8,
                      children: [
                        _buildTag(prettify(konsultacja.categoryAlias)),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      konsultacja.title,
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    if ((konsultacja.photoUrl ?? '').isNotEmpty)
                      FutureBuilder(
                        future: _checkImageExists(konsultacja.photoUrl!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.data == true) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(40.r),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.network(
                                  konsultacja.photoUrl!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),

                    SizedBox(height: 20.h),
                    Text(
                      'Status: ${konsultacja.status}',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Od: ${konsultacja.startDate}  Do: ${konsultacja.endDate}',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _parseHtmlToPlainText(konsultacja.shortDescription),
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 12.h,),
                    Text(
                      _parseHtmlToPlainText(konsultacja.description).replaceAll(
                        RegExp(r'<[^>]*>'),
                        '',
                      ),
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                    ),
                    SizedBox(height: 24.h),
                    if ((konsultacja.pollUrl ?? '').isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 18.h),
                          ),
                          child: Text(
                            'Weź udział',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: EdgeInsets.only(right: 12.w, left: 12.w, top: 8.h, bottom: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1C3),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Future<bool> _checkImageExists(String url) async {
  try {
    final client = HttpClient();
    final request = await client.headUrl(Uri.parse(url));
    final response = await request.close();
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}

String _parseHtmlToPlainText(String htmlText) {
  return htmlText
      .replaceAll(RegExp(r'</p>\s*<p>'), '\n\n') // podwójna nowa linia między paragrafami
      .replaceAll(RegExp(r'<[^>]+>'), '')        // usuń wszystkie pozostałe tagi HTML
      .replaceAll(RegExp(r'&nbsp;'), ' ')        // zamień encje HTML na spacje
      .replaceAll(RegExp(r'&amp;'), '&')         // inne encje (opcjonalnie)
      .trim();                                   // usuń białe znaki na końcach
}

