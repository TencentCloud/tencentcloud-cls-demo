#!/bin/sh
BIN_OUTPUT_DIRECTORY=`pwd`

APPLICATION_NAME="TencentCloundLogProducer"
SCHEME="TencentCloundLogProducer"
# SCHEME_TV="KSCrash_static_tvos"
WORKSPACE="TencentCloundLogProducer.xcodeproj"
PROJECT_BUILDDIR="./build"
# PROJECT_BUILDDIR="${BIN_OUTPUT_DIRECTORY}/build"

rm -rf ${PROJECT_BUILDDIR}

xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk iphoneos clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphoneos"
xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME} -configuration Release -sdk iphonesimulator clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/iphonesimulator"
# xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME_TV} -configuration Release -sdk appletvos clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/appletvos"
# xcodebuild OTHER_CFLAGS="-fembed-bitcode"  -project ${WORKSPACE} -scheme ${SCHEME_TV} -configuration Release -sdk appletvsimulator clean build CONFIGURATION_BUILD_DIR="${PROJECT_BUILDDIR}/appletvsimulator"

cd ./${PROJECT_BUILDDIR}
rm -rf iphoneos/TencentCloundLogProducer.framework/PrivateHeaders
rm -rf iphoneos/TencentCloundLogProducer.framework/Modules
rm -rf iphoneos/TencentCloundLogProducer.framework/_CodeSignature
rm -rf iphonesimulator/TencentCloundLogProducer.framework/PrivateHeaders
rm -rf iphonesimulator/TencentCloundLogProducer.framework/Modules
rm -rf iphonesimulator/TencentCloundLogProducer.framework/_CodeSignature

cp -r iphoneos/TencentCloundLogProducer.framework ./

lipo -remove arm64 ./iphonesimulator/TencentCloundLogProducer.framework/TencentCloundLogProducer -output ./iphonesimulator/TencentCloundLogProducer.framework/TencentCloundLogProducer
lipo -create iphoneos/TencentCloundLogProducer.framework/TencentCloundLogProducer iphonesimulator/TencentCloundLogProducer.framework/TencentCloundLogProducer -output TencentCloundLogProducer.framework/TencentCloundLogProducer

open .

