# Sudoku Pro — Use Case & Implementation Specification

**Proyek:** Sudoku Pro (Tim B)
**Versi dokumen:** 1.0
**Basis:** Wireframe 7 screen — Home, Login, Game, Leaderboard, Game Completed, Statistics, Profile/Settings
**Tujuan:** Acuan implementasi kode (functional spec) yang turun langsung dari wireframe.

---

## 0. Catatan Asumsi & Gap pada Wireframe

Sebelum use case, ada beberapa hal yang **tidak terlihat di wireframe** tapi diperlukan agar aplikasi berjalan. Saya tandai supaya Tim B bisa diskusi/konfirmasi:

| Kode | Asumsi / Gap | Rekomendasi |
|------|--------------|-------------|
| GAP-01 | Screen **Register/Sign Up** tidak ada, padahal ada link "Create an Account" di Login | Buat screen register dengan minimal: email, password, confirm password, username |
| GAP-02 | Screen **Forgot Password** tidak ada, padahal link-nya ada di Login | Buat flow: input email → kirim reset link → screen konfirmasi |
| GAP-03 | Screen **Game Over** (saat mistakes 3/3) tidak ada | Buat modal/screen game over dengan opsi Restart, New Game, Back to Home |
| GAP-04 | Screen **Pause** dan handling pause game tidak ada | Tambahkan tombol pause di game screen; pause = timer berhenti, board di-blur |
| GAP-05 | Difficulty **Master** terlihat locked (ikon gembok). Kondisi unlock tidak dijelaskan | Asumsi: unlock setelah menyelesaikan minimal 10 Expert level |
| GAP-06 | Fitur **Friends** di leaderboard butuh sistem pertemanan (add friend, accept request) yang tidak ada screen-nya | Untuk MVP, asumsikan Friends = user yang follow-mutual via username; atau buat screen "Add Friend" terpisah |
| GAP-07 | "Change Theme" muncul di Game Completed tapi **tidak ada toggle theme di Settings** | Tambahkan menu "Theme" di Settings (Light/Dark/System) |
| GAP-08 | Daftar bahasa di Language tidak dispesifikasi | Default: English; minimal tambah Bahasa Indonesia |
| GAP-09 | Behavior **Notes** & **Hint** tidak terlihat di wireframe | Asumsi standar: Notes = toggle mode pencil-mark; Hint = limited per game (3x) |
| GAP-10 | Tidak ada screen detail untuk **Edit Profile**, **Privacy & Security**, **Notifications** | Perlu desain tambahan, atau scope-out dari MVP |

**Konfidensi pada interpretasi wireframe: [Medium]** — sebagian behavior saya simpulkan dari konvensi umum game Sudoku karena wireframe tidak punya prototype interaktif.

---

## 1. Aktor

| Aktor | Deskripsi |
|-------|-----------|
| **Guest** | Pengguna yang belum login. Hanya bisa akses screen Login/Register |
| **Player** | Pengguna terdaftar yang sudah login. Akses penuh ke fitur game |
| **System** | Aplikasi itu sendiri (generator puzzle, validator, timer, scorer) |

---

## 2. Daftar Use Case (Ringkas)

| ID | Use Case | Aktor | Prioritas |
|----|----------|-------|-----------|
| UC-01 | Login | Guest | High |
| UC-02 | Register Akun Baru | Guest | High |
| UC-03 | Lupa Password | Guest | Medium |
| UC-04 | Login via Google/Apple (SSO) | Guest | Medium |
| UC-05 | Logout | Player | High |
| UC-06 | Memulai Game Baru (pilih difficulty) | Player | High |
| UC-07 | Melanjutkan Game (Continue) | Player | High |
| UC-08 | Mengisi Sel Sudoku | Player | High |
| UC-09 | Menghapus Isi Sel (Erase) | Player | High |
| UC-10 | Undo Aksi | Player | High |
| UC-11 | Menggunakan Notes (Pencil Mark) | Player | Medium |
| UC-12 | Menggunakan Hint | Player | Medium |
| UC-13 | Menyelesaikan Game | Player + System | High |
| UC-14 | Game Over karena Mistakes 3/3 | Player + System | High |
| UC-15 | Melihat Leaderboard | Player | Medium |
| UC-16 | Filter Leaderboard (Global/Friends + Daily/Weekly/All Time) | Player | Medium |
| UC-17 | Share Hasil/Ranking | Player | Low |
| UC-18 | Melihat Statistik Pribadi | Player | Medium |
| UC-19 | Melihat Profil & Rank | Player | Medium |
| UC-20 | Edit Profil | Player | Low |
| UC-21 | Mengubah Bahasa | Player | Low |
| UC-22 | Mengubah Tema (Light/Dark) | Player | Low |
| UC-23 | Mengatur Notifikasi | Player | Low |

---

## 3. Detail Use Case

### UC-01: Login

| Field | Isi |
|-------|-----|
| **ID** | UC-01 |
| **Nama** | Login |
| **Aktor** | Guest |
| **Deskripsi** | Pengguna terdaftar masuk ke aplikasi menggunakan email dan password |
| **Precondition** | Pengguna sudah memiliki akun terdaftar; tidak sedang login |
| **Trigger** | Pengguna membuka aplikasi dan diarahkan ke screen Login |
| **Main Flow** | 1. System menampilkan screen Login dengan input email & password<br>2. Player input email pada field "Email Address"<br>3. Player input password pada field "Password"<br>4. (Opsional) Player centang "Remember Me"<br>5. Player tekan tombol "LOGIN TO PLAY"<br>6. System validasi format email & password tidak kosong<br>7. System kirim request autentikasi ke backend<br>8. System menerima response sukses + token<br>9. System simpan token (jika Remember Me: persistent storage, jika tidak: session storage)<br>10. System redirect ke Home screen |
| **Alternate Flow** | **A1 – Email/password salah:**<br>• Step 8: backend return 401<br>• System tampilkan error "Email atau password salah"<br>• Kembali ke step 2<br><br>**A2 – Format email invalid:**<br>• Step 6: validasi gagal<br>• System tampilkan inline error di field email<br><br>**A3 – Network error:**<br>• System tampilkan toast "Tidak ada koneksi internet"<br><br>**A4 – Klik "Forgot Password?":**<br>• Pindah ke UC-03<br><br>**A5 – Klik "Google" atau "Apple":**<br>• Pindah ke UC-04<br><br>**A6 – Klik "Create an Account":**<br>• Pindah ke UC-02 |
| **Postcondition** | Player ter-autentikasi; token tersimpan; user data tersedia di state global |
| **Catatan implementasi** | • Validasi password minimal: ≥8 karakter (cek di register, tidak di login)<br>• Token sebaiknya JWT dengan expiry; "Remember Me" extends refresh token<br>• Hindari menyimpan password di state mana pun<br>• Loading state pada tombol saat request berlangsung |

---

### UC-02: Register Akun Baru ⚠️ *Screen belum ada di wireframe*

| Field | Isi |
|-------|-----|
| **ID** | UC-02 |
| **Aktor** | Guest |
| **Precondition** | Belum punya akun |
| **Main Flow** | 1. Player klik "New to the grid? Create an Account" di Login screen<br>2. System tampilkan screen Register<br>3. Player input: username, email, password, confirm password<br>4. Player tekan "REGISTER"<br>5. System validasi (lihat aturan di bawah)<br>6. System kirim ke backend<br>7. Backend create user, return success<br>8. System auto-login user → redirect Home |
| **Alternate Flow** | **A1:** Email sudah terdaftar → error "Email sudah digunakan"<br>**A2:** Username sudah dipakai → error<br>**A3:** Password & confirm tidak match → error inline<br>**A4:** Password lemah → error |
| **Aturan Validasi** | • Username: 3–20 karakter, alfanumerik + underscore<br>• Email: regex standar email<br>• Password: min 8 karakter, ada huruf & angka |

---

### UC-06: Memulai Game Baru (Pilih Difficulty)

| Field | Isi |
|-------|-----|
| **ID** | UC-06 |
| **Aktor** | Player |
| **Precondition** | Player sudah login dan berada di Home screen |
| **Main Flow** | 1. System tampilkan Home screen dengan section "NEW GAME — SELECT DIFFICULTY" berisi 5 tombol: Easy, Medium, Hard, Expert, Master<br>2. Player tekan salah satu tombol difficulty (kecuali Master jika locked)<br>3. System generate puzzle baru sesuai difficulty<br>4. System reset state game (mistakes=0, timer=00:00, undo stack kosong)<br>5. System tampilkan Game screen dengan puzzle baru |
| **Alternate Flow** | **A1 – Player tekan Master saat locked:**<br>• System tampilkan modal/toast: "Selesaikan 10 Expert level untuk unlock Master"<br><br>**A2 – Ada game yang sedang berjalan (continue game tersedia):**<br>• Sistem tampilkan konfirmasi "Mulai game baru akan menghapus progress saat ini, lanjutkan?" |
| **Postcondition** | Game baru aktif; state tersimpan otomatis |
| **Catatan implementasi** | **Puzzle generator:**<br>• Pakai library seperti `sudoku` (npm) atau implementasi backtracking + symmetric digging<br>• Difficulty ditentukan jumlah clue yang diberikan:<br>  - Easy: 36–40 clue<br>  - Medium: 30–35<br>  - Hard: 25–29<br>  - Expert: 22–24<br>  - Master: 17–21<br>• **Validasi solusi unik** wajib (puzzle harus punya tepat 1 solusi)<br>• Generator yang lambat → jalankan di Web Worker / background isolate |

---

### UC-07: Melanjutkan Game (Continue)

| Field | Isi |
|-------|-----|
| **ID** | UC-07 |
| **Aktor** | Player |
| **Precondition** | Ada game yang belum selesai tersimpan |
| **Main Flow** | 1. Home screen tampilkan card "CONTINUE GAME" dengan info level & sisa waktu<br>2. Player tekan "CONTINUE"<br>3. System load state game dari storage (board, timer, mistakes, notes, undo stack)<br>4. System tampilkan Game screen dengan state ter-restore |
| **Alternate Flow** | **A1 – Tidak ada saved game:**<br>• Card "CONTINUE GAME" tidak ditampilkan |
| **Catatan implementasi** | • Auto-save tiap user melakukan aksi (debounce 500ms)<br>• Storage: localStorage (web) / SharedPreferences-DB (mobile)<br>• Schema game state: lihat section 5 (Data Model) |

---

### UC-08: Mengisi Sel Sudoku

| Field | Isi |
|-------|-----|
| **ID** | UC-08 |
| **Aktor** | Player |
| **Precondition** | Berada di Game screen, game belum selesai, mistakes < 3 |
| **Main Flow** | 1. Player tap sel kosong di grid → sel ter-highlight (selected)<br>2. System juga highlight: baris, kolom, dan 3×3 box dari sel (visual cue)<br>3. Player tekan angka 1–9 di number pad<br>4. System cek apakah Notes mode aktif (lihat UC-11)<br>5. Jika **bukan** Notes mode: system isi angka ke sel<br>6. System validasi: angka cocok dengan solusi?<br>   - **Ya:** sel tampil normal; cek apakah board penuh (lihat UC-13)<br>   - **Tidak:** sel ditandai merah; mistakes counter +1<br>7. System push aksi ke undo stack<br>8. System auto-save state |
| **Alternate Flow** | **A1 – Sel adalah clue awal (pre-filled):**<br>• Step 1: sel tidak bisa di-select untuk diisi (read-only)<br><br>**A2 – Mistakes mencapai 3:**<br>• Lanjut ke UC-14 (Game Over)<br><br>**A3 – Angka yang sama sudah ada di baris/kolom/box:**<br>• Tetap diisi, tapi highlight conflict (UX tambahan) |
| **Catatan implementasi** | • Cell state perlu field: `value`, `isFixed`, `isError`, `notes[]`<br>• Validasi error = compare dengan solution grid yang disimpan sejak puzzle di-generate (bukan re-solve tiap kali, mahal)<br>• Highlight: gunakan CSS class atau styling state, bukan rerender keseluruhan grid |

---

### UC-10: Undo Aksi

| Field | Isi |
|-------|-----|
| **ID** | UC-10 |
| **Aktor** | Player |
| **Main Flow** | 1. Player tekan tombol "UNDO"<br>2. System pop aksi terakhir dari undo stack<br>3. System restore state sel ke sebelum aksi<br>4. (Jika aksi sebelumnya menambah mistake) decrement mistake counter |
| **Alternate Flow** | **A1 – Undo stack kosong:**<br>• Tombol disabled atau no-op |
| **Catatan implementasi** | • Undo stack berupa array of `{cellIndex, prevValue, prevNotes, wasError}`<br>• **Pertimbangan:** apakah undo bisa "mengembalikan" mistake yang sudah dihitung? Saran: **tidak**, supaya tidak abuse. Tapi UI tetap konsisten — diskusi tim |

---

### UC-11: Menggunakan Notes (Pencil Mark)

| Field | Isi |
|-------|-----|
| **ID** | UC-11 |
| **Aktor** | Player |
| **Main Flow** | 1. Player tekan tombol "NOTES" → mode notes aktif (visual: tombol toggle highlighted)<br>2. Player tap sel kosong<br>3. Player tekan angka 1–9<br>4. System tambahkan angka tsb ke array `notes` sel (kecil-kecil di sudut sel)<br>5. Jika angka sudah ada di notes → angka tersebut dihapus (toggle) |
| **Catatan implementasi** | • Render notes sebagai grid 3×3 di dalam cell<br>• Saat sel diisi angka final (non-notes), clear semua notes di sel itu<br>• **Auto-clean notes:** ketika player mengisi angka X di sel, hapus notes "X" dari sel lain di baris/kolom/box yang sama (fitur QoL — opsional) |

---

### UC-12: Menggunakan Hint

| Field | Isi |
|-------|-----|
| **ID** | UC-12 |
| **Aktor** | Player |
| **Precondition** | Hint quota > 0; ada sel kosong dengan sel ter-select (atau tidak, tergantung design) |
| **Main Flow** | 1. Player tekan tombol "HINT"<br>2. System pilih sel yang akan di-reveal (lihat strategi di bawah)<br>3. System isi sel dengan angka yang benar<br>4. System decrement hint quota<br>5. Aksi **tidak** masuk undo stack (atau masuk dengan flag khusus — diskusi tim) |
| **Alternate Flow** | **A1 – Hint quota habis:**<br>• Tombol disabled, atau munculkan opsi "watch ad / upgrade Pro" jika ada monetisasi |
| **Strategi pilih sel hint** | Opsi A: sel yang sedang ter-select (jika kosong)<br>Opsi B: sel kosong random<br>Opsi C: sel termudah berdasarkan teknik solving (naked single dulu) — kompleks tapi lebih edukatif<br>**Rekomendasi MVP: Opsi A dengan fallback ke B** |
| **Catatan** | • Quota default: 3 per game<br>• Hint counter perlu masuk ke game state (untuk continue) |

---

### UC-13: Menyelesaikan Game

| Field | Isi |
|-------|-----|
| **ID** | UC-13 |
| **Aktor** | Player + System |
| **Precondition** | Board penuh; semua sel valid |
| **Main Flow** | 1. (Trigger setelah UC-08 step 6) System cek apakah seluruh board penuh & match solusi<br>2. System stop timer<br>3. System hitung skor (formula di bawah)<br>4. System update streak (jika game diselesaikan dalam 1 hari berturut-turut → streak +1)<br>5. System update statistik: games_won, win_rate, best_time, current_streak, longest_streak<br>6. System cek personal best — jika waktu < best_time sebelumnya → tandai "NEW PERSONAL BEST"<br>7. System tampilkan screen "Game Completed!" dengan: completion time, total score, indikator personal best, streak<br>8. System kirim hasil ke backend (untuk leaderboard) |
| **Aksi dari Game Completed** | • **PLAY NEXT LEVEL:** generate puzzle baru dengan difficulty sama → UC-06<br>• **CHANGE THEME:** buka modal theme switcher<br>• **SHARE RESULT:** UC-17<br>• Tutup (X) atau navigasi bottom nav |
| **Formula skor (saran)** | `score = base_score(difficulty) - (waktu_detik × 0.5) - (mistakes × 50) - (hint_dipakai × 100)`<br>Dengan base_score: Easy=500, Medium=750, Hard=1000, Expert=1250, Master=1500<br>**Konfidensi: [Low]** — ini hanya saran, Tim B perlu definisi resmi |
| **Postcondition** | Statistik ter-update; saved game di-clear; entry leaderboard ter-submit |

---

### UC-14: Game Over karena Mistakes 3/3 ⚠️ *Screen belum ada*

| Field | Isi |
|-------|-----|
| **ID** | UC-14 |
| **Main Flow** | 1. (Trigger dari UC-08 saat mistake counter = 3) System tampilkan modal Game Over<br>2. Modal berisi: "Game Over", waktu yang berlalu, jumlah sel terisi<br>3. Opsi: "Try Again" (puzzle sama), "New Puzzle" (UC-06), "Back to Home"<br>4. System update statistik: games_played (tidak naik di win_rate jika kalah), streak reset |
| **Catatan** | • Streak harian reset jika kalah? **Diskusi tim** — saran: streak win-based, jadi kalah memutus streak |

---

### UC-15: Melihat Leaderboard

| Field | Isi |
|-------|-----|
| **ID** | UC-15 |
| **Main Flow** | 1. Player tap "RANKS" di bottom nav<br>2. System tampilkan leaderboard dengan default: Global + Daily<br>3. Top 3 ditampilkan dalam podium (rank 1 di tengah, 2 di kiri, 3 di kanan) dengan nama, score/time<br>4. Rank 4 ke bawah ditampilkan list dengan: rank, avatar, username, level/tag, time/score<br>5. Di bawah ada sticky bar "Your Ranking" dengan rank & time pengguna saat ini |
| **Catatan implementasi** | • Pagination atau infinite scroll untuk list panjang<br>• Cache hasil leaderboard 1–5 menit untuk hemat call<br>• **Privacy concern:** semua user terlihat by username — pastikan ToS jelas |

---

### UC-16: Filter Leaderboard

| Field | Isi |
|-------|-----|
| **Main Flow** | • Toggle Global ↔ Friends di top tab<br>• Toggle Daily / Weekly / All Time di filter pills<br>• Setiap toggle: refetch leaderboard dengan parameter baru |
| **API endpoint (saran)** | `GET /leaderboard?scope=global&period=daily&limit=50&offset=0` |

---

### UC-18: Melihat Statistik Pribadi

| Field | Isi |
|-------|-----|
| **Main Flow** | 1. Player tap "STATS" di bottom nav<br>2. System tampilkan grid 2×2: Games Won, Win Rate, Best Time, Current Streak; + 2 kotak: Longest Streak, Total Games<br>3. Di bawah ada list "Recent Games" — 4 entry terakhir dengan: level, tanggal/jam, points<br>4. Tap entry recent game → (opsional) detail game tersebut |
| **Catatan implementasi** | • Hitung di backend, kirim sebagai 1 endpoint: `GET /users/me/stats`<br>• `win_rate = (games_won / games_played) × 100%`<br>• Cache di client, refresh tiap masuk Stats screen |

---

### UC-19 & UC-20: Profile & Edit Profile

| Field | Isi |
|-------|-----|
| **Main Flow Profile** | 1. Tap "PROFILE" di bottom nav<br>2. System tampilkan: avatar (badge PRO jika applicable), username, rank title, ringkasan stats (3 kolom), current rank card, settings menu, logout button |
| **Edit Profile** | Tap "Edit Profile" → screen baru (belum ada wireframe) berisi: upload avatar, ubah username, ubah email (perlu re-verify), ubah password |

---

### UC-21 / 22 / 23: Settings (Language / Theme / Notifications)

Ketiganya pola sama — buka detail screen, pilih opsi, simpan ke preferences storage, terapkan instan.

| Setting | Detail |
|---------|--------|
| Language | List bahasa (radio), default English. Pakai i18n library (i18next/Flutter intl) |
| Theme | Light / Dark / System default. Apply via CSS variables atau Material ThemeMode |
| Notifications | Toggle untuk: Daily Reminder, Streak Alert, Leaderboard Update. Backend perlu endpoint update preferences |

---

## 4. Functional Requirements Mapping

| Req ID | Functional Requirement | Use Case |
|--------|------------------------|----------|
| FR-01 | Sistem harus generate puzzle Sudoku dengan 5 level difficulty yang valid (solusi unik) | UC-06 |
| FR-02 | Sistem harus menyimpan progress game otomatis | UC-07, UC-08 |
| FR-03 | Sistem harus mendeteksi error input & mengakumulasi maksimal 3 mistakes per game | UC-08, UC-14 |
| FR-04 | Sistem harus menyediakan tools bantu: Undo, Erase, Notes, Hint | UC-09 s/d UC-12 |
| FR-05 | Sistem harus menghitung skor & waktu, menyimpannya ke leaderboard | UC-13 |
| FR-06 | Sistem harus menampilkan leaderboard dengan filter scope & period | UC-15, UC-16 |
| FR-07 | Sistem harus menampilkan statistik personal yang ter-update real-time | UC-18 |
| FR-08 | Sistem harus mendukung autentikasi email/password & SSO | UC-01, UC-04 |
| FR-09 | Sistem harus mendukung kustomisasi: bahasa, tema, notifikasi | UC-21, UC-22, UC-23 |

---

## 5. Data Model (Saran)

```
User {
  id: UUID
  username: string (unique)
  email: string (unique)
  passwordHash: string
  avatarUrl: string?
  rank: enum (Beginner | Intermediate | Advanced | Expert | Pro | Master)
  isPro: boolean
  createdAt: timestamp
  preferences: {
    language: string
    theme: enum (light | dark | system)
    notifications: { daily: bool, streak: bool, leaderboard: bool }
  }
}

GameSession {           // game yang sedang berjalan (saved game)
  id: UUID
  userId: UUID (FK)
  difficulty: enum
  puzzle: int[81]       // grid awal (0 = empty)
  solution: int[81]     // solusi (untuk validasi)
  currentBoard: int[81]
  notes: int[][81]      // array of notes per cell
  mistakes: int
  hintsUsed: int
  elapsedSeconds: int
  undoStack: Action[]
  startedAt: timestamp
  lastSavedAt: timestamp
  isCompleted: boolean
}

GameResult {            // game yang sudah selesai (untuk stats & leaderboard)
  id: UUID
  userId: UUID
  difficulty: enum
  completionTimeSeconds: int
  score: int
  mistakes: int
  hintsUsed: int
  isWon: boolean
  completedAt: timestamp
}

UserStats {             // bisa di-cache, di-compute dari GameResult
  userId: UUID
  gamesWon: int
  gamesPlayed: int
  winRate: float
  bestTimeSeconds: int
  currentStreak: int
  longestStreak: int
  totalGames: int
}

Friendship {            // jika fitur Friends di-implement
  userId: UUID
  friendId: UUID
  status: enum (pending | accepted)
  createdAt: timestamp
}
```

---

## 6. Saran Struktur Komponen (UI-agnostic)

```
screens/
├── auth/
│   ├── LoginScreen
│   ├── RegisterScreen          ⚠️ belum ada wireframe
│   └── ForgotPasswordScreen    ⚠️ belum ada wireframe
├── home/
│   └── HomeScreen
├── game/
│   ├── GameScreen
│   ├── components/
│   │   ├── SudokuGrid
│   │   ├── SudokuCell
│   │   ├── NumberPad
│   │   ├── ActionBar (Undo, Erase, Notes, Hint)
│   │   ├── GameHeader (Mistakes, Timer)
│   │   └── DifficultyBadge
│   └── GameCompletedModal
│   └── GameOverModal           ⚠️ belum ada wireframe
├── leaderboard/
│   ├── LeaderboardScreen
│   ├── components/
│   │   ├── Podium
│   │   ├── LeaderboardList
│   │   └── ScopeFilter
├── stats/
│   └── StatsScreen
├── profile/
│   ├── ProfileScreen
│   ├── EditProfileScreen       ⚠️ belum ada wireframe
│   └── SettingsScreens (Language, Theme, Notifications, Privacy)
└── shared/
    └── BottomNavigation
```

**State management:**
- **Global state:** auth/user, current game session, user stats
- **Local state:** UI state (filters aktif, modal terbuka, dll)
- **Rekomendasi:** Zustand/Redux Toolkit (React), Riverpod/Bloc (Flutter), Pinia (Vue) — tergantung stack Tim B yang belum saya tahu

---

## 7. Endpoint API yang Dibutuhkan (Saran)

| Method | Endpoint | Use Case |
|--------|----------|----------|
| POST | `/auth/register` | UC-02 |
| POST | `/auth/login` | UC-01 |
| POST | `/auth/forgot-password` | UC-03 |
| POST | `/auth/sso/google` | UC-04 |
| POST | `/auth/logout` | UC-05 |
| GET | `/games/generate?difficulty=...` | UC-06 (atau client-side) |
| GET | `/games/current` | UC-07 |
| PUT | `/games/current` | auto-save UC-08 |
| POST | `/games/complete` | UC-13 |
| GET | `/leaderboard?scope=...&period=...` | UC-15, UC-16 |
| GET | `/users/me/stats` | UC-18 |
| GET | `/users/me` | UC-19 |
| PATCH | `/users/me` | UC-20 |
| PATCH | `/users/me/preferences` | UC-21, UC-22, UC-23 |

**Catatan:** generate puzzle bisa client-side (lebih hemat server) atau server-side (lebih konsisten anti-cheat). Diskusi Tim B.

---

## 8. Anti-Pattern & Risiko Implementasi

Hal-hal yang sering keliru dikerjakan di proyek serupa — heads-up:

1. **Re-render seluruh grid tiap input** → laggy di mobile. Gunakan memoization per-cell (React.memo / const widget Flutter).
2. **Validasi dengan solve ulang tiap input** → sangat mahal. Simpan solution array di state, compare langsung.
3. **Timer pakai `setInterval` tanpa cleanup** → memory leak saat navigasi. Selalu cleanup di unmount.
4. **Auto-save tiap keystroke tanpa debounce** → spam I/O. Debounce 300–500ms.
5. **Leaderboard call tiap masuk screen** → boros. Cache + pull-to-refresh.
6. **Generator puzzle di main thread** → freeze UI. Web Worker / Isolate.
7. **Tidak ada idempotency pada `/games/complete`** → submit ganda saat retry network → leaderboard double entry. Pakai client-generated UUID.
8. **Tidak ada rate limit pada submit skor** → mudah di-cheat. Tambahkan server-side validation: time minimum (puzzle tidak mungkin selesai < N detik).

---

## 9. Saran Prioritas Pengerjaan (MVP)

**Sprint 1 (Core gameplay — tanpa ini tidak ada apa-apa):**
UC-06, UC-08, UC-09, UC-10, UC-13, UC-14

**Sprint 2 (Auth & persistence):**
UC-01, UC-02, UC-05, UC-07

**Sprint 3 (QoL gameplay):**
UC-11, UC-12

**Sprint 4 (Sosial & stats):**
UC-15, UC-16, UC-18, UC-19

**Sprint 5 (Polish):**
UC-03, UC-04, UC-17, UC-20, UC-21, UC-22, UC-23

---

## 10. Hal yang Saya Belum Bisa Pastikan (Perlu Konfirmasi Tim B)

1. **Stack teknologi** — web (framework apa?) atau mobile (Flutter/RN/native?)
2. **Backend** — sudah ada, belum, atau mau pakai BaaS (Firebase/Supabase)?
3. **Formula skor resmi** — saya kasih saran, tapi Tim B harus tetapkan
4. **Definisi "rank title"** di profile (Beginner/Pro/dll) — kriteria naik rank apa?
5. **Master unlock condition** — saya asumsikan 10 Expert wins
6. **Hint quota per game** — saya asumsikan 3
7. **Apakah Friends sistem perlu fitur add/remove**, atau cukup mutual-follow?
8. **Sumber puzzle** — generate atau database puzzle pre-made?

Sebelum coding dimulai, item 1–8 sebaiknya dijawab dulu di meeting tim — biar nggak ada rework besar di tengah jalan.
