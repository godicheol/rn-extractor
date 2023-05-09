//
//  RNExtractor.m
//  RNExtractor
//
//  Created by Icheol on 2023/04/23.
//  Copyright © 2023 Facebook. All rights reserved.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RNExtractor, NSObject)

RCT_EXTERN__BLOCKING_SYNCHRONOUS_METHOD(getName)

RCT_EXTERN_METHOD(
    isProtectedZip:(NSString *)srcPath
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    extractZip:(NSString *)srcPath
    destinationPath:(NSString *)destPath
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    extractZipWithPassword:(NSString *)srcPath
    destinationPath:(NSString *)destPath
    withPassword:(NSString *)password
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    isProtectedRar:(NSString *)srcPath
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    extractRar:(NSString *)srcPath
    destinationPath:(NSString *)destPath
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    extractRarWithPassword:(NSString *)srcPath
    destinationPath:(NSString *)destPath
    withPassword:(NSString *)password
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject
)

// RCT_EXTERN_METHOD(
//     isProtectedSevenZip:(NSString *)srcPath
//     resolver:(RCTPromiseResolveBlock)resolve
//     rejecter:(RCTPromiseRejectBlock)reject
// )

RCT_EXTERN_METHOD(
    extractSevenZip:(NSString *)srcPath
    destinationPath:(NSString *)destPath
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    extractSevenZipWithPassword:(NSString *)srcPath
    destinationPath:(NSString *)destPath
    withPassword:(NSString *)password
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    isProtectedPdf:(NSString *)srcPath
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    extractPdf:(NSString *)srcPath
    destinationPath:(NSString *)destPath
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    extractPdfWithPassword:(NSString *)srcPath
    destinationPath:(NSString *)destPath
    withPassword:(NSString *)password
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject
)

@end
