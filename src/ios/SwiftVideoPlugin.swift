import Foundation

import GPUImage

// extension UInt8: AnyObject {
// }

// class My_UInt: UnsignedIntegerType, Comparable, Equatable {
//     // func areaSelected(view:UIView,points:NSArray)
// }


@objc(SwiftVideoPlugin) class SwiftVideoPlugin : CDVPlugin {
  var videoCamera:GPUImageVideoCamera?
  var filter:GPUImagePixellateFilter?
  var output:GPUImageRawDataOutput?
  var rawBytesForImage: UnsafeMutablePointer<GLubyte>? //UInt8
  var last_time = NSDate()

  var lanczosResamplingFilter: GPUImageLanczosResamplingFilter = GPUImageLanczosResamplingFilter()

  func sayHello(command: CDVInvokedUrlCommand) {
        self.videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset352x288, cameraPosition: .Back)
        self.videoCamera!.outputImageOrientation = .Portrait;

        self.lanczosResamplingFilter.forceProcessingAtSize(CGSizeMake(35, 28))

        // stillImageSource.addTarget(lanczosResamplingFilter)
        // lanczosResamplingFilter.useNextFrameForImageCapture()
        // stillImageSource.processImage()
        // var lanczosImage: UIImage = lanczosResamplingFilter.imageFromCurrentFramebuffer()


        // filter = GPUImagePixellateFilter()
        // videoCamera?.addTarget(filter)
        // videoCamera?.addTarget(filter)
        // filter?.addTarget(self.view as! GPUImageView)

//        Works
        // self.output = GPUImageRawDataOutput(imageSize: CGSizeMake(35, 28), resultsInBGRAFormat: true)
        self.output = GPUImageRawDataOutput(imageSize: CGSizeMake(352, 288), resultsInBGRAFormat: true)
//        this works too, slightly slower it seems? unlike guy says
//        output = MyRawDataOutput(imageSize: CGSizeMake(352, 288), resultsInBGRAFormat: true)

        self.output!.newFrameAvailableBlock = { () in
            let since_last = ((NSDate().timeIntervalSinceReferenceDate-self.last_time.timeIntervalSinceReferenceDate)*1000)
            if since_last > 2000 {
	            // print(since_last)
	            self.rawBytesForImage = self.output!.rawBytesForImage
	            // print("raw raw mem:")
	            // print(self.rawBytesForImage!.memory)
	            self.last_time = NSDate()
	           	// print(self.rawBytesForImage?.memory)
	            //http://stackoverflow.com/a/31109955/83859
	            // let buffer = UnsafeMutableBufferPointer(start: self.rawBytesForImage!, count: Int(352*288*4)) // also WORKS
	            // let array = [GLubyte](buffer)
	            // print(array[0], array[1])

	            // http://stackoverflow.com/questions/25997376/type-string-anyobject-does-not-conform-to-protocol-anyobject-why
	            // print(buffer[0], buffer[1], buffer[2])
	            // https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/TypeCasting.html

				var data = NSData(bytes: self.rawBytesForImage!, length: Int(352*288*4)) // also WORKS
				
				// http://stackoverflow.com/a/24516400/83859
				let count = data.length / sizeof(UInt8) // all should be uint8, but uint seems to work with anyobject? 
				// // create array of appropriate length:
				var array = [Any](count: count, repeatedValue: 0) // uint8
				// // copy bytes into array
				data.getBytes(&array, length:count * sizeof(UInt8))
				// array.joinWithSeparator("-")
				// print(array)

				// print(data.bytes.memory)
				// let ptr = UnsafePointer<UInt8>(data.bytes)

				// let data = NSData(bytes: self.rawBytesForImage!, length: Int(35*28*4)) // also WORKS
				print("frame")
				let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: "Hey hey h!!!!!ey!") // buffer
				// let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsArrayBuffer: &data) // or buffer or data
				// let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsArrayBuffer: data) // or buffer or data
				
				// let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsArray: array) // or buffer or data
				pluginResult.setKeepCallbackAsBool(true)
				self.commandDelegate?.sendPluginResult(pluginResult, callbackId:command.callbackId)
            }
        }
//        https://github.com/BradLarson/GPUImage/blob/master/framework/Source/GPUImageLookupFilter.h
//        answer: http://stackoverflow.com/questions/33731637/how-to-create-gpuimage-lookup-png-resource
        // self.videoCamera?.addTarget(self.lanczosResamplingFilter)
        self.videoCamera?.addTarget(self.output)
        self.videoCamera?.startCameraCapture()
        //            buffer.baseAddress.destroy(buffer.count)
        // 

	    // let message = "Hello !";
	    // let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: message);
	    // pluginResult.setKeepCallbackAsBool(true)
	    // self.commandDelegate?.sendPluginResult(pluginResult, callbackId:command.callbackId);

	    // let pluginResultTwo = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: "World!");
	    // // pluginResultTwo.setKeepCallbackAsBool(true) // this will cause it not to work,
	    // // if you set this true (again)
	    // // you need to then send another result after the one below
	    // self.commandDelegate?.sendPluginResult(pluginResultTwo, callbackId:command.callbackId);

  }
}


// http://stackoverflow.com/questions/25448976/how-to-write-cordova-plugin-in-swift
