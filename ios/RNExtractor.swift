//
//  RNExtractor.swift
//  RNExtractor
//
//  Created by Icheol on 2023/04/23.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation
import SSZipArchive
import UIKit
import UnrarKit
import PLzmaSDK
import PDFKit

enum ExtractError: Error {
    case extract
    case srcNotFound
    case destNotFound
    case destExists
    case error
}

extension ExtractError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .extract:
            return NSLocalizedString(
                "A problem occurred while extracting the archive", 
                comment: "Extract Error"
            )
        case .srcNotFound:
            return NSLocalizedString(
                "Source not found.", 
                comment: "File Not Found"
            )
        case .destNotFound:
            return NSLocalizedString(
                "Destination file not found.", 
                comment: "Directory Not Found"
            )
        case .destExists:
            return NSLocalizedString(
                "File already exists.", 
                comment: "Exists Error"
            )
        case .error:
            return NSLocalizedString(
                "Occurred error", 
                comment: "Occurred Error"
            )
        }
    }
}

class ZipExtractor {
    static func extract(
        _ srcPath: String,
        destinationPath destPath: String,
        withPassword password: String? = nil
    ) throws {
        let srcUrlString = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let destUrlString = destPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        var error: NSError?
        
        let success: Bool = SSZipArchive.unzipFile(
            atPath: srcUrlString,
            toDestination: destUrlString,
            preserveAttributes: true,
            overwrite: false,
            password: password,
            error: &error,
            delegate: nil
        )
        
        if let error = error {
            throw error
        }

        if !success {
            throw ExtractError.extract
        }
    }

    static func isProtected(
        _ srcPath: String
    ) throws -> Bool {
        let srcUrlString = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let isProtected = SSZipArchive.isFilePasswordProtected(atPath: srcUrlString)
        return isProtected
    }
}

class RarExtractor {
    static func extract(
        _ srcPath: String,
        destinationPath destPath: String,
        withPassword password: String? = nil
    ) throws {
        let srcUrlString = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let destUrlString = destPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let archive = try URKArchive(path: srcUrlString)
        
        if let password = password {
            archive.password = password
        }
        
        try archive.extractFiles(
            to: destUrlString,
            overwrite: false
        )
    }

    static func isProtected(
        _ srcPath: String
    ) throws -> Bool {
        let srcUrlString = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let archive = try URKArchive(path: srcUrlString)
        return archive.isPasswordProtected()
    }
}

class SevenZipExtractor {
    static func extract(
        _ srcPath: String,
        destinationPath destPath: String,
        withPassword password: String? = nil
    ) throws {
        let srcUrlString = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let destUrlString = destPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        // 1. Create a source input stream for reading archive file content.
        //  1.1. Create a source input stream with the path to an archive file.
        let archivePath = try Path(srcUrlString)
        let archivePathInStream = try InStream(path: archivePath)

        //  1.2. Create a source input stream with the file content.
        // let archiveData = Data(...)
        // let archiveData = try Data(contentsOf:URL(string: srcPath)!)
        // let archiveDataInStream = try InStream(dataNoCopy: archiveData) // also available Data(dataCopy: Data)

        // 2. Create decoder with source input stream, type of archive and optional delegate.
        let decoder = try Decoder(stream: archivePathInStream, fileType: .sevenZ, delegate: nil)
        
        //  2.1. Optionaly provide the password to open/list/test/extract encrypted archive items.
        try decoder.setPassword(password)
        
        // let opened = try decoder.open()
        _ = try decoder.open()
        
        // 3. Select archive items for extracting or testing.
        //  3.1. Select all archive items.
        // let allArchiveItems = try decoder.items()
        // try decoder.items()
        
        //  3.2. Get the number of items, iterate items by index, filter and select items.
        // let numberOfArchiveItems = try decoder.count()
        // let selectedItemsDuringIteration = try ItemArray(capacity: numberOfArchiveItems)
        // let selectedItemsToStreams = try ItemOutStreamArray()
        // for itemIndex in 0..<numberOfArchiveItems {
        //     let item = try decoder.item(at: itemIndex)
        //     try selectedItemsDuringIteration.add(item: item)
        //     try selectedItemsToStreams.add(item: item, stream: OutStream()) // to memory stream
        // }
        
        // 4. Extract or test selected archive items. The extract process might be:
        //  4.1. Extract all items to a directory. In this case, you can skip the step #3.
        // let extracted = try decoder.extract(to: Path(destPath))
        _ = try decoder.extract(to: Path(destUrlString))
        
        //  4.2. Extract selected items to a directory.
        // let extracted = try decoder.extract(items: selectedItemsDuringIteration, to: Path(destinationPath))
        
        //  4.3. Extract each item to a custom out-stream. 
        //       The out-stream might be a file or memory. I.e. extract 'item #1' to a file stream, extract 'item #2' to a memory stream(then take extacted memory) and so on.
        // let extracted = try decoder.extract(itemsToStreams: selectedItemsToStreams)
    }

    // static func isProtected(
    //     _ srcPath: String
    // ) -> Bool {
    //     return false
    // }
}

class PdfExtractor {
    static func extractPage(
        _ pdfPage: PDFPage,
        destinationPath destPath: String,
        withPage page: Int,
        withQuality quality: Int
    ) throws -> Void {
        let pageBoundingRect = pdfPage.bounds(for: .mediaBox) 
        let image = pdfPage.thumbnail(of: CGSize(width: pageBoundingRect.width, height: pageBoundingRect.height), for: .mediaBox)
        let fileName = "\(page).jpg"
        let destUrl = URL(string: "file://\(destPath)/\(fileName)")!
        guard let data = image.jpegData(compressionQuality: CGFloat(quality) / 100) else {
            throw ExtractError.extract
        }
        try data.write(to: destUrl)
    }

    static func extract(
        _ srcPath: String,
        destinationPath destPath: String,
        withQuality quality: Int,
        withPassword password: String? = nil
    ) throws -> Void {
        let srcUrlString = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let destUrlString = destPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let srcUrl = URL(string: "file://\(srcUrlString)") else {
            throw ExtractError.srcNotFound
        }
        guard let destUrl = URL(string: destUrlString) else {
            throw ExtractError.destNotFound
        }
        guard let pdfDocument = PDFDocument(url: srcUrl) else {
            throw ExtractError.srcNotFound
        }
        if let password = password {
            pdfDocument.unlock(withPassword: password)
        }
        // check file name
        for page in 0..<pdfDocument.pageCount {
            let fileName = "\(page).jpg"
            if FileManager.default.fileExists(atPath: "\(srcUrl.absoluteString)/\(fileName)") {
                throw ExtractError.destExists
            }
        }
        // extract
        for page in 0..<pdfDocument.pageCount {
            guard let pdfPage = pdfDocument.page(at: page) else {
                throw ExtractError.extract
            }
            do {
                try extractPage(pdfPage, destinationPath: destUrlString, withPage: page, withQuality: quality) 
            } catch {
                throw error
            }
        }
    }

    static func isProtected(
        _ srcPath: String
    ) throws -> Bool {
        let srcUrlString = srcPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let srcUrl = URL(string: "file://\(srcUrlString)") else {
            throw ExtractError.srcNotFound
        }
        guard let pdfDocument = PDFDocument(url: srcUrl) else {
            throw ExtractError.srcNotFound
        }
        if pdfDocument.isEncrypted {
            return true;
        }
        if pdfDocument.isLocked {
            return true;
        }
        return false;
    }
}

@objc(RNExtractor)
class RNExtractor: NSObject {

    @objc
    static func requiresMainQueueSetup() -> Bool {
        return false
    }

    @objc
    func getName() -> String {
        return "RNExtractor"
    }

    @objc
    func isProtectedZip(
        _ srcPath: String,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) {
        let isProtected = SSZipArchive.isFilePasswordProtected(atPath: srcPath)
        resolve(isProtected)
    }
    
    @objc
    func extractZip(
        _ srcPath: String,
        destinationPath destPath: String,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) {
        do {
            try ZipExtractor.extract(
                srcPath,
                destinationPath: destPath
            )
            resolve(nil)
        } catch {
            reject("ERROR", error.localizedDescription, error)
        }
    }
    
    @objc
    func extractZipWithPassword(
        _ srcPath: String,
        destinationPath destPath: String,
        withPassword password: String? = nil,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) {
        do {
            try ZipExtractor.extract(
                srcPath,
                destinationPath: destPath,
                withPassword: password
            )
            resolve(nil)
        } catch {
            reject("ERROR", error.localizedDescription, error)
        }
    }

    @objc
    func isProtectedRar(
        _ srcPath: String,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) {
        do {
            let isProtected = try RarExtractor.isProtected(srcPath)
            resolve(isProtected)
        } catch {
            reject("ERROR", error.localizedDescription, error)
        }
    }

    @objc
    func extractRar(
        _ srcPath: String,
        destinationPath destPath: String,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) {
        do {
            try RarExtractor.extract(
                srcPath,
                destinationPath: destPath
            )
            resolve(nil)
        } catch {
            reject("ERROR", error.localizedDescription, error)
        }
    }

    @objc
    func extractRarWithPassword(
        _ srcPath: String,
        destinationPath destPath: String,
        withPassword password: String? = nil,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) {
        do {
            try RarExtractor.extract(
                srcPath,
                destinationPath: destPath,
                withPassword: password
            )
            resolve(nil)
        } catch {
            reject("ERROR", error.localizedDescription, error)
        }
    }

    // @objc
    // func isProtectedSenvenZip(
    //     _ srcPath: String,
    //     resolver resolve: RCTPromiseResolveBlock,
    //     rejecter reject: RCTPromiseRejectBlock
    // ) {
    // }

    @objc
    func extractSevenZip(
        _ srcPath: String,
        destinationPath destPath: String,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) {
        do {
            try SevenZipExtractor.extract(
                srcPath,
                destinationPath: destPath
            )
            resolve(nil)
        } catch {
            reject("ERROR", error.localizedDescription, error)
        }
    }

    @objc
    func extractSevenZipWithPassword(
        _ srcPath: String,
        destinationPath destPath: String,
        withPassword password: String? = nil,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) {
        do {
            try SevenZipExtractor.extract(
                srcPath,
                destinationPath: destPath,
                withPassword: password
            )
            resolve(nil)
        } catch {
            reject("ERROR", error.localizedDescription, error)
        }
    }

    @available(iOS 11.0, *)
    @objc
    func isProtectedPdf(
        _ srcPath: String,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) {
        do {
            let isProtected = try PdfExtractor.isProtected(srcPath)
            resolve(isProtected)
        } catch {
            reject("ERROR", error.localizedDescription, error)
        }
    }

    @available(iOS 11.0, *)
    @objc
    func extractPdf(
        _ srcPath: String,
        destinationPath destPath: String,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) {
        do {
            try PdfExtractor.extract(
                srcPath,
                destinationPath: destPath,
                withQuality: 100
            )
            resolve(nil)
        } catch {
            reject("ERROR", error.localizedDescription, error)
        }
    }

    @available(iOS 11.0, *)
    @objc
    func extractPdfWithPassword(
        _ srcPath: String,
        destinationPath destPath: String,
        withPassword password: String? = nil,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) {
        do {
            try PdfExtractor.extract(
                srcPath,
                destinationPath: destPath,
                withQuality: 100,
                withPassword: password
            )
            resolve(nil)
        } catch {
            reject("ERROR", error.localizedDescription, error)
        }
    }
}
