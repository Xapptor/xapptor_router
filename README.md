# **Xapptor Router**
### Router Module for Web and Mobile Navigation.

## **Let's get started**

### **1 - Depend on it**
##### Add it to your package's pubspec.yaml file
```yml
dependencies:
    xapptor_router: 
        git: 
        url: git://github.com/Xapptor/xapptor_router.git 
        ref: main
```

### **2 - Install it**
##### Install packages from the command line
```sh
flutter packages get
```

### **3 - Learn it like a charm**

### **Call your start_screens_config function in your main.dart**
```dart
Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    Paint.enableDithering = true;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    start_screens_config();
}
```

### **Create start_screens_config function**
### * Set current_build_mode
### * Set landing_screen
### * Set unknown_screen
### * Add new app screens with add_new_app_screen function
### * Final step is call runApp function using the default Xapptor App class, setting your app_name and theme
```dart
start_screens_config() {
    current_build_mode = BuildMode.release;
    landing_screen = Landing();
    unknown_screen = UnknownScreen(
        logo_path: logo_image_path,
    );

    add_new_app_screen(
        AppScreen(
            name: "login",
            child: UserInfoView(
                text_list: [
                    "Email",
                    "Password",
                    "Remember me",
                    "Log In",
                    "Recover password",
                    "Register",
                ],
                tc_and_pp_text: RichText(text: TextSpan()),
                gender_values: [],
                country_values: [],
                text_color: Colors.blue,
                first_button_color: Colors.white,
                second_button_color: Colors.white,
                third_button_color: Colors.white,
                logo_image_path: "your_image_path",
                has_language_picker: false,
                topbar_color: Colors.blue,
                custom_background: null,
                user_info_form_type: UserInfoFormType.login,
                outline_border: true,
                first_button_action: null,
                second_button_action: open_forgot_password,
                third_button_action: open_register,
                has_back_button: true,
                text_field_background_color: null,
            ),
        ),
    );

    add_new_app_screen(
        AppScreen(
            name: "privacy_policy",
            child: PrivacyPolicy(
                base_url: "https://www.domain.com",
                use_topbar: false,
                topbar_color: Colors.blue,
            ),
        ),
    );

    add_new_app_screen(
        AppScreen(
            name: "home",
            child: Home(),
        ),
    );

    runApp(
        App(
            app_name: "MyAppName",
            theme: ThemeData(
                primarySwatch: material_color_abeinstitute(),
                fontFamily: 'VarelaRound',
                textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                        ),
                    ),
                ),
            ),
        ),
    );
}
```

### **You can open a screen calling the function open_screen and passing the name of the screen:**
```dart
open_screen("home/courses");
```

                
