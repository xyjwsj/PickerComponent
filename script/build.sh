#! bin/sh

PROJECT_DIR=/Users/hoolai/Documents/macProject/ImagePickerComponent
BUILD_OUTSDK_DIR=${PROJECT_DIR}/OUTSDK/BUILD_DIR
BUILD_HEADER_DIR=${PROJECT_DIR}/OUTSDK/HEADER_DIR

SDK_OUT_DIR=${PROJECT_DIR}/OUTSDK/SDK

TARGET_REF_DIR=/Users/hoolai/Documents/accesssdk/access_service/sdk


check(){
 if [ $? -ne 0 ];then
 	echo '\033[0;31;1m===============================================================================\033[0m';
    echo '\033[0;31;1m=========================='"$1,执行失败"'=======================================\033[0m';
    echo '\033[0;31;1m===============================================================================\033[0m';
    exit 1;
 fi
	echo '\033[0;32;1m===============================================================================\033[0m';
    echo '\033[0;32;1m=========================='"$1,执行成功"'=======================================\033[0m';
    echo '\033[0;32;1m===============================================================================\033[0m';
}

over_create_dir() {
    if [ -d $1 ];then
        rm -rf $1
    fi
    mkdir -p $1
}

copy_from_path_to_path() {
    array=(echo `find $1 -name $2`)
    for ((i=0; i<${#array[@]}; i++ ));
       do
          attr=(${array[$i]})
          echo $attr
          if [ "${attr}" = "echo" ];then
                continue
          fi
          cp $attr $3
      done
}

create_header() {

  file_name=$3
  file_path=${BUILD_HEADER_DIR}/$file_name

  if [ -f "$file_path" ];then
    rm -f $file_path
  fi

  touch $file_path

  echo $file_path

  echo "//" > ${file_path}
  echo "//  UISDK.h" >> ${file_path}
  echo "//  UISDK" >> ${file_path}
  echo "//" >> ${file_path}
  echo "//  Created by Hoolai on 16/8/31." >> ${file_path}
  echo "//  Copyright © 2016年 wushaojie. All rights reserved." >> ${file_path}
  echo "//" >> ${file_path}

  echo "#ifndef UISDK_h" >> ${file_path}
  echo "#define UISDK_h" >> ${file_path}


  array_h=(echo `find $1 -name $2`)
    for ((j=0; j<${#array_h[@]}; j++ ));
       do
          attr_h=(${array_h[$j]})

          if [ "${attr_h}" = "echo" ];then
                continue
          fi
          h_name=${attr_h##*/}

          if [ "${h_name}" = "UISDK.h" ];then
                continue
          fi

          grep "#import \"${h_name}\"" ${file_path}
          if [ $? -ne 0 ];then

              echo "#import \"${h_name}\"" >> ${file_path}
          fi

      done

  echo "#endif /* UISDK_h */" >> ${file_path}
}

copy_header_file() {
	cp $PROJECT_DIR/"ImagePickerComponent/Classes/ImageSelectorBrowse(图片选择器,展示,删除)/Controller/HLImagePickerController.h" ${BUILD_HEADER_DIR}
	cp $PROJECT_DIR/"ImagePickerComponent/Classes/Other/Category/"*.h ${BUILD_HEADER_DIR}
	cp $PROJECT_DIR/"ImagePickerComponent/Classes/Other/HLSharedData.h" ${BUILD_HEADER_DIR}
}

build_target(){
     cd $PROJECT_DIR
     xcodebuild -scheme $1 -sdk iphonesimulator -configuration Release clean build SYMROOT="$BUILD_OUTSDK_DIR" -destination 'platform=iOS Simulator,name=iPhone 6'
     check "模拟器编译"
     xcodebuild -scheme $1 -sdk iphoneos -configuration Release clean build SYMROOT="$BUILD_OUTSDK_DIR"
     check "真机编译"
}

pack_framework() {
    over_create_dir $SDK_OUT_DIR/$1.framework/Headers
    lipo -create -o $SDK_OUT_DIR/$1.framework/$1 $BUILD_OUTSDK_DIR/Release-iphoneos/lib$1.a $BUILD_OUTSDK_DIR/Release-iphonesimulator/lib$1.a
    copy_from_path_to_path $BUILD_HEADER_DIR "*.h" $SDK_OUT_DIR/$1.framework/Headers

   	over_create_dir $TARGET_REF_DIR/$1.framework
   	cp -r $SDK_OUT_DIR/$1.framework/* $TARGET_REF_DIR/$1.framework
}

over_create_dir ${BUILD_HEADER_DIR}

copy_header_file

create_header $BUILD_HEADER_DIR '*.h' "UISDK.h"

over_create_dir ${BUILD_OUTSDK_DIR}
over_create_dir ${SDK_OUT_DIR}

build_target $1

pack_framework $1


