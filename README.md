## Installation

```console
cd ios && pod install
```

```swift
// /react-native/ios/Podfile
...
target <TARGET_NAME> do {
    ...
    pod "UnrarKit", :modular_headers => true // add this line
    ...
}
```

```js
import RNE from 'rn-extractor';
```

## Usage

```js

const srcPath = "archive path";
const destPath = "directory path";

// zip
await RNE.isProtectedZip(srcPath); // return boolean
await RNE.extractZip(srcPath, destPath); // return undefined
await RNE.extractZipWithPassword(srcPath, destPath, password); // return undefined
// rar
await RNE.isProtectedRar(srcPath); // return boolean
await RNE.extractRar(srcPath, destPath); // return undefined
await RNE.extractRarWithPassword(srcPath, destPath, password); // return undefined
// 7z
await RNE.extractSevenZip(srcPath, destPath); // return undefined
await RNE.extractSevenZipWithPassword(srcPath, destPath, password); // return undefined
// pdf
await RNE.isProtectedPdf(srcPath); // return boolean
await RNE.extractPdf(srcPath, destPath); // return undefined
```

## Acknowledgements

- [zip4j](https://github.com/srikanth-lingala/zip4j)
- [junrar](https://github.com/junrar/junrar)
- [AndroidP7zip](https://github.com/hzy3774/AndroidP7zip)
- [UnrarKit](https://github.com/abbeycode/UnrarKit)
- [ZipArchive](https://github.com/ZipArchive/ZipArchive)
- [PLzmaSDK](https://github.com/OlehKulykov/PLzmaSDK)