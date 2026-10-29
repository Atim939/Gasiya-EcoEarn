import '../models/models.dart';

/// SAMPLE DATA so the app runs with no backend.
/// Replace with real data (or load from your API in AppData).

String _img(String seed) => 'https://picsum.photos/seed/$seed/600/600';

List<Product> mockProducts() => [
      Product(id: 'p1', name: 'Recycled Phone Stand', description: 'Made from collected plastic', price: 15000, image: _img('gasiya-phonestand'), category: 'plastic', seller: 'Takataka Gulu'),
      Product(id: 'p2', name: 'Recycled Laptop Stand', description: 'Sturdy, lightweight, foldable', price: 45000, image: _img('gasiya-laptopstand'), category: 'plastic', seller: 'Takataka Gulu'),
      Product(id: 'p3', name: 'Woven Polythene Basket', description: 'Handwoven from polythene bags', price: 20000, image: _img('gasiya-basket'), category: 'polythene'),
      Product(id: 'p4', name: 'Glass Bottle Lamp', description: 'Upcycled glass bottle lamp', price: 30000, image: _img('gasiya-lamp'), category: 'glass'),
      Product(id: 'p5', name: 'Scrap Metal Wall Art', description: 'One-of-a-kind decor piece', price: 60000, image: _img('gasiya-wallart'), category: 'metal'),
      Product(id: 'p6', name: 'Rubber Tyre Planter', description: 'Painted tyre garden planter', price: 25000, image: _img('gasiya-planter'), category: 'rubber'),
    ];

// Coordinates are approximate town centres. TODO: replace with real sites.
List<CollectionPoint> mockPoints() => const [
      CollectionPoint(id: 'c1', name: 'Arua Central Collection Point', district: 'Arua', address: 'Arua City centre', hours: 'Mon-Sat, 8am-5pm', phone: '0700000001', lat: 3.0200, lng: 30.9110, accepts: ['polythene', 'plastic', 'glass', 'metal', 'rubber']),
      CollectionPoint(id: 'c2', name: 'Arua Market Drop-off', district: 'Arua', address: 'Near the main market', hours: 'Daily, 7am-4pm', lat: 3.0150, lng: 30.9050, accepts: ['polythene', 'plastic', 'glass']),
      CollectionPoint(id: 'c3', name: 'Gulu Town Collection Point', district: 'Gulu', address: 'Gulu city centre', hours: 'Mon-Sat, 8am-5pm', phone: '0700000002', lat: 2.7747, lng: 32.2990, accepts: ['polythene', 'plastic', 'glass', 'metal', 'rubber']),
      CollectionPoint(id: 'c4', name: 'Nebbi Town Depot', district: 'Nebbi', address: 'Nebbi town', hours: 'Mon-Fri, 8am-4pm', lat: 2.4778, lng: 31.0885, accepts: ['polythene', 'plastic', 'metal']),
      CollectionPoint(id: 'c5', name: 'Koboko Collection Point', district: 'West Nile (other)', address: 'Koboko town', hours: 'Mon-Sat, 8am-4pm', lat: 3.4122, lng: 30.9597, accepts: ['polythene', 'plastic', 'glass']),
      CollectionPoint(id: 'c6', name: 'Yumbe Drop-off', district: 'West Nile (other)', address: 'Yumbe town', hours: 'Mon-Fri, 8am-4pm', lat: 3.4650, lng: 31.2467, accepts: ['plastic', 'metal', 'rubber']),
    ];

List<ImpactStory> mockStories() => [
      ImpactStory(id: 's1', title: 'Market drainage cleared', district: 'Arua', body: 'Volunteers and residents collected polythene bags clogging the drainage channel, and earned points for every kilo.', before: _img('gasiya-before1'), after: _img('gasiya-after1')),
      ImpactStory(id: 's2', title: 'Riverbank clean-up', district: 'Nebbi', body: 'A weekend collection drive cleared plastic bottles from the riverbank and turned them into products for sale.', before: _img('gasiya-before2'), after: _img('gasiya-after2')),
    ];

List<Review> mockReviews() => [
      Review(id: 'r1', name: 'Community member', rating: 5, text: 'I earned points from bottles I used to throw away. Cashing out was easy.', createdAt: DateTime(2026, 10, 2)),
      Review(id: 'r2', name: 'Shop owner', rating: 4, text: 'Collection points are close to the market, which makes dropping off simple.', createdAt: DateTime(2026, 10, 9)),
    ];
