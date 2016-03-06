import Foundation

import GPUImage


@objc(SwiftVideoPlugin) class SwiftVideoPlugin : CDVPlugin {
  var videoCamera:GPUImageVideoCamera?
  var filter:GPUImagePixellateFilter?
  var output:GPUImageRawDataOutput?
  var rawBytesForImage: UnsafeMutablePointer<GLubyte>? //UInt8
  var last_time = NSDate()
  var lanczosResamplingFilter:GPUImageLanczosResamplingFilter?
  var destSize:CGSize?

  func sayHello(command: CDVInvokedUrlCommand) {
  		self.commandDelegate?.runInBackground({() -> Void in

	        self.videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset352x288, cameraPosition: .Back)
	        self.videoCamera!.outputImageOrientation = .Portrait;
	        self.lanczosResamplingFilter = GPUImageLanczosResamplingFilter()
	        // self.destSize = CGSize(width: 352, height: 288)
	        self.destSize = CGSize(width: 352/2, height: 288/2)
	        // self.destSize = CGSize(width: 128, height: 96)
	        // 128 × 96 ? https://en.wikipedia.org/wiki/Common_Intermediate_Format
	        //  ????????????
	        // AVCaptureVideoOrientationLandscapeRight
	        // .LandscapeRight
	        // self.videoCamera.setInputRotation(.GPUImageRotateRight, atIndex:0)

	//        Works
	        // self.output = GPUImageRawDataOutput(imageSize: CGSizeMake(35, 28), resultsInBGRAFormat: true)
	        self.output = GPUImageRawDataOutput(imageSize: self.destSize!, resultsInBGRAFormat: true)
	        // self.output = GPUImageRawDataOutput(imageSize: self.size, resultsInBGRAFormat: true)

	        self.output!.newFrameAvailableBlock = { () in
	            let since_last = ((NSDate().timeIntervalSinceReferenceDate-self.last_time.timeIntervalSinceReferenceDate)*1000)
	            // 300 was good at 352, 2888
	            // 50 for "/2 "/2
	            // 0 at 128, 96
	            if since_last > 50 { 
		            // print(since_last)
		            self.rawBytesForImage = self.output!.rawBytesForImage
		            // print("raw raw mem:") // print(self.rawBytesForImage!.memory)
		            self.last_time = NSDate()
					// var data = NSData(bytes: self.rawBytesForImage!, length: Int(self.destSize.width*self.destSize.height*4)) 
					var data = NSData(bytes: self.rawBytesForImage!, length: Int(self.destSize!.width*self.destSize!.height*4)) 
					// var data = NSData(bytes: self.rawBytesForImage!, length: Int(35*28*4)) 
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
					// let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: array.map({"\($0)"}).joinWithSeparator(",")) // buffer
					// let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: "Hey hey h!!!!!ey!") // buffer
					// This seems like it would work, but for `Cannot convert value of type '[UInt8]' to expected argument type '[AnyObject]!'`
					// let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsArray: array) // or buffer or data

					
					// Works, need to use a DataView in JS! Hooray/duh.
					let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsArrayBuffer: data) // or buffer or data

					pluginResult.setKeepCallbackAsBool(true)

					self.commandDelegate?.sendPluginResult(pluginResult, callbackId:command.callbackId)
	            }
	        }
	//        https://github.com/BradLarson/GPUImage/blob/master/framework/Source/GPUImageLookupFilter.h
	//        answer: http://stackoverflow.com/questions/33731637/how-to-create-gpuimage-lookup-png-resource

	        
	        // self.lanczosResamplingFilter?.forceProcessingAtSize(self.destSize!)
	        // self.videoCamera?.addTarget(self.lanczosResamplingFilter)
	        // self.lanczosResamplingFilter?.addTarget(self.output)
	        // self.videoCamera?.startCameraCapture()

	        self.videoCamera?.addTarget(self.output)
	        self.videoCamera?.startCameraCapture()

	     })// end runsinbackground
        
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


