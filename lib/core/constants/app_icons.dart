/// Icons copied as-is from the Claude Design SVGs, each in the colour the
/// design draws it with. Drawn through `AppSvgIcon`, which recolours them for
/// the theme; the logo marks go through `TranslyMark` and keep their colours.
abstract final class AppIcons {
  static const String _dir = 'assets/icons';

  // ── Translate ──
  static const String speaker = '$_dir/speaker.svg';
  static const String speakerFilled = '$_dir/speaker_filled.svg';
  static const String copy = '$_dir/copy.svg';
  static const String save = '$_dir/save.svg';

  /// The AI badge and the translating note.
  static const String spark = '$_dir/spark.svg';

  /// The four-point star of the plan card, Pro upgrade and AI toast.
  static const String sparkle = '$_dir/sparkle.svg';

  static const String swap = '$_dir/swap.svg';
  static const String keyboard = '$_dir/keyboard.svg';
  static const String mic = '$_dir/mic.svg';
  static const String camera = '$_dir/camera.svg';

  // ── Navigation ── (point the LTR way; mirrored in RTL)
  static const String back = '$_dir/back.svg';
  static const String chevron = '$_dir/chevron.svg';
  static const String arrow = '$_dir/arrow.svg';

  // ── Language picker ──
  static const String closeSheet = '$_dir/close_sheet.svg';
  static const String search = '$_dir/search.svg';
  static const String checkSelect = '$_dir/check_select.svg';
  static const String swapPicker = '$_dir/swap_picker.svg';
  static const String downloadPicker = '$_dir/download_picker.svg';

  // ── Auth ──
  static const String mail = '$_dir/mail.svg';
  static const String lock = '$_dir/lock.svg';
  static const String user = '$_dir/user.svg';
  static const String eye = '$_dir/eye.svg';

  /// The terms checkbox.
  static const String check = '$_dir/check.svg';

  /// Success marks (toast, update notes), from design `10 · Pro Success`.
  static const String checkSuccess = '$_dir/check_success.svg';

  static const String google = '$_dir/google.svg';
  static const String apple = '$_dir/apple.svg';
  static const String facebook = '$_dir/facebook.svg';

  // ── Toast ──
  static const String copyToast = '$_dir/copy_toast.svg';
  static const String error = '$_dir/error.svg';
  static const String delete = '$_dir/delete.svg';

  // ── Profile ──
  static const String cameraBadge = '$_dir/camera_badge.svg';

  // ── Offline packs (designs `12d` and `02d`) ──
  static const String download = '$_dir/download.svg';
  static const String downloadNotice = '$_dir/download_notice.svg';
  static const String trash = '$_dir/trash.svg';
  static const String close = '$_dir/close.svg';

  // ── Logo mark (two rings; drawn as designed, not recoloured) ──
  static const String markWhite = '$_dir/mark_white.svg';
  static const String markCoral = '$_dir/mark_coral.svg';

  /// Every icon above, for the test that checks they are all bundled.
  static const List<String> all = [
    speaker,
    speakerFilled,
    copy,
    save,
    spark,
    sparkle,
    swap,
    keyboard,
    mic,
    camera,
    back,
    chevron,
    arrow,
    closeSheet,
    search,
    checkSelect,
    swapPicker,
    downloadPicker,
    mail,
    lock,
    user,
    eye,
    check,
    checkSuccess,
    google,
    apple,
    facebook,
    copyToast,
    error,
    delete,
    cameraBadge,
    download,
    downloadNotice,
    trash,
    close,
    markWhite,
    markCoral,
  ];
}
