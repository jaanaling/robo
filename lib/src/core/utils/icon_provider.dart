enum IconProvider {
  splash(imageName: 'splash.webp'),
  logo(imageName: 'logo.webp'),
  background(imageName: 'background.webp'),
  baner(imageName: 'baner.webp'),
  button(imageName: 'button.webp'),
  close(imageName: 'close.webp'),
  hint(imageName: 'hint.svg'),
  back(imageName: 'back.svg'),
  achiv(imageName: 'achiv.svg'),
  achivBut(imageName: 'achiv_but.svg'),
  loseBack(imageName: 'lose_back.webp'),
  menuButton(imageName: 'menu_button.webp'),
  winBack(imageName: 'win_back.webp'),
  timer(imageName: 'timer.webp'),
  tip(imageName: 'tip.svg'),
  image1(imageName: '1.webp'),
  image2(imageName: '2.webp'),
  image3(imageName: '3.webp'),
  image4(imageName: '4.webp'),
  image5(imageName: '5.webp'),
  image6(imageName: '6.webp'),

  unknown(imageName: '');

  const IconProvider({
    required this.imageName,
  });

  final String imageName;
  static const _imageFolderPath = 'assets/images';

  String buildImageUrl() => '$_imageFolderPath/$imageName';
  static String buildImageByName(String name) => '$_imageFolderPath/$name';
}
