import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediapark/services/image_cache_service.dart';
import 'package:mediapark/services/hive_data_cache.dart';



void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await ImageCacheService.init();
  await Hive.initFlutter();
  await HiveDataCache.init();
  await dotenv.load(fileName: ".env");
  runApp(
    ScreenUtilInit(
      designSize: Size(412, 924),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const MyApp(),
    ),
  );
}