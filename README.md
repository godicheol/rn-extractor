## Installation

```console
git clone https://github.com/godicheol/rn-archive-extractor

npm pack

npm install rn-archive-extractor-1.0.0.tgz
```

```console
cd ios && pod install
```

```swift
// /react-native/ios/Podfile
...
target '<ReactNativeApplication>' do {
    ...
    pod "UnrarKit", :modular_headers => true // add this line
    ...
}
```

```js
import RNAE from 'rn-archive-extractor';
```

## Usage

```js

const srcPath = "./foo.zip"; // archive path
const destPath = "./dest"; // directory path

// zip
await RNAE.isProtectedZip(srcPath); // return boolean
await RNAE.extractZip(srcPath, destPath); // return undefined
await RNAE.extractZipWithPassword(srcPath, destPath, password); // return undefined
// rar
await RNAE.isProtectedRar(srcPath); // return boolean
await RNAE.extractRar(srcPath, destPath); // return undefined
await RNAE.extractRarWithPassword(srcPath, destPath, password); // return undefined
// 7z
await RNAE.extractSevenZip(srcPath, destPath); // return undefined
await RNAE.extractSevenZipWithPassword(srcPath, destPath, password); // return undefined
// pdf
await RNAE.isProtectedPdf(srcPath); // return boolean
await RNAE.extractPdf(srcPath, destPath); // return undefined
```

## Acknowledgements

- [zip4j](https://github.com/srikanth-lingala/zip4j)
- [junrar](https://github.com/junrar/junrar)
- [AndroidP7zip](https://github.com/hzy3774/AndroidP7zip)
- [UnrarKit](https://github.com/abbeycode/UnrarKit)
- [ZipArchive](https://github.com/ZipArchive/ZipArchive)
- [PLzmaSDK](https://github.com/OlehKulykov/PLzmaSDK)