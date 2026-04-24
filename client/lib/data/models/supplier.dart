class Supplier {
  final String code;
  final String name;
  final String contact;
  final String? email;
  final String? address;
  final String paymentTerms;
  final int leadTimeDays;
  final List<String> categories;

  const Supplier({
    required this.code,
    required this.name,
    required this.contact,
    this.email,
    this.address,
    required this.paymentTerms,
    required this.leadTimeDays,
    required this.categories,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      code: json['code'] as String,
      name: json['name'] as String,
      contact: json['contact'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
      paymentTerms: json['paymentTerms'] as String,
      leadTimeDays: json['leadTimeDays'] as int,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'contact': contact,
      'email': email,
      'address': address,
      'paymentTerms': paymentTerms,
      'leadTimeDays': leadTimeDays,
      'categories': categories,
    };
  }

  @override
  String toString() {
    return 'Supplier(code: $code, name: $name)';
  }
}

/// Predefined suppliers for Queen Builders
class Suppliers {
  static final List<Supplier> all = [
    const Supplier(
      code: 'SUP-A',
      name: 'Supplier A - Boysen Paint Center',
      contact: '(02) 8888-1234',
      email: 'orders@boysen.com.ph',
      paymentTerms: 'Net 30',
      leadTimeDays: 3,
      categories: ['Paint & Finishing'],
    ),
    const Supplier(
      code: 'SUP-B',
      name: 'Supplier B - Nippon Distributors',
      contact: '(02) 8888-2345',
      email: 'sales@nippon.com.ph',
      paymentTerms: 'Net 30',
      leadTimeDays: 3,
      categories: ['Paint & Finishing'],
    ),
    const Supplier(
      code: 'SUP-C',
      name: 'Supplier C - Holcim Philippines',
      contact: '(02) 8888-3456',
      email: 'orders@holcim.ph',
      paymentTerms: 'Net 45',
      leadTimeDays: 5,
      categories: ['Cement'],
    ),
    const Supplier(
      code: 'SUP-D',
      name: 'Supplier D - Republic Cement',
      contact: '(02) 8888-4567',
      email: 'sales@republiccement.com',
      paymentTerms: 'Net 45',
      leadTimeDays: 5,
      categories: ['Cement'],
    ),
    const Supplier(
      code: 'SUP-E',
      name: 'Supplier E - Hardware Wholesale',
      contact: '(02) 8888-5678',
      email: 'wholesale@hardware.ph',
      paymentTerms: 'Net 15',
      leadTimeDays: 2,
      categories: ['Nails & Fasteners', 'Tools', 'Paint & Finishing'],
    ),
    const Supplier(
      code: 'SUP-F',
      name: 'Supplier F - Local Timber & Quarry',
      contact: '(02) 8888-6789',
      email: 'orders@timber.ph',
      paymentTerms: 'Net 30',
      leadTimeDays: 4,
      categories: ['Wood', 'Aggregates'],
    ),
    const Supplier(
      code: 'SUP-G',
      name: 'Supplier G - Pag-asa Steel Corp',
      contact: '(02) 8888-7890',
      email: 'sales@pagasasteel.com',
      paymentTerms: 'Net 30',
      leadTimeDays: 4,
      categories: ['Steel'],
    ),
    const Supplier(
      code: 'SUP-H',
      name: 'Supplier H - Capitol Steel',
      contact: '(02) 8888-8901',
      email: 'orders@capitolsteel.ph',
      paymentTerms: 'Net 30',
      leadTimeDays: 4,
      categories: ['Steel'],
    ),
    const Supplier(
      code: 'SUP-I',
      name: 'Supplier I - Block Factory',
      contact: '(02) 8888-9012',
      email: 'factory@blocks.ph',
      paymentTerms: 'Cash',
      leadTimeDays: 1,
      categories: ['Blocks'],
    ),
    const Supplier(
      code: 'SUP-J',
      name: 'Supplier J - Roofing Supply',
      contact: '(02) 8888-0123',
      email: 'orders@roofing.ph',
      paymentTerms: 'Net 30',
      leadTimeDays: 3,
      categories: ['Roofing'],
    ),
    const Supplier(
      code: 'SUP-K',
      name: 'Supplier K - Electrical Supply',
      contact: '(02) 8888-1357',
      email: 'sales@electrical.ph',
      paymentTerms: 'Net 30',
      leadTimeDays: 3,
      categories: ['Electrical'],
    ),
    const Supplier(
      code: 'SUP-L',
      name: 'Supplier L - Plumbing Depot',
      contact: '(02) 8888-2468',
      email: 'orders@plumbing.ph',
      paymentTerms: 'Net 30',
      leadTimeDays: 3,
      categories: ['Plumbing'],
    ),
    const Supplier(
      code: 'SUP-M',
      name: 'Supplier M - Tools Distributor',
      contact: '(02) 8888-3579',
      email: 'sales@tools.ph',
      paymentTerms: 'Net 30',
      leadTimeDays: 3,
      categories: ['Tools'],
    ),
    const Supplier(
      code: 'SUP-N',
      name: 'Supplier N - Safety Supply',
      contact: '(02) 8888-4680',
      email: 'orders@safety.ph',
      paymentTerms: 'Net 30',
      leadTimeDays: 2,
      categories: ['Safety Equipment'],
    ),
  ];
}
