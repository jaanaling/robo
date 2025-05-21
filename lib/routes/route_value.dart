enum RouteValue {
  splash(
    path: '/',
  ),
  home(
    path: '/home',
  ),
  article(
    path: 'article',
  ),
  articles(
    path: 'articles',
  ),
  select(
    path: 'select',
  ),
  initial(
    path: 'initial',
  ),
  game(
    path: 'game',
  ),
  privacy(
    path: 'privacy',
  ),

  achievements(
    path: 'achievements',
  ),

  unknown(
    path: '',
  );

  final String path;
  const RouteValue({
    required this.path,
  });
}
