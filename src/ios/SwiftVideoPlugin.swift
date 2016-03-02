import Foundation

@objc(SwiftVideoPlugin) class SwiftVideoPlugin : CDVPlugin {
  func sayHello(command: CDVInvokedUrlCommand) {
  	commandDelegate?.runInBackground({() -> Void in
	    let message = "Hello !";
	    // print(CDVInvokedUrlCommand)
	    let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: message);
	    pluginResult.setKeepCallbackAsBool(true)
	    self.commandDelegate?.sendPluginResult(pluginResult, callbackId:command.callbackId);

	    let pluginResultTwo = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: "World!");
	    // pluginResultTwo.setKeepCallbackAsBool(true) // this will cause it not to work,
	    // if you set this true (again)
	    // you need to then send another result after the one below
	    self.commandDelegate?.sendPluginResult(pluginResultTwo, callbackId:command.callbackId);
	 })

  }
}


// http://stackoverflow.com/questions/25448976/how-to-write-cordova-plugin-in-swift

// func myPluginMethod(command: CDVInvokedUrlCommand) {
//     // Check command.arguments here.
//     self.commandDelegate.runInBackground({() -> Void in
//         var payload: String? = nil
//             // Some blocking logic...
//         var pluginResult: CDVPluginResult = CDVPluginResult.resultWithStatus(CDVCommandStatus_OK, messageAsString: payload!)
//         // The sendPluginResult method is thread-safe.
//         self.commandDelegate.sendPluginResult(pluginResult, callbackId: command.callbackId)
//     })
// }