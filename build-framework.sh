#!/bin/sh

PROJECT_NAME='KS3YunSDK'
SRCROOT='.'

#sdk包输出目录
OUTPUT_DIR=${SRCROOT}/Framework/StaticFramework/${PROJECT_NAME}.framework
#OUTPUT_DIR=${SRCROOT}/Framework/DynamicFramework/${PROJECT_NAME}.framework

WORKING_DIR=${SRCROOT}/KS3SDKIOS/KS3YunSDK/build
# 编译目录
DEVICE_DIR=${WORKING_DIR}/Release-iphoneos/${PROJECT_NAME}.framework
SIMULATOR_DIR=${WORKING_DIR}/Release-iphonesimulator/${PROJECT_NAME}.framework

cd ${SRCROOT}/KS3SDKIOS/KS3YunSDK
xcodebuild -configuration "Release" -target "${PROJECT_NAME}" -sdk iphoneos clean build
xcodebuild -configuration "Release" -target "${PROJECT_NAME}" -sdk iphonesimulator clean build
cd ../..

if [ -d "${OUTPUT_DIR}" ]
then 
	rm -rf "${OUTPUT_DIR}"
fi

cp -R "${DEVICE_DIR}" "${OUTPUT_DIR}"

lipo -create "${DEVICE_DIR}/${PROJECT_NAME}" "${SIMULATOR_DIR}/${PROJECT_NAME}" -output "${OUTPUT_DIR}/${PROJECT_NAME}"

rm -r "${WORKING_DIR}"

if [ -d "${OUTPUT_DIR}/_CodeSignature" ]
then
    rm -rf "${OUTPUT_DIR}/_CodeSignature"
fi

if [ -f "${OUTPUT_DIR}/Info.plist" ]
then
    rm "${OUTPUT_DIR}/Info.plist"
fi
