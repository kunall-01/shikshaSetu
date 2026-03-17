// ignore_for_file: constant_identifier_names

class AppUrl {
  static const String liveBaseURL = "https://bestwayfuture.in/";
  static const String localBaseURL = 'http://192.168.29.90:1000';
//http://192.168.29.90:1000/addadmin
  static const String baseURL = '$localBaseURL/admin';
  static const String parentbaseURL = '$localBaseURL/parent';
  static const String tutorebaseURL = '$localBaseURL/tutor';
  static const String baseIMGURL = localBaseURL;

// Admin
  static const String login = '$baseURL/login';
  static const String addadmin = '$baseURL/addadmin';
  static const String addsubject = '$baseURL/addsubject';
  static const String getsubjects = '$baseURL/getsubject';
  static const String addtutor = '$baseURL/addtutor';
  static const String edittutor = '$baseURL/edittutor';
  static const String editparent = '$baseURL/editparent';
  static const String tutorBU = '$baseURL/tutorBU';
  static const String parentBU = '$baseURL/parentBU';
  static const String editstudent = '$baseURL/editstudent';
  static const String getStdSubAssign = '$baseURL/getStdSubAssign';
  static const String assignstudentinsert = '$baseURL/assignstudentinsert';
  static const String gettutor = '$baseURL/gettutor';
  static const String addparent = '$baseURL/addparent';
  static const String getparentandtutorlist = '$baseURL/getparentandtutorlist';
  static const String addstudent = '$baseURL/addstudent';
  static const String changepassword = '$baseURL/changepassword';
  static const String getparentchild = '$baseURL/getparentchild';
  static const String fetchsubject = '$baseURL/fetchsubject';
  static const String assignstudentdelete = '$baseURL/assignstudentdelete';
  static const String editsubject = '$baseURL/editsubject';
  static const String getalladmin = '$baseURL/getalladmin';
  static const String editAdmin = '$baseURL/editadmin';
  static const String deleteadmin = '$baseURL/deleteadmin';
  static const String blockunblockadmin = '$baseURL/blockunblockadmin';
  static const String getmyadminprofile = '$baseURL/getmyadminprofile';
  static const String myadminprofileedit = '$baseURL/myadminprofileedit';

  //Common
  static const String chatting = '$baseURL/getparentandtutorandadminchatlist';
  static const String getChats = '$baseURL/getChats';
  static const String sendchatmsg = '$baseURL/sendchatmsg';

//--------------------------- Image ---
  static const String tutorprofilephoto = '$baseIMGURL/data/profile/tutor/';
  static const String stdprofilephoto = '$baseIMGURL/data/profile/student/';

  // Parent Portal
  static const String pr_getallchild = '$parentbaseURL/pr_getallchild';
  static const String pr_getchilddetail = '$parentbaseURL/pr_getchilddetail';
  static const String getmyparentprofile = '$parentbaseURL/getmyparentprofile';
  static const String gethomeworkofstudentinparent =
      '$parentbaseURL/gethomeworkofstudentinparent';
  static const String getmarksbytutorandstudentinparent =
      '$parentbaseURL/getmarksbytutorandstudentinparent';

  static const String parentchangepassword =
      '$parentbaseURL/parentchangepassword';
  static const String parentchattinglist =
      '$parentbaseURL/getpparentandadminchatlist';

  // Tutor
  static const String trgetallstudents = '$tutorebaseURL/tr_getallstudents';
  static const String trgetdashdata = '$tutorebaseURL/tr_getdashdata';
  static const String getmytutorprofile = '$tutorebaseURL/getmytutorprofile';
  static const String trGetSuboftutor = '$tutorebaseURL/trgetSuboftutor';
  static const String trAddmarks = '$tutorebaseURL/addstudentmarks';
  static const String editstudentmarks = '$tutorebaseURL/editstudentmarks';
  static const String editstudenthomework =
      '$tutorebaseURL/editstudenthomework';
  static const String getmarksbytutorandstudent =
      '$tutorebaseURL/getmarksbytutorandstudent';
  static const String addhomework = '$tutorebaseURL/addhomework';
  static const String gethomeworkofstudent =
      '$tutorebaseURL/gethomeworkofstudent';

  static const String tutorchangepassword =
      '$tutorebaseURL/tutorchangepassword';

  static const String rateStudent = '$tutorebaseURL/ratestudent';

  static const String tutorchattinglist =
      '$tutorebaseURL/gettparentandadminchatlist';
}
