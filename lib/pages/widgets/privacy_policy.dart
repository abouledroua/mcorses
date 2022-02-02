import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcorses/classes/data.dart';
import 'package:mcorses/pages/authentification/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool accept = false;

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  Future<bool> _onWillPop() async {
    return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: Row(children: const [
                      Icon(Icons.exit_to_app_sharp, color: Colors.red),
                      Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text('Etes-vous sur ?'))
                    ]),
                    content: const Text(
                        "Voulez-vous vraiment quitter l'application ?"),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Non',
                              style: TextStyle(color: Colors.red))),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Oui',
                              style: TextStyle(color: Colors.green)))
                    ]))) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    return SafeArea(
        child: WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
                body: ListView(children: [
              Center(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FittedBox(
                          child: Text("Regle d'utilisation de l'application",
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.laila(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 100))))),
              const Divider(),
              const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      "Veuillez lire et accepter les termes d'utilisation de l'application Medical Corses",
                      style: TextStyle(fontSize: 14))),
              const Divider(),
              privacyText(),
              const Divider(),
              InkWell(
                  onTap: () {
                    setState(() {
                      accept = !accept;
                    });
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Switch(
                            value: accept,
                            onChanged: (value) {
                              setState(() {
                                accept = value;
                              });
                            }),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(children: const [
                              Text("J'accepte les terme d'utilisation",
                                  overflow: TextOverflow.clip)
                            ]))
                      ])),
              InkWell(
                  onTap: accept
                      ? () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString('Privacy', "1");
                          Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                  maintainState: true,
                                  opaque: true,
                                  pageBuilder: (context, _, __) =>
                                      const LoginPage(),
                                  transitionDuration:
                                      const Duration(seconds: 2),
                                  transitionsBuilder:
                                      (context, anim1, anim2, child) {
                                    return FadeTransition(
                                        child: child, opacity: anim1);
                                  }));
                        }
                      : null,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(10),
                            color: accept ? Colors.green : Colors.grey.shade400,
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text("Continuer",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20)),
                                  SizedBox(width: 10),
                                  Icon(Icons.arrow_forward, color: Colors.white)
                                ]))
                      ])),
              const SizedBox(height: 20)
            ]))));
  }

  title(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  details(String text) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  privacyText() {
    return ListView(shrinkWrap: true, primary: false, children: [
      title("Privacy Policy Introduction"),
      details(
          "    Our privacy policy will help you understand what information we collect at Medical Courses, how Medical Courses uses it, and what choices you have. Medical Courses built the Medical Courses app as a free app. This SERVICE is provided by Medical Courses at no cost and is intended for use as is. If you choose to use our Service, then you agree to the collection and use of information in relation with this policy. The Personal Information that we collect are used for providing and improving the Service. We will not use or share your information with anyone except as described in this Privacy Policy. The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible in our website, unless otherwise defined in this Privacy Policy."),
      title("Information Collection and Use"),
      details(
          "    For a better experience while using our Service, we may require you to provide us with certain personally identifiable information, including but not limited to users name, email, address, pictures, function. The information that we request will be retained by us and used as described in this privacy policy. The app does use third party services that may collect information used to identify you."),
      title("Cookies"),
      details(
          "    Cookies are files with small amount of data that is commonly used an anonymous unique identifier. These are sent to your browser from the website that you visit and are stored on your devices’s internal memory. \n This Services does not uses these “cookies” explicitly. However, the app may use third party code and libraries that use “cookies” to collection information and to improve their services. You have the option to either accept or refuse these cookies, and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service."),
      title("Device Information"),
      details(
          "    We collect information from your device in some cases. The information will be utilized for the provision of better service and to prevent fraudulent acts. Additionally, such information will not include that which will identify the individual user."),
      title("Service Providers"),
      details(
          "    We may employ third-party companies and individuals due to the following reasons:\n    To facilitate our Service; To provide the Service on our behalf; To perform Service-related services; or To assist us in analyzing how our Service is used.\n    We want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose."),
      title("Security"),
      details(
          "    We value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security."),
      title("Children’s Privacy"),
      details(
          "    This Services do not address anyone under the age of 13. We do not knowingly collect personal identifiable information from children under 13. In the case we discover that a child under 13 has provided us with personal information, we immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us so that we will be able to do necessary actions."),
      title("Changes to This Privacy Policy"),
      details(
          "    We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately, after they are posted on this page."),
      title("Contact Us"),
      details(
          "    If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us. Contact Information: Email: amor.bouledroua@live.fr")
    ]);
  }
}
