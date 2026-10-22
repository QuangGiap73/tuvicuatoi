class ChartResult {
  const ChartResult({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.solarDate,
    required this.solarTime,
    required this.hourBranch,
    required this.lunarDate,
    required this.lunarYearCanChi,
    required this.namXem,
    required this.amDuongThuanLy,
    required this.menhCucBinhHoa,
    required this.thanCu,
    required this.menh,
    required this.cuc,
    required this.amDuong,
    required this.chuMenh,
    required this.chuThan,
    required this.palaces,
    required this.rawData,
  });

  final String id;
  final String fullName;
  final String gender;
  final String solarDate;
  final String solarTime;
  final String hourBranch;
  final String lunarDate;
  final String lunarYearCanChi;
  final String namXem;
  final String amDuongThuanLy;
  final String menhCucBinhHoa;
  final String thanCu;
  final String menh;
  final String cuc;
  final String amDuong;
  final String chuMenh;
  final String chuThan;
  final List<ChartPalace> palaces;
  final Map<String, dynamic> rawData;

  factory ChartResult.fromJson(Map<String, dynamic> json) {
    final rawPalaces = json['palaces'];
    final palaces = <ChartPalace>[];
    if (rawPalaces is Map) {
      for (final entry in rawPalaces.entries) {
        final value = entry.value;
        if (value is Map) {
          palaces.add(ChartPalace.fromJson(Map<String, dynamic>.from(value)));
        }
      }
    }
    return ChartResult(
      id: _text(json['id']),
      fullName: _text(json['fullName']),
      gender: _text(json['gender']),
      solarDate: _text(json['solarDate']),
      solarTime: _text(json['solarTime']),
      hourBranch: _text(json['hourBranch']),
      lunarDate: _text(json['lunarDate']),
      lunarYearCanChi: _text(json['lunarYearCanChi']),
      namXem: _text(json['namXem']),
      amDuongThuanLy: _text(json['amDuongThuanLy']),
      menhCucBinhHoa: _text(json['menhCucBinhHoa']),
      thanCu: _text(json['thanCu']),
      menh: _text(json['menh']),
      cuc: _text(json['cuc']),
      amDuong: _text(json['amDuong']),
      chuMenh: _text(json['chuMenh']),
      chuThan: _text(json['chuThan']),
      palaces: List.unmodifiable(palaces),
      rawData: Map.unmodifiable(json),
    );
  }
}

class ChartPalace {
  const ChartPalace({
    required this.id,
    required this.branch,
    required this.canChi,
    required this.name,
    required this.element,
    required this.isThan,
    required this.mainStars,
    required this.luckyStars,
    required this.badStars,
    required this.vongTrangSinh,
    required this.daiHanAge,
    required this.tieuHanAges,
  });

  final String id;
  final String branch;
  final String canChi;
  final String name;
  final String element;
  final bool isThan;
  final List<ChartStar> mainStars;
  final List<String> luckyStars;
  final List<String> badStars;
  final String vongTrangSinh;
  final int? daiHanAge;
  final List<int> tieuHanAges;

  factory ChartPalace.fromJson(Map<String, dynamic> json) => ChartPalace(
    id: _text(json['id']),
    branch: _text(json['branch']),
    canChi: _text(json['canChi']),
    name: _text(json['name']),
    element: _text(json['element']),
    isThan: json['isThan'] == true,
    mainStars: _mapList(json['mainStars'], ChartStar.fromJson),
    luckyStars: _stringList(json['luckyStars']),
    badStars: _stringList(json['badStars']),
    vongTrangSinh: _text(json['vongTrangSinh']),
    daiHanAge: (json['daiHanAge'] as num?)?.toInt(),
    tieuHanAges:
        (json['tieuHanAges'] as List?)
            ?.whereType<num>()
            .map((value) => value.toInt())
            .toList(growable: false) ??
        const [],
  );
}

class ChartStar {
  const ChartStar({required this.name, required this.tag});

  final String name;
  final String tag;

  factory ChartStar.fromJson(Map<String, dynamic> json) =>
      ChartStar(name: _text(json['name']), tag: _text(json['tag']));
}

String _text(Object? value) => value?.toString() ?? '';

List<String> _stringList(Object? value) => value is List
    ? value.map((item) => item.toString()).toList(growable: false)
    : const [];

List<T> _mapList<T>(Object? value, T Function(Map<String, dynamic>) parser) =>
    value is List
    ? value
          .whereType<Map>()
          .map((item) => parser(Map<String, dynamic>.from(item)))
          .toList(growable: false)
    : const [];
