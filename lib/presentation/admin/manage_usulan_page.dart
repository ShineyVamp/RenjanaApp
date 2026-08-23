import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dekorasi.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_bar_halaman.dart';
import '../../core/widgets/pesan_kosong.dart';
import '../../data/models/usulan_model.dart';
import '../../data/repositories/usulan_repository.dart';
import '../../core/extensions/navigation.dart';
import '../kontribusi/form_usulan_page.dart';
import '../kontribusi/widgets/kartu_usulan.dart';
import '../kontribusi/widgets/perbandingan_koreksi.dart';
import '../kontribusi/widgets/pratinjau_usulan.dart';

// Tinjauan usulan konten dari seluruh pengguna. Menyetujui langsung
// menerbitkan arsipnya, jadi admin tidak perlu mengetik ulang isinya.
class AdminManageUsulanPage extends StatefulWidget {
  const AdminManageUsulanPage({super.key});

  @override
  State<AdminManageUsulanPage> createState() => _AdminManageUsulanPageState();
}

class _AdminManageUsulanPageState extends State<AdminManageUsulanPage>
    with SingleTickerProviderStateMixin {
  final UsulanRepository _repository = UsulanRepository();

  late final TabController _tab;

  Map<StatusUsulan, int> _jumlah = const {};
  Map<MaksudUsulan, int> _jumlahMaksud = const {};
  List<Usulan> _daftar = const [];
  Map<int, String> _pengusul = const {};
  bool _isLoading = true;

  // null berarti tidak disaring, jadi arsip baru dan koreksi tampil bersama.
  MaksudUsulan? _maksud;

  StatusUsulan get _statusAktif => StatusUsulan.values[_tab.index];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: StatusUsulan.values.length, vsync: this)
      ..addListener(() {
        if (_tab.indexIsChanging) return;
        _muatDaftar();
      });
    _muatData();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _muatData() async {
    final jumlah = await _repository.jumlahPerStatus();
    if (!mounted) return;
    setState(() => _jumlah = jumlah);
    await _muatDaftar();
  }

  Future<void> _muatDaftar() async {
    setState(() => _isLoading = true);
    final jumlahMaksud = await _repository.jumlahPerMaksud(_statusAktif);
    final daftar = await _repository.semua(
      status: _statusAktif,
      maksud: _maksud,
    );

    // nama pengusul diambil sekali per baris, bukan di dalam builder
    final nama = <int, String>{};
    for (final u in daftar) {
      final id = u.id;
      if (id != null) nama[id] = await _repository.namaPengusul(id);
    }

    if (!mounted) return;
    setState(() {
      _daftar = daftar;
      _jumlahMaksud = jumlahMaksud;
      _pengusul = nama;
      _isLoading = false;
    });
  }

  Future<void> _tinjau(Usulan usulan) async {
    final berubah = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LembarTinjauan(
        usulan: usulan,
        pengusul: _pengusul[usulan.id] ?? '',
        repository: _repository,
      ),
    );

    if (!mounted || berubah != true) return;
    await _muatData();
  }

  String get _pesanKosong {
    final status = _statusAktif.label.toLowerCase();
    switch (_maksud) {
      case MaksudUsulan.baru:
        return 'Tidak ada usulan arsip baru berstatus "$status".';
      case MaksudUsulan.koreksi:
        return 'Tidak ada usulan koreksi berstatus "$status".';
      case null:
        return 'Tidak ada usulan berstatus "$status".';
    }
  }

  // Arsip baru dan koreksi ditinjau dengan cara berbeda, jadi keduanya bisa
  // dipisah lewat penyaring ini.
  Widget _buildPenyaring() {
    Widget chip(MaksudUsulan? maksud, String label, int jumlah) {
      final terpilih = _maksud == maksud;

      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () {
            if (_maksud == maksud) return;
            setState(() => _maksud = maksud);
            _muatDaftar();
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: terpilih ? AppColors.primary : AppColors.surface,
              borderRadius: AppDekorasi.radiusKecil,
              border: Border.all(
                color: terpilih ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              '$label ($jumlah)',
              style: AppTypography.eyebrow(
                fontSize: 10.5,
                color: terpilih ? Colors.white : AppColors.textPrimary,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      );
    }

    final baru = _jumlahMaksud[MaksudUsulan.baru] ?? 0;
    final koreksi = _jumlahMaksud[MaksudUsulan.koreksi] ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        height: 30,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            chip(null, 'SEMUA', baru + koreksi),
            chip(MaksudUsulan.baru, 'ARSIP BARU', baru),
            chip(MaksudUsulan.koreksi, 'KOREKSI', koreksi),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarHalaman(
        judul: 'Usulan Konten',
        bawah: TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTypography.eyebrow(
            fontSize: 11.5,
            color: AppColors.primary,
            letterSpacing: 0.4,
          ),
          tabs: [
            for (final s in StatusUsulan.values)
              Tab(text: '${s.label.toUpperCase()} (${_jumlah[s] ?? 0})'),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _buildPenyaring(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _daftar.isEmpty
                    ? PesanKosong(pesan: _pesanKosong, ikon: _statusAktif.ikon)
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _muatData,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                          itemCount: _daftar.length,
                          itemBuilder: (context, index) {
                            final usulan = _daftar[index];
                            return KartuUsulan(
                              usulan: usulan,
                              namaPengusul: _pengusul[usulan.id],
                              onTap: () => _tinjau(usulan),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Lembar tinjauan satu usulan: isinya utuh, lalu tiga keputusan.
class _LembarTinjauan extends StatefulWidget {
  final Usulan usulan;
  final String pengusul;
  final UsulanRepository repository;

  const _LembarTinjauan({
    required this.usulan,
    required this.pengusul,
    required this.repository,
  });

  @override
  State<_LembarTinjauan> createState() => _LembarTinjauanState();
}

class _LembarTinjauanState extends State<_LembarTinjauan> {
  final TextEditingController _catatan = TextEditingController();
  bool _memproses = false;

  @override
  void initState() {
    super.initState();
    _catatan.text = widget.usulan.catatanAdmin;
  }

  @override
  void dispose() {
    _catatan.dispose();
    super.dispose();
  }

  // Menolak dan meminta revisi wajib beralasan; tanpa itu pengusul tidak tahu
  // apa yang harus diperbaiki.
  Future<void> _putuskan(StatusUsulan status) async {
    final id = widget.usulan.id;
    if (id == null) return;

    final catatan = _catatan.text.trim();

    // Persetujuan yang dicabut harus diikuti penarikan arsipnya, kalau tidak
    // konten yang ditolak tetap terbaca pengguna.
    final dicabut =
        status != StatusUsulan.disetujui &&
        widget.usulan.status == StatusUsulan.disetujui;

    if (status != StatusUsulan.disetujui && catatan.isEmpty) {
      _beriTahu('Tuliskan alasannya dulu untuk pengusul.', gagal: true);
      return;
    }

    setState(() => _memproses = true);

    var kodeTagHasil = '';
    if (status == StatusUsulan.disetujui) {
      final hasil = await widget.repository.terapkan(widget.usulan);
      if (!mounted) return;

      if (!hasil.sukses) {
        setState(() => _memproses = false);
        _beriTahu(hasil.galat ?? 'Gagal menerbitkan arsip.', gagal: true);
        return;
      }
      kodeTagHasil = hasil.kodeTag;
    } else if (dicabut) {
      final hasil = await widget.repository.tarikTerbitan(widget.usulan);
      if (!mounted) return;

      if (!hasil.sukses) {
        setState(() => _memproses = false);
        _beriTahu(hasil.galat ?? 'Gagal menarik arsip.', gagal: true);
        return;
      }
    }

    await widget.repository.putuskan(
      id: id,
      status: status,
      catatan: catatan,
      kodeTagHasil: kodeTagHasil,
    );
    if (!mounted) return;

    // Messenger diambil sebelum lembar ditutup, sebab setelah pop context
    // milik lembar ini sudah tidak berlaku.
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context, true);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          status == StatusUsulan.disetujui
              ? 'Usulan disetujui dan terbit sebagai $kodeTagHasil'
              : (dicabut
                    ? 'Usulan ditandai ${status.label.toLowerCase()}, '
                          'arsipnya ditarik kembali'
                    : 'Usulan ditandai ${status.label.toLowerCase()}'),
        ),
        duration: const Duration(milliseconds: 2200),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
  }

  // Admin menyunting isi usulan. Lembar ini ditutup setelahnya supaya
  // daftarnya memuat versi terbaru sebelum dibuka lagi.
  Future<void> _sunting() async {
    final hasil = await context.push(
      FormUsulanPage(usulanAwal: widget.usulan, sebagaiAdmin: true),
    );
    if (!mounted || hasil != true) return;
    Navigator.pop(context, true);
  }

  void _beriTahu(String pesan, {bool gagal = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(pesan),
        duration: const Duration(milliseconds: 2000),
        behavior: SnackBarBehavior.floating,
        backgroundColor: gagal ? AppColors.primaryDark : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usulan = widget.usulan;

    // PembersihDialog tidak dipakai di sini: controllernya milik State ini dan
    // sudah dibuang di dispose(), jadi membungkusnya justru membuang dua kali.
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${usulan.jenis.label.toUpperCase()}'
                      '${usulan.koreksi ? ' · KOREKSI' : ''}',
                      style: AppTypography.eyebrow(),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      usulan.judul.isEmpty ? 'Tanpa judul' : usulan.judul,
                      style: AppTypography.angka(
                        color: AppColors.textPrimary,
                      ).copyWith(fontSize: 22, height: 1.15),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Diusulkan ${widget.pengusul.isEmpty ? 'pengguna' : widget.pengusul}'
            ' · ${KartuUsulan.tanggal(usulan.diperbaruiPada)}',
            style: AppTypography.caption(fontSize: 11.5),
          ),
          const Divider(color: AppColors.border, height: 26),

          if (usulan.koreksi) ...[
            PerbandinganKoreksi(usulan: usulan, repository: widget.repository),
            const Divider(color: AppColors.border, height: 26),
            Text(
              'ISI USULAN SELENGKAPNYA',
              style: AppTypography.eyebrow(fontSize: 9.5),
            ),
            const SizedBox(height: 10),
          ],

          PratinjauUsulan(usulan: usulan),
          const SizedBox(height: 10),

          Text(
            'Catatan untuk pengusul',
            style: AppTypography.labelBold(fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _catatan,
            maxLines: 4,
            style: AppTypography.caption(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              hintText:
                  'Wajib diisi bila menolak atau meminta perbaikan. '
                  'Boleh dikosongkan bila menyetujui.',
              hintStyle: AppTypography.caption(fontSize: 11.5),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: AppDekorasi.radiusKecil,
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppDekorasi.radiusKecil,
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppDekorasi.radiusKecil,
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDekorasi.radiusKecil,
                ),
              ),
              onPressed: _memproses ? null : _sunting,
              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              label: Text(
                'Sunting Isi Usulan',
                style: AppTypography.labelBold(
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          _buildTombol(
            teks: widget.usulan.status == StatusUsulan.disetujui
                ? 'Terbitkan Ulang'
                : 'Setujui & Terbitkan',
            ikon: Icons.verified_rounded,
            warna: AppColors.success,
            utama: true,
            status: StatusUsulan.disetujui,
          ),
          const SizedBox(height: 8),
          _buildTombol(
            teks: 'Minta Perbaikan',
            ikon: Icons.edit_note_rounded,
            warna: AppColors.warning,
            status: StatusUsulan.revisi,
          ),
          const SizedBox(height: 8),
          _buildTombol(
            teks: 'Tolak',
            ikon: Icons.cancel_outlined,
            warna: AppColors.error,
            status: StatusUsulan.ditolak,
          ),
        ],
      ),
    );
  }

  Widget _buildTombol({
    required String teks,
    required IconData ikon,
    required Color warna,
    required StatusUsulan status,
    bool utama = false,
  }) {
    // Setujui tetap hidup pada usulan yang sudah disetujui, sebab dipakai
    // menerbitkan ulang isi yang baru disunting.
    final aktif =
        !_memproses &&
        (status == StatusUsulan.disetujui || widget.usulan.status != status);

    return SizedBox(
      width: double.infinity,
      child: utama
          ? ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: warna,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDekorasi.radiusKecil,
                ),
              ),
              onPressed: aktif ? () => _putuskan(status) : null,
              icon: Icon(ikon, size: 18, color: Colors.white),
              label: Text(
                _memproses ? 'Memproses…' : teks,
                style: AppTypography.buttonText().copyWith(fontSize: 13.5),
              ),
            )
          : OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: warna),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDekorasi.radiusKecil,
                ),
              ),
              onPressed: aktif ? () => _putuskan(status) : null,
              icon: Icon(ikon, size: 18, color: warna),
              label: Text(
                teks,
                style: AppTypography.labelBold(fontSize: 13, color: warna),
              ),
            ),
    );
  }
}
