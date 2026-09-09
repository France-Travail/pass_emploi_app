import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/file_picker_wrapper.dart';
import 'package:pass_emploi_app/utils/image_picker_wrapper.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_bottom_sheet.dart';

sealed class ChatPieceJointeBottomSheetResult {
  final String path;

  ChatPieceJointeBottomSheetResult({required this.path});
}

class ChatPieceJointeBottomSheetImageResult
    extends ChatPieceJointeBottomSheetResult {
  ChatPieceJointeBottomSheetImageResult(String path) : super(path: path);
}

class ChatPieceJointeBottomSheetFileResult
    extends ChatPieceJointeBottomSheetResult {
  ChatPieceJointeBottomSheetFileResult(String path) : super(path: path);
}

class ChatPieceJointeBottomSheet extends StatefulWidget {
  const ChatPieceJointeBottomSheet({super.key});

  static Future<ChatPieceJointeBottomSheetResult?> show(BuildContext context) {
    return showDsfrBottomSheet<ChatPieceJointeBottomSheetResult>(
      context: context,
      name: AnalyticsScreenNames.chat,
      builder: (context) => ChatPieceJointeBottomSheet(),
    );
  }

  @override
  State<ChatPieceJointeBottomSheet> createState() =>
      _ChatPieceJointeBottomSheetState();
}

enum PermissionErrorType { none, gallery, camera, file }

class _ChatPieceJointeBottomSheetState
    extends State<ChatPieceJointeBottomSheet> {
  bool showFileTooLargeMessage = false;
  bool showLoading = false;
  PermissionErrorType permissionErrorType = PermissionErrorType.none;

  void _isFileTooLarge(bool isFileTooLarge) {
    setState(() {
      showLoading = false;
      showFileTooLargeMessage = isFileTooLarge;
    });
  }

  void _pickFileSarted() {
    setState(() {
      showLoading = true;
      showFileTooLargeMessage = false;
    });
  }

  void _pickFileEnded() => setState(() => showLoading = false);

  void _onPermissionError(PermissionErrorType type) =>
      setState(() => permissionErrorType = type);

  void _resetErrorMessages() {
    setState(() {
      showFileTooLargeMessage = false;
      permissionErrorType = PermissionErrorType.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DsfrBottomSheet(
      shrinkWrap: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DsfrSpacings.s2w,
          DsfrSpacings.s2w,
          DsfrSpacings.s2w,
          DsfrSpacings.s2w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Title(),
            const SizedBox(height: DsfrSpacings.s2w),
            switch (permissionErrorType) {
              PermissionErrorType.none => SizedBox.shrink(),
              PermissionErrorType.camera => _CameraPermissionWarning(),
              PermissionErrorType.file => _FilePermissionWarning(),
              PermissionErrorType.gallery => _GalleryPermissionWarning(),
            },
            if (permissionErrorType != PermissionErrorType.none)
              const SizedBox(height: DsfrSpacings.s2w),
            if (showFileTooLargeMessage) ...[
              _FileTooLargeWarning(),
              const SizedBox(height: DsfrSpacings.s2w),
            ],
            if (showLoading) ...[
              _Loading(),
              const SizedBox(height: DsfrSpacings.s2w),
            ],
            _PieceJointeWarning(),
            const SizedBox(height: DsfrSpacings.s3v),
            _TakePictureButton(
              onPressed: () => _resetErrorMessages(),
              onPickImagePermissionError: () =>
                  _onPermissionError(PermissionErrorType.camera),
            ),
            const SizedBox(height: DsfrSpacings.s1w),
            _SelectPictureButton(
              onPressed: () => _resetErrorMessages(),
              onPickImagePermissionError: () =>
                  _onPermissionError(PermissionErrorType.gallery),
            ),
            const SizedBox(height: DsfrSpacings.s1w),
            _SelectFileButton(
              onPressed: () => _resetErrorMessages(),
              isFileTooLarge: _isFileTooLarge,
              onPermissionError: () =>
                  _onPermissionError(PermissionErrorType.file),
              pickFileSarted: _pickFileSarted,
              pickFileEnded: _pickFileEnded,
            ),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AutoFocusA11y(
      child: Semantics(
        header: true,
        child: Text(
          Strings.chatPieceJointeBottomSheetTitle,
          style: DsfrTextStyle.headline4(
            color: DsfrColorDecisions.textTitleGrey(context),
          ),
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: Strings.loadingAnnouncement,
      liveRegion: true,
      child: Center(
        child: SizedBox.square(
          dimension: 40,
          child: CircularProgressIndicator(
            color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
          ),
        ),
      ),
    );
  }
}

class _PieceJointeWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DsfrAlert(
      type: DsfrAlertType.info,
      description: DsfrAlertDescriptionText(
        Strings.chatPieceJointeBottomSheetSubtitle,
      ),
    );
  }
}

class _SelectPictureButton extends StatelessWidget {
  final VoidCallback onPressed;
  final VoidCallback onPickImagePermissionError;

  const _SelectPictureButton({
    required this.onPressed,
    required this.onPickImagePermissionError,
  });

  @override
  Widget build(BuildContext context) {
    return _PieceJointeButton(
      icon: DsfrIcons.mediaImageLine,
      text: Strings.chatPieceJointeBottomSheetSelectImageButton,
      onPressed: () async {
        onPressed();
        final result = await ImagePickerWrapper.pickSingleImage();
        if (context.mounted && result is ImagePickerSuccessResult) {
          Navigator.of(
            context,
          ).pop(ChatPieceJointeBottomSheetImageResult(result.path));
        } else if (result is ImagePickerPermissionErrorResult) {
          onPickImagePermissionError();
        }
      },
    );
  }
}

class _TakePictureButton extends StatelessWidget {
  final VoidCallback onPressed;
  final VoidCallback onPickImagePermissionError;

  const _TakePictureButton({
    required this.onPressed,
    required this.onPickImagePermissionError,
  });

  @override
  Widget build(BuildContext context) {
    return _PieceJointeButton(
      icon: DsfrIcons.mediaCameraLine,
      text: Strings.chatPieceJointeBottomSheetTakeImageButton,
      onPressed: () async {
        onPressed();
        final result = await ImagePickerWrapper.takeSinglePicture();
        if (context.mounted && result is ImagePickerSuccessResult) {
          Navigator.of(
            context,
          ).pop(ChatPieceJointeBottomSheetImageResult(result.path));
        } else if (result is ImagePickerPermissionErrorResult) {
          onPickImagePermissionError();
        }
      },
    );
  }
}

class _SelectFileButton extends StatelessWidget {
  final void Function(bool isFileTooLarge) isFileTooLarge;
  final VoidCallback onPressed;
  final VoidCallback onPermissionError;
  final VoidCallback pickFileSarted;
  final VoidCallback pickFileEnded;

  const _SelectFileButton({
    required this.onPressed,
    required this.isFileTooLarge,
    required this.onPermissionError,
    required this.pickFileSarted,
    required this.pickFileEnded,
  });

  @override
  Widget build(BuildContext context) {
    return _PieceJointeButton(
      icon: DsfrIcons.documentFileTextLine,
      text: Strings.chatPieceJointeBottomSheetSelectFileButton,
      onPressed: () async {
        onPressed();
        pickFileSarted();
        final result = await FilePickerWrapper.pickFile();
        if (result is FilePickerSuccessResult && context.mounted) {
          _onFilePicked(context, result);
        } else if (result is FilePickerPermissionErrorResult) {
          onPermissionError();
        }
        pickFileEnded();
      },
    );
  }

  void _onFilePicked(BuildContext context, FilePickerSuccessResult result) {
    final isTooLarge = result.isTooLarge;
    isFileTooLarge(isTooLarge);
    if (context.mounted && !isTooLarge) {
      Navigator.of(
        context,
      ).pop(ChatPieceJointeBottomSheetFileResult(result.path));
    }
  }
}

class _FileTooLargeWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DsfrAlert(
      type: DsfrAlertType.error,
      description: DsfrAlertDescriptionText(
        Strings.chatPieceJointeBottomSheetFileTooLarge,
      ),
    );
  }
}

class _GalleryPermissionWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _PermissionDeniedWarning(
      Strings.chatPieceJointeGalleryPermissionError,
    );
  }
}

class _CameraPermissionWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _PermissionDeniedWarning(
      Strings.chatPieceJointeCameraPermissionError,
    );
  }
}

class _FilePermissionWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _PermissionDeniedWarning(Strings.chatPieceJointeFilePermissionError);
  }
}

class _PermissionDeniedWarning extends StatelessWidget {
  final String message;

  const _PermissionDeniedWarning(this.message);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      focusable: true,
      child: AutoFocusA11y(
        child: DsfrAlert(
          type: DsfrAlertType.warning,
          description: DsfrAlertDescriptionWidget(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: DsfrTextStyle.bodyMd(
                    color: DsfrColorDecisions.textDefaultGrey(context),
                  ),
                ),
                const SizedBox(height: DsfrSpacings.s1w),
                DsfrLink(
                  label: Strings.chatPieceJointeOpenAppSettings,
                  icon: DsfrIcons.systemExternalLinkLine,
                  iconPosition: DsfrLinkIconPosition.end,
                  onTap: () => AppSettings.openAppSettings(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PieceJointeButton extends StatelessWidget {
  const _PieceJointeButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DsfrButton(
      label: text,
      icon: icon,
      variant: DsfrButtonVariant.tertiary,
      size: DsfrComponentSize.lg,
      onPressed: onPressed,
    );
  }
}
