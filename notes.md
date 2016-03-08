## Notes

http://stackoverflow.com/questions/27496055/getting-file-not-found-in-bridging-header-when-importing-objective-c-framework


http://www.sunsetlakesoftware.com/2014/06/30/exploring-swift-using-gpuimage
http://stackoverflow.com/questions/25538579/use-cocoapods-with-an-app-extension



http://stackoverflow.com/questions/25414404/how-to-bundle-cocoapod-dependencies-with-cordova-plugin
https://github.com/xdissent/cocoapods-cordova

Size/Resolution 
https://en.wikipedia.org/wiki/Common_Intermediate_Format

// AVCaptureVideoOrientationLandscapeRight
// .LandscapeRight
// self.videoCamera.setInputRotation(.GPUImageRotateRight, atIndex:0)

// WORKS
// let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: array.map({"\($0)"}).joinWithSeparator(","))

// let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: "Hey hey h!!!!!ey!") // buffer
// This seems like it would work, but for `Cannot convert value of type '[UInt8]' to expected argument type '[AnyObject]!'`
// let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsArray: array) // or buffer or data



// http://stackoverflow.com/a/24516400/83859
var count = data.length / sizeof(UInt8) // all should be uint8, but uint seems to work with anyobject? 
// print(self.destSize)
// print(count)
//405 504 with no filter
// 3920 with 35*28
// create array of appropriate length:
// var array = [UInt8](count: count, repeatedValue: 0) // but cordova wants AnyObject gah
// copy bytes into array
// data.getBytes(&array, length:count * sizeof(UInt8))
// print(array)
// Works!


//        https://github.com/BradLarson/GPUImage/blob/master/framework/Source/GPUImageLookupFilter.h
//        answer: http://stackoverflow.com/questions/33731637/how-to-create-gpuimage-lookup-png-resource
// But fuck that


This works, but I don't think it's neccesary. 

// self.lanczosResamplingFilter = GPUImageLanczosResamplingFilter()
// self.lanczosResamplingFilter?.forceProcessingAtSize(self.destSize!)
// self.videoCamera?.addTarget(self.lanczosResamplingFilter)
// self.lanczosResamplingFilter?.addTarget(self.output)
// self.videoCamera?.startCameraCapture()
