// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Odoo CRM Mobile';

  @override
  String get appTagline => 'Sales on the go';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to manage your pipeline';

  @override
  String get odooUrl => 'Odoo URL';

  @override
  String get database => 'Database';

  @override
  String get username => 'Username';

  @override
  String get emailOrUsername => 'Email or username';

  @override
  String get password => 'Password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get login => 'Sign in';

  @override
  String get serverSettings => 'Server settings';

  @override
  String get orSeparator => 'or';

  @override
  String get useFaceId => 'Use Face ID';

  @override
  String get faceIdUnavailable =>
      'Sign in once to enable Face ID on this device.';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Retry';

  @override
  String get settings => 'Settings';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get leads => 'Leads';

  @override
  String get orders => 'Orders';

  @override
  String get profile => 'Profile';

  @override
  String get createLead => 'Create Lead';

  @override
  String get editLead => 'Edit Lead';

  @override
  String get leadTitle => 'Opportunity title';

  @override
  String get leadUpdated => 'Lead updated successfully';

  @override
  String get selectDate => 'Select a date';

  @override
  String get searchLeads => 'Search leads...';

  @override
  String get searchOrders => 'Search orders...';

  @override
  String get filter => 'Filter';

  @override
  String get all => 'All';

  @override
  String get newLeads => 'New';

  @override
  String get qualified => 'Qualified';

  @override
  String get proposition => 'Proposition';

  @override
  String get won => 'Won';

  @override
  String get lost => 'Lost';

  @override
  String get draft => 'Draft';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get done => 'Done';

  @override
  String get totalLeads => 'Total Leads';

  @override
  String get newLeadsKpi => 'New Leads';

  @override
  String get ordersKpi => 'Orders';

  @override
  String get monthlyRevenue => 'Monthly Revenue';

  @override
  String get pipelineValue => 'Pipeline value';

  @override
  String goodMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String goodAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String goodEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String get recentActivities => 'Recent Activities';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get newLeadAction => 'New Lead';

  @override
  String get newOrderAction => 'New Order';

  @override
  String get searchAction => 'Search';

  @override
  String greeting(String name) {
    return 'Hello, $name!';
  }

  @override
  String get customerName => 'Customer Name';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get source => 'Source';

  @override
  String get note => 'Note';

  @override
  String get salesperson => 'Salesperson';

  @override
  String get stage => 'Stage';

  @override
  String get date => 'Date';

  @override
  String get orderNumber => 'Order #';

  @override
  String get customer => 'Customer';

  @override
  String get amount => 'Amount';

  @override
  String get status => 'Status';

  @override
  String get company => 'Company';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get about => 'About';

  @override
  String get signOut => 'Sign out';

  @override
  String get accountInfo => 'Account Information';

  @override
  String get noLeads => 'No leads found';

  @override
  String get noLeadsMessage =>
      'Try adjusting your filters or create a new lead.';

  @override
  String get noOrders => 'No orders found';

  @override
  String get noOrdersMessage => 'Orders will appear here once created.';

  @override
  String get leadSaved => 'Lead saved successfully';

  @override
  String get leadDetailTitle => 'Lead details';

  @override
  String get contactInfo => 'Contact information';

  @override
  String get salesInfo => 'Sales info';

  @override
  String get description => 'Description';

  @override
  String get expectedRevenue => 'Expected revenue';

  @override
  String get probability => 'Probability';

  @override
  String get priority => 'Priority';

  @override
  String get deadline => 'Closing date';

  @override
  String get lastUpdated => 'Last updated';

  @override
  String get tags => 'Tags';

  @override
  String get address => 'Address';

  @override
  String get city => 'City';

  @override
  String get website => 'Website';

  @override
  String get mobile => 'Mobile';

  @override
  String get jobPosition => 'Job position';

  @override
  String get callAction => 'Call';

  @override
  String get emailAction => 'Email';

  @override
  String get openInOdoo => 'Open in Odoo';

  @override
  String get leadNotFound => 'Lead not found';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityNormal => 'Normal';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityVeryHigh => 'Very high';

  @override
  String get noDescription => 'No description provided.';

  @override
  String get otherInfo => 'Other Information';

  @override
  String get chatterAndNotes => 'Log notes & Chatter';

  @override
  String get logNote => 'Log note';

  @override
  String get logNoteHint => 'Add an internal log note…';

  @override
  String get addLogNote => 'Add log note';

  @override
  String get sendMessage => 'Send message';

  @override
  String get sendMessageHint => 'Write a message…';

  @override
  String get chatterMessage => 'Message';

  @override
  String get activityLog => 'Activity';

  @override
  String get noChatterMessages => 'No messages yet.';

  @override
  String get loading => 'Loading...';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get leadActions => 'Lead actions';

  @override
  String get markWon => 'Mark as won';

  @override
  String get markLost => 'Mark as lost';

  @override
  String get changeStage => 'Change stage';

  @override
  String get assignSalesperson => 'Assign salesperson';

  @override
  String get convertToOpportunity => 'Convert to opportunity';

  @override
  String get lostReason => 'Lost reason';

  @override
  String get selectOption => 'Select…';

  @override
  String get scheduleActivity => 'Schedule activity';

  @override
  String get scheduledActivities => 'Scheduled activities';

  @override
  String get activityHistory => 'Activity history';

  @override
  String get noScheduledActivities => 'No scheduled activities';

  @override
  String get activityType => 'Activity type';

  @override
  String get summary => 'Summary';

  @override
  String get markDone => 'Done';

  @override
  String get pipeline => 'Pipeline';

  @override
  String get listView => 'List view';

  @override
  String get opportunities => 'Opportunities';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortOldest => 'Oldest first';

  @override
  String get sortName => 'Name A–Z';

  @override
  String get sortRevenue => 'Highest revenue';

  @override
  String get sortPriority => 'Highest priority';

  @override
  String get messageAction => 'Message';

  @override
  String get infoTab => 'Info';

  @override
  String get notesTab => 'Notes';

  @override
  String get activityTab => 'Activity';

  @override
  String get noNotesYet => 'No notes yet';

  @override
  String get newQuotation => 'New quotation';

  @override
  String get createQuotation => 'Create quotation';

  @override
  String get orderLines => 'Order lines';

  @override
  String get addLine => 'Add line';

  @override
  String get product => 'Product';

  @override
  String get quantity => 'Quantity';

  @override
  String get unitPrice => 'Unit price';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get total => 'Total';

  @override
  String get customerRequired => 'Customer is required';

  @override
  String get atLeastOneLine => 'Add at least one order line';

  @override
  String get quotationInfo => 'Quotation info';

  @override
  String get origin => 'Origin';

  @override
  String get validityDate => 'Validity date';

  @override
  String get clientOrderRef => 'Customer reference';

  @override
  String get salesTeam => 'Sales team';

  @override
  String get pricelist => 'Pricelist';

  @override
  String get paymentTerm => 'Payment terms';

  @override
  String get createCustomer => 'Create customer';

  @override
  String get selectCustomer => 'Select customer';

  @override
  String get searchProducts => 'Search products…';

  @override
  String get searchCustomers => 'Search customers…';

  @override
  String get sent => 'Sent';

  @override
  String get sale => 'Sales order';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get comingSoon => 'Detail screen coming soon';

  @override
  String quotationCreated(String number) {
    return 'Quotation $number created';
  }

  @override
  String get orderDetailTitle => 'Order details';

  @override
  String get editOrder => 'Edit order';

  @override
  String get edit => 'Edit';

  @override
  String get opportunity => 'Opportunity';

  @override
  String get noOrderLines => 'No order lines';

  @override
  String orderUpdated(String number) {
    return 'Order $number updated';
  }

  @override
  String get orderNotEditable => 'This order cannot be edited';
}
