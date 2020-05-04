part of 'styling.dart';

final TextStyle categoryTextStyle = 
  GoogleFonts.signika(
    fontWeight: FontWeight.bold,
    fontSize: 30,
    color: obscure
);

final TextStyle messageLocationText = 
  GoogleFonts.signika(
    color: obscure,
    fontSize: 20,
);
final TextStyle categoryText = 
  GoogleFonts.signika(
    color: obscure,
    fontSize: 31,
    fontWeight: FontWeight.w600
);

final TextStyle choiceCategoryText = 
  GoogleFonts.signika(
    color: obscure,
    fontSize: 19,
    fontWeight: FontWeight.w600
);

TextStyle alertButtonText = GoogleFonts.montserrat(
  color: light,
  fontSize: 28,
  fontWeight: FontWeight.bold,
  letterSpacing: 2,
  shadows: [Shadow(color: Colors.black.withOpacity(0.16),offset: Offset(0,3),blurRadius: 6)]
);

TextStyle alertMessagetStyle = GoogleFonts.signika(
  fontSize: 32,
  fontWeight: FontWeight.w100,
  color: obscure
);

TextStyle alertTimertStyle = GoogleFonts.signika(
  fontSize: 32,
  color: primary
);

TextStyle buttonStyeText = GoogleFonts.signika(
  fontSize: 32,
  color: my_red
);

TextStyle markAsReadedText = GoogleFonts.signika(
  fontSize: 23,
  color: obscure,
  decoration : TextDecoration.underline
);


