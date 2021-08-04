
class AppConfig {
  static final String appName               = 'Punch Admin';

  static final String googleStoreVersion    = '1.0';
  static final String appleStoreVersion     = '1.0';
  static final String appVersion            = '1.0';
  static final String localVersion          = '1.0';
  static final int    adminUserRole         = 10;
  static final int    employerUserRole      = 20;
  static final int    internUserRole        = 30;
  static final String apiURL                = 'https://us-central1-punch-application.cloudfunctions.net/';
  static final String apiKey                = '9052903cd744b4dfabc030c08a0c3647';

  static final String mapUrlTemplate  = 'https://api.mapbox.com/styles/v1/punch/cknud2vci0sg817o5ko9slahp/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoicHVuY2giLCJhIjoiY2tudWN1MTIxMGJydTJ2cHM4ZnE1dG16biJ9.KF9uF4kVsWOXkLFgipRFHQ';
  static final String mapAccessToken  = 'sk.eyJ1IjoicHVuY2giLCJhIjoiY2tudWN3YnZjMGJxaTJvb2MydXl5Zjl2NiJ9.f-GODyTGz-J0rTupYolJhA';
  static final String mapID           = 'mapbox.mapbox-streets-v8';

  static final bool isPublished             = true;

  static String appUpdateVersion;
}