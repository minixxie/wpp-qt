#TEMPLATE = lib

QT += widgets sql concurrent positioning gui_private
qtHaveModule(webengine) {
	QT += webengine
	DEFINES += QT_WEBVIEW_WEBENGINE_BACKEND
}


INCLUDEPATH += $$PWD/src/

SOURCES += \
	$$PWD/src/wpp/lang/Pinyin.cpp $$PWD/src/wpp/lang/PinyinData.cpp \
	$$PWD/src/wpp/qt/Application.cpp \
	$$PWD/src/wpp/qt/System.cpp \
	$$PWD/src/wpp/qt/Keyboard.cpp \
	$$PWD/src/wpp/qt/Resolution.cpp \
	$$PWD/src/wpp/qt/NetworkAccessManager.cpp \
	$$PWD/src/wpp/qt/HttpAgent.cpp \
	$$PWD/src/wpp/qt/CookieJar.cpp \
	$$PWD/src/wpp/qt/LocalStorage.cpp \
	$$PWD/src/wpp/qt/GeoPosition.cpp \
	$$PWD/src/wpp/qt/AbstractDataCache.cpp \
	$$PWD/src/wpp/qt/TimeAgo.cpp \
	$$PWD/src/wpp/qt/Map.cpp \
	$$PWD/src/wpp/qt/PermissionDeniedException.cpp \
	$$PWD/src/wpp/qt/ReadAddressBookPermissionDeniedException.cpp \
	$$PWD/src/wpp/qt/AddressBookContact.cpp \
	$$PWD/src/wpp/qt/AddressBookContactPhone.cpp \
	$$PWD/src/wpp/qt/AddressBookContactEmail.cpp \
	$$PWD/src/wpp/qt/AddressBookReader.cpp \
	$$PWD/src/wpp/qt/AbstractBaseController.cpp \
	$$PWD/src/wpp/qt/AbstractMainController.cpp \
	$$PWD/src/wpp/qt/PhotoCaptureController.cpp \
	$$PWD/src/wpp/qt/CaptureImageProvider.cpp \
	$$PWD/src/wpp/qt/Gallery.cpp \
	$$PWD/src/wpp/qt/NativeMap.cpp \
	$$PWD/src/wpp/qt/ImagePicker.cpp \
	$$PWD/src/wpp/qt/NativeCamera.cpp \
	$$PWD/src/wpp/qt/NativeDateTimePicker.cpp \
	$$PWD/src/wpp/qt/IOSTimeZonePicker.cpp \
	$$PWD/src/wpp/qt/QObjectStarList.cpp 

HEADERS += \
	$$PWD/src/wpp/lang/Pinyin.h \
	$$PWD/src/wpp/qt/Application.h \
	$$PWD/src/wpp/qt/QmlApplicationEngine.h \
	$$PWD/src/wpp/qt/System.h \
	$$PWD/src/wpp/qt/Keyboard.h \
	$$PWD/src/wpp/qt/Route.h \
	$$PWD/src/wpp/qt/Resolution.h \
	$$PWD/src/wpp/qt/NetworkAccessManager.h \
	$$PWD/src/wpp/qt/HttpAgent.h \
	$$PWD/src/wpp/qt/CookieJar.h \
	$$PWD/src/wpp/qt/LocalStorage.h \
	$$PWD/src/wpp/qt/GeoPosition.h \
	$$PWD/src/wpp/qt/AbstractDataCache.h \
	$$PWD/src/wpp/qt/TimeAgo.h \
	$$PWD/src/wpp/qt/Map.h \
	$$PWD/src/wpp/qt/PermissionDeniedException.h \
	$$PWD/src/wpp/qt/ReadAddressBookPermissionDeniedException.h \
	$$PWD/src/wpp/qt/AddressBookContact.h \
	$$PWD/src/wpp/qt/AddressBookContactPhone.h \
	$$PWD/src/wpp/qt/AddressBookContactEmail.h \
	$$PWD/src/wpp/qt/AddressBookReader.h \
	$$PWD/src/wpp/qt/AddressBookObjC.h \
	$$PWD/src/wpp/qt/AbstractBaseController.h \
	$$PWD/src/wpp/qt/AbstractMainController.h \
	$$PWD/src/wpp/qt/PhotoCaptureController.h \
	$$PWD/src/wpp/qt/CaptureImageProvider.h \
        $$PWD/src/wpp/qt/Gallery.h \
        $$PWD/src/wpp/qt/GalleryFolder.h \
		$$PWD/src/wpp/qt/GalleryPhoto.h \
	$$PWD/src/wpp/qt/NativeCamera.h \
	$$PWD/src/wpp/qt/ImagePicker.h \
		$$PWD/src/wpp/qt/NativeMap.h \
	$$PWD/src/wpp/qt/NativeDateTimePicker.h \
	$$PWD/src/wpp/qt/IOSTimeZonePicker.h \
	$$PWD/src/wpp/qt/QObjectStarList.h

android {
	SOURCES += \
		$$PWD/wpp-android/jni/wpp_android_DatePickerDialog.cpp
	HEADERS += \
		$$PWD/wpp-android/jni/wpp_android_DatePickerDialog.h
}

ios {
QMAKE_CFLAGS += -fobjc-arc #enable ARC, flags to clang
QMAKE_CXXFLAGS += -fobjc-arc #enable ARC, flags to clang++
OBJECTIVE_SOURCES += \
	$$PWD/src/wpp/qt/AddressBookObjC.mm  \
	$$PWD/src/wpp/qt/AddressBookReader.mm \
	$$PWD/src/wpp/qt/NativeCamera.mm \
	$$PWD/src/wpp/qt/ImagePicker.mm \
	$$PWD/src/wpp/qt/NativeMap.mm \
        $$PWD/src/wpp/qt/System.mm \
		$$PWD/src/wpp/qt/GeoPosition.mm \
		$$PWD/src/wpp/qt/IOS.mm \
	$$PWD/src/wpp/qt/NativeDateTimePicker.mm \
	$$PWD/src/wpp/qt/IOSTimeZonePicker.mm \
	$$PWD/src/wpp/qt/QIOSViewController+Rotate.mm

OBJECTIVE_HEADERS += \
	$$PWD/src/wpp/qt/AddressBookObjC.h
HEADERS += \
		$$PWD/src/wpp/qt/IOS.h \
	$$PWD/src/wpp/qt/QIOSViewController+Rotate.h


LIBS += -framework AddressBook -framework MapKit \
	-framework AssetsLibrary -framework MobileCoreServices #required by ELCImagePickerController
}

OTHER_FILES += \
	$$PWD/identified-modules/wpp/qt/qml/AbstractMain.qml \
	$$PWD/identified-modules/wpp/qt/qml/RotatableRectangle.qml \
	$$PWD/identified-modules/wpp/qt/qml/Avatar.qml \
	$$PWD/identified-modules/wpp/qt/qml/Avatars.qml \
	$$PWD/identified-modules/wpp/qt/qml/CircleImageMask.qml \
	$$PWD/identified-modules/wpp/qt/qml/DateTime.qml \
	$$PWD/identified-modules/wpp/qt/qml/Dialog.qml \
	$$PWD/identified-modules/wpp/qt/qml/HSlides.qml \
	$$PWD/identified-modules/wpp/qt/qml/Hyperlink.qml \
	$$PWD/identified-modules/wpp/qt/qml/ImageBackground.qml \
	$$PWD/identified-modules/wpp/qt/qml/KTextArea.qml \
	$$PWD/identified-modules/wpp/qt/qml/Line.qml \
	$$PWD/identified-modules/wpp/qt/qml/ListViewDialog.qml \
	$$PWD/identified-modules/wpp/qt/qml/Map.qml \
	$$PWD/identified-modules/wpp/qt/qml/JSMap.qml \
	$$PWD/identified-modules/wpp/qt/qml/WebViewJSMap.qml \
	$$PWD/identified-modules/wpp/qt/qml/StaticImageMap.qml \
	$$PWD/identified-modules/wpp/qt/qml/Overlay.qml \
	$$PWD/identified-modules/wpp/qt/qml/RoundedImage.qml \
	$$PWD/identified-modules/wpp/qt/qml/SelectionList.qml \
	$$PWD/identified-modules/wpp/qt/qml/Spinner.qml \
	$$PWD/identified-modules/wpp/qt/qml/Tab.qml \
	$$PWD/identified-modules/wpp/qt/qml/WppTabView.qml \
	$$PWD/identified-modules/wpp/qt/qml/TextField.qml \
	$$PWD/identified-modules/wpp/qt/qml/SearchField.qml \
	$$PWD/identified-modules/wpp/qt/qml/AddressBookUI.qml \
	$$PWD/identified-modules/wpp/qt/qml/TitleBar.qml \
	$$PWD/identified-modules/wpp/qt/qml/TitleBarIcon.qml \
	$$PWD/identified-modules/wpp/qt/qml/TitleBarBackIcon.qml \
	$$PWD/identified-modules/wpp/qt/qml/TitleBarNextIcon.qml  \
	$$PWD/identified-modules/wpp/qt/qml/Modal.qml \
	$$PWD/identified-modules/wpp/qt/qml/LoadingModal.qml \
	$$PWD/identified-modules/wpp/qt/qml/LoadingIcon.qml \
	$$PWD/identified-modules/wpp/qt/qml/TitleBarButton.qml \
	$$PWD/identified-modules/wpp/qt/qml/SelectionListModal.qml \
	$$PWD/identified-modules/wpp/qt/qml/SelectionListView.qml \
	$$PWD/identified-modules/wpp/qt/qml/LocalAlbumBrowse.qml \
	$$PWD/identified-modules/wpp/qt/qml/SelectPhotoSourceModal.qml \
	$$PWD/identified-modules/wpp/qt/qml/TakePhotoUI.qml \
	$$PWD/identified-modules/wpp/qt/qml/CropImage.qml \
	$$PWD/identified-modules/wpp/qt/qml/PhotoCaptureControls.qml \
	$$PWD/identified-modules/wpp/qt/qml/DownloadUpdateUI.qml \
	$$PWD/identified-modules/wpp/qt/qml/ThickCursor.qml \
	$$PWD/identified-modules/wpp/qt/qml/ComposeUI.qml \
	$$PWD/identified-modules/wpp/qt/qml/DetectLocationUI.qml \
	$$PWD/identified-modules/wpp/qt/qml/AttachPhotoUI.qml \
	$$PWD/identified-modules/wpp/qt/qml/SmileysUI.qml \
	$$PWD/identified-modules/wpp/qt/qml/AtUserTab.qml \
	$$PWD/identified-modules/wpp/qt/qml/SwitchButton.qml \
	$$PWD/identified-modules/wpp/qt/qml/TestSelectionListView.qml \
	$$PWD/identified-modules/wpp/qt/qml/TimezoneModel.qml \
	$$PWD/identified-modules/wpp/qt/qml/TimezoneControl.qml \
	$$PWD/identified-modules/wpp/qt/qml/DateTimeControl.qml

RESOURCES += $$PWD/wpp.qrc


###### ELCImagePickerController #######
ios {
INCLUDEPATH += $$PWD/ELCImagePickerController/Classes/
OBJECTIVE_SOURCES += \
	$$PWD/ELCImagePickerController/Classes/ELCImagePicker/ELCAlbumPickerController.m \
	$$PWD/ELCImagePickerController/Classes/ELCImagePicker/ELCAsset.m \
	$$PWD/ELCImagePickerController/Classes/ELCImagePicker/ELCAssetCell.m \
	$$PWD/ELCImagePickerController/Classes/ELCImagePicker/ELCAssetTablePicker.m \
	$$PWD/ELCImagePickerController/Classes/ELCImagePicker/ELCConsole.m \
	$$PWD/ELCImagePickerController/Classes/ELCImagePicker/ELCImagePickerController.m \
	$$PWD/ELCImagePickerController/Classes/ELCImagePicker/ELCOverlayImageView.m
OBJECTIVE_HEADERS += \
	$$PWD/ELCImagePickerController/Classes/ELCImagePicker/ELCAlbumPickerController.h \
	$$PWD/ELCImagePickerController/Classes/ELCImagePicker/ELCAssetTablePicker.h \
	$$PWD/ELCImagePickerController/Classes/ELCImagePicker/ELCAsset.h \
	$$PWD/ELCImagePickerController/Classes/ELCImagePicker/ELCConsole.h \
	$$PWD/ELCImagePickerController/Classes/ELCImagePicker/ELCAssetCell.h \
	$$PWD/ELCImagePickerController/Classes/ELCImagePicker/ELCImagePickerController.h \
	$$PWD/ELCImagePickerController/Classes/ELCImagePicker/ELCAssetPickerFilterDelegate.h \
	$$PWD/ELCImagePickerController/Classes/ELCImagePicker/ELCImagePickerHeader.h \
	$$PWD/ELCImagePickerController/Classes/ELCImagePicker/ELCAssetSelectionDelegate.h \
	$$PWD/ELCImagePickerController/Classes/ELCImagePicker/ELCOverlayImageView.h
}
###### ActionSheetPicker-3.0 #######
ios {
INCLUDEPATH += $$PWD/ActionSheetPicker-3.0/CoreActionSheetPicker/ $$PWD/ActionSheetPicker-3.0/Pickers/ \
	$$PWD/ActionSheetPicker-3.0/ObjC-Example/Example/Classes/ \
	$$PWD/ActionSheetPicker-3.0/Example-for-iOS-7-and-6/Example/Classes/
OBJECTIVE_SOURCES += \
	$$PWD/ActionSheetPicker-3.0/Pickers/AbstractActionSheetPicker.m	\
	$$PWD/ActionSheetPicker-3.0/Pickers/ActionSheetLocalePicker.m \
	$$PWD/ActionSheetPicker-3.0/Pickers/ActionSheetCustomPicker.m \
	$$PWD/ActionSheetPicker-3.0/Pickers/ActionSheetStringPicker.m \
	$$PWD/ActionSheetPicker-3.0/Pickers/ActionSheetDatePicker.m	\
	$$PWD/ActionSheetPicker-3.0/Pickers/DistancePickerView.m \
	$$PWD/ActionSheetPicker-3.0/Pickers/ActionSheetDistancePicker.m	\
	$$PWD/ActionSheetPicker-3.0/Pickers/SWActionSheet.m \
	$$PWD/ActionSheetPicker-3.0/ObjC-Example/Example/Classes/NSDate+TCUtils.m \
	$$PWD/"ActionSheetPicker-3.0/Example Projects/Example-for-iOS-7-and-6/Example/Classes/NSDate+TCUtils.m"
OBJECTIVE_HEADERS += \
	$$PWD/ActionSheetPicker-3.0/Pickers/AbstractActionSheetPicker.h	\
	$$PWD/ActionSheetPicker-3.0/Pickers/ActionSheetLocalePicker.h \
	$$PWD/ActionSheetPicker-3.0/Pickers/ActionSheetCustomPicker.h \
	$$PWD/ActionSheetPicker-3.0/Pickers/ActionSheetPicker.h \
	$$PWD/ActionSheetPicker-3.0/Pickers/ActionSheetCustomPickerDelegate.h \
	$$PWD/ActionSheetPicker-3.0/Pickers/ActionSheetStringPicker.h \
	$$PWD/ActionSheetPicker-3.0/Pickers/ActionSheetDatePicker.h	\
	$$PWD/ActionSheetPicker-3.0/Pickers/DistancePickerView.h \
	$$PWD/ActionSheetPicker-3.0/Pickers/ActionSheetDistancePicker.h	\
	$$PWD/ActionSheetPicker-3.0/Pickers/SWActionSheet.h \
	$$PWD/ActionSheetPicker-3.0/ObjC-Example/Example/Classes/NSDate+TCUtils.h \
	$$PWD/"ActionSheetPicker-3.0/Example Projects/Example-for-iOS-7-and-6/Example/Classes/NSDate+TCUtils.h"
}

#QML_INFRA_FILES = qmldir
QML_IMPORT_PATH += $$PWD/identified-modules #to read qmldir files
#QML2_IMPORT_PATH += $$PWD/qmldir
