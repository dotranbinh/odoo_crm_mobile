abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const leads = '/leads';
  static const leadPipeline = '/leads/pipeline';
  static const leadDetail = '/leads/:id';
  static String leadDetailFor(int id) => '/leads/$id';
  static String leadEditFor(int id) => '/leads/$id/edit';
  static const createLead = '/create-lead';
  static const orders = '/orders';
  static const profile = '/profile';
  static const settings = '/settings';
}
