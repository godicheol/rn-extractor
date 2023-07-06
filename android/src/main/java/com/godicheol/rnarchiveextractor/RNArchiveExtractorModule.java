package com.godicheol.rnarchiveextractor;


import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import net.lingala.zip4j.ZipFile;
import net.lingala.zip4j.exception.ZipException;

import com.github.junrar.Archive;
import com.github.junrar.Junrar;
import com.github.junrar.exception.RarException;

import com.hzy.libp7zip.P7ZipApi;

import android.graphics.Bitmap;
import android.graphics.pdf.PdfRenderer;
import android.graphics.pdf.PdfRenderer.Page;
import android.os.ParcelFileDescriptor;

public class RNArchiveExtractorModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    public RNArchiveExtractorModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNArchiveExtractor";
    }

    @ReactMethod
    public void isProtectedZip(final String srcPath, Promise promise) {
        try {
            ZipFile zipFile = new ZipFile(srcPath);
            promise.resolve(zipFile.isEncrypted());
        } catch(ZipException e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void extractZip(final String srcPath, final String destPath, Promise promise) {
        try {
            ZipFile zipFile = new ZipFile(srcPath);
            zipFile.extractAll(destPath);
            promise.resolve(null);
        } catch(Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void extractZipWithPassword(final String srcPath, final String destPath, final String password, Promise promise) {
        try {
            ZipFile zipFile = new ZipFile(srcPath, password.toCharArray());
            zipFile.extractAll(destPath);
            promise.resolve(null);
        } catch(Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void isProtectedRar(final String srcPath, Promise promise) {
        try {
            Archive rarFile = new Archive(new File(srcPath));
            promise.resolve(rarFile.isEncrypted());
        } catch(RarException e) {
            promise.reject(e);
        } catch(IOException e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void extractRar(final String srcPath, final String destPath, Promise promise) {
        try {
            File rarFile = new File(srcPath);
            File destFolder = new File(destPath);
            Junrar.extract(rarFile, destFolder);
            promise.resolve(null);
        } catch(Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void extractRarWithPassword(final String srcPath, final String destPath, final String password, Promise promise) {
        try {
            File rarFile = new File(srcPath);
            File destFolder = new File(destPath);
            Junrar.extract(rarFile, destFolder, password);
            promise.resolve(null);
        } catch(Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void extractSevenZip(final String srcPath, final String destPath, Promise promise) {
        try {
            File srcFile = new File(srcPath);
            File destFolder = new File(destPath);
            String command = String.format("7z x '%s' '-o%s' -aoa", srcFile.getAbsolutePath(), destFolder.getAbsolutePath());
            int result = P7ZipApi.executeCommand(command);
            if (result == 2){
                throw new Exception("Wrong password.");
            }
            promise.resolve(null);
        } catch(Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void extractSevenZipWithPassword(final String srcPath, final String destPath, final String password, Promise promise) {
        try {
            File srcFile = new File(srcPath);
            File destFolder = new File(destPath);
            String command = String.format("7z x '%s' '-o%s' '-p%s' -aoa", srcFile.getAbsolutePath(), destFolder.getAbsolutePath(), password);
            int result = P7ZipApi.executeCommand(command);
            if (result == 2){
                throw new Exception("Wrong password.");
            }
            promise.resolve(null);
        } catch(Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void isProtectedPdf(final String srcPath, Promise promise) {
        try {
            File srcFile = new File(srcPath);
            if (!srcFile.exists()) {
                throw new Exception("File not found");
            }
            ParcelFileDescriptor parcelFileDescriptor = ParcelFileDescriptor.open(srcFile, ParcelFileDescriptor.MODE_READ_ONLY);
            PdfRenderer renderer = new PdfRenderer(parcelFileDescriptor);
            promise.resolve(false);
        } catch(SecurityException e) {
            promise.resolve(true);
        } catch(IOException e) {
            promise.reject(e);
        } catch(Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void extractPdf(final String srcPath, final String destPath, Promise promise) {
        try {
            int quality = 100;
            File srcFile = new File(srcPath);
            if (!srcFile.exists()) {
                throw new Exception("File not found");
            }
            ParcelFileDescriptor parcelFileDescriptor = ParcelFileDescriptor.open(srcFile, ParcelFileDescriptor.MODE_READ_ONLY);
            // create a new renderer
            PdfRenderer renderer = new PdfRenderer(parcelFileDescriptor);
            // let us just render all pages
            final int pageCount = renderer.getPageCount();
            // check exists
            for (int i = 0; i < pageCount; i++) {
                String path = destPath + "/" + String.valueOf(i) + ".jpg";
                File file = new File(path);
                if (file.exists()) {
                    throw new Exception("File already exists");
                }
            }
            // extract
            FileOutputStream fos = null;
            try {
                for (int i = 0; i < pageCount; i++) {
                    String path = destPath + "/" + String.valueOf(i) + ".jpg";
                    Page page = renderer.openPage(i);
                    int pageWidth = page.getWidth();
                    int pageHeight = page.getHeight();
                    Bitmap bitmap = Bitmap.createBitmap(
                        pageWidth,
                        pageHeight,
                        Bitmap.Config.ARGB_8888);
                    // say we render for showing on the screen
                    page.render(
                        bitmap,
                        null,
                        null,
                        Page.RENDER_MODE_FOR_DISPLAY);
                    // do stuff with the bitmap
                    File file = new File(path);
                    fos = new FileOutputStream(file);
                    // compress to jpeg
                    bitmap.compress(Bitmap.CompressFormat.JPEG, quality, fos);
                    // close the page
                    page.close();
                }
            } catch(Exception e) {
                promise.reject(e);
            } finally {
                // close the renderer
                renderer.close();
                promise.resolve(null);
            }
        } catch(IOException err) {
            promise.reject(err);
        } catch(Exception err) {
            promise.reject(err);
        }
    }
}
