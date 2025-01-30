import 'package:get/get.dart';

class DashboardController extends GetxController{
  var selectedMenu=0.obs;
  updateSelectedMenu(pos)=> selectedMenu.value=pos;
}