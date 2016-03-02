import Foundation

import GPUImage

@objc(SwiftVideoPlugin) class SwiftVideoPlugin : CDVPlugin {
  var videoCamera:GPUImageVideoCamera?
  var filter:GPUImagePixellateFilter?
  var output:GPUImageRawDataOutput?
  var rawBytesForImage: UnsafeMutablePointer<GLubyte>?
  var last_time = NSDate()

  var lanczosResamplingFilter: GPUImageLanczosResamplingFilter = GPUImageLanczosResamplingFilter()

  func sayHello(command: CDVInvokedUrlCommand) {

  	commandDelegate?.runInBackground({() -> Void in
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
        self.output = GPUImageRawDataOutput(imageSize: CGSizeMake(35, 28), resultsInBGRAFormat: true)
        // self.output = GPUImageRawDataOutput(imageSize: CGSizeMake(352, 288), resultsInBGRAFormat: true)
//        this works too, slightly slower it seems? unlike guy says
//        output = MyRawDataOutput(imageSize: CGSizeMake(352, 288), resultsInBGRAFormat: true)

        self.output!.newFrameAvailableBlock = { () in
            let since_last = ((NSDate().timeIntervalSinceReferenceDate-self.last_time.timeIntervalSinceReferenceDate)*1000)
            print(since_last)
            self.rawBytesForImage = self.output!.rawBytesForImage
            self.last_time = NSDate()
//            print(self.rawBytesForImage?.memory)
            //http://stackoverflow.com/a/31109955/83859
            // let buffer = UnsafeMutableBufferPointer(start: self.rawBytesForImage!, count: Int(352*288*4)) // also WORKS

			// let data = NSData(bytes: self.rawBytesForImage!, length: Int(352*288*4)) // also WORKS
			let data = NSData(bytes: self.rawBytesForImage!, length: Int(35*28*4)) // also WORKS
			print(data.length)
			// was 405504
			// let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: "Hey hey h!!!!!ey!") // buffer
			let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsArrayBuffer: data) // buffer
			pluginResult.setKeepCallbackAsBool(true)
			self.commandDelegate?.sendPluginResult(pluginResult, callbackId:command.callbackId)
        }
//        https://github.com/BradLarson/GPUImage/blob/master/framework/Source/GPUImageLookupFilter.h
//        answer: http://stackoverflow.com/questions/33731637/how-to-create-gpuimage-lookup-png-resource
        self.videoCamera?.addTarget(self.lanczosResamplingFilter)
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
	 })

  }
}


// http://stackoverflow.com/questions/25448976/how-to-write-cordova-plugin-in-swift
