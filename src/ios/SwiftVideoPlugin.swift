import Foundation

import GPUImage


struct Options {
	var size: CGSize?
	var palette: [[Float]]? //= [[1,2,3], [77,32,83]]
	var minMsPerFrame: Int?
}


@objc(SwiftVideoPlugin) class SwiftVideoPlugin : CDVPlugin {
  var options = Options()
  var videoCamera:GPUImageVideoCamera?
  var filter:GPUImagePixellateFilter?
  var output:GPUImageRawDataOutput? 
  var rawBytesForImage: UnsafeMutablePointer<GLubyte>? //UInt8
  var last_time = NSDate()
  var lanczosResamplingFilter:GPUImageLanczosResamplingFilter?
  var destSize:CGSize?

  func setupPalette(command: CDVInvokedUrlCommand) {
  	print("setupPalette called (Swift)")
  	self.options.palette = command.arguments[0] as? [[Float]]
  	print(self.options)
  	var a = KDPointImpl(values: [9,3, 14], payload: Int())
  	// print(a)
  	let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
  	self.commandDelegate?.sendPluginResult(pluginResult, callbackId:command.callbackId)
  }

  func setupCamera(command: CDVInvokedUrlCommand) {
  	// self.options.palette = command.arguments[0] as? [[Float]]
  	// print(self.options)
  	// var a = KDPointImpl(values: [9,3, 14], payload: Int())
  	// print(a)
  	let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
  	self.commandDelegate?.sendPluginResult(pluginResult, callbackId:command.callbackId)
  }

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




// This should clearly be in a different file, but I can't figure out how
// import UIKit

// import Foundation

public protocol KDPoint {
    func distance(other: Self) -> Double
    func dimension() -> Int
    func lessThan(other: Self, dim: Int) -> Bool
}

public enum BinaryTreeVisitOrder {
    case InOrder
    case PreOrder
    case PostOrder
}

struct KDTreeNodeInfo {
    let count: Int
    let height: Int
    let balanced: Bool
}

public protocol NumericType {
    var doubleValue: Double {get}
}

extension Int : NumericType {
    public var doubleValue: Double {
        return Double(self)
    }
}

extension Float : NumericType {
    public var doubleValue: Double {
        return Double(self)
    }
}

extension Double : NumericType {
    public var doubleValue: Double {
        return self
    }
}

public struct KDPointImpl<T: NumericType, PayloadType> : KDPoint {
    public let values: [T]
    public let payload: PayloadType
    
    public init(values v: [T], payload p: PayloadType) {
        values = v
        payload = p
    }
    
    public func distance(p: KDPointImpl<T, PayloadType>) -> Double {
        return sqrt(zip(values, p.values).map{a, b in pow(a.doubleValue - b.doubleValue, 2)}.reduce(0, combine: +))
    }
    
    public func dimension() -> Int {
        return values.count
    }
    
    public func lessThan(other: KDPointImpl<T, PayloadType>, dim: Int) -> Bool {
        return values[dim].doubleValue < other.values[dim].doubleValue
    }
}

public enum KDTree<T: KDPoint> {
    case Leaf
    indirect case Node(value: T, fields: Any, left: KDTree<T>, right: KDTree<T>)
    
    static func makeNode(value v: T, left l: KDTree<T> = .Leaf, right r: KDTree<T> = .Leaf) -> KDTree<T> {
        let f = KDTreeNodeInfo(
            count: 1 + l.count + r.count,
            height: 1 + max(l.height, r.height),
            balanced: l.balanced && r.balanced && abs(l.height - r.height) <= 1)
        return .Node(value: v, fields: f, left: l, right: r)
    }
    
    public static func fromPoints(points: [T], _ depth: Int = 0) -> KDTree<T> {
        if points.count <= 1 {
            return points.isEmpty ? .Leaf : makeNode(value: points[0])
        }
        let axis = depth % points[0].dimension()
        let sortedPoints = points.sort{a1, a2 in return a1.lessThan(a2, dim: axis)}
        let median = Int(sortedPoints.count/2)
        return makeNode(
            value: sortedPoints[median],
            left: fromPoints(Array(sortedPoints[0..<median]), depth + 1),
            right: fromPoints(Array(sortedPoints[median+1..<sortedPoints.count]), depth + 1))
    }
    
    public func nearestNeighbor(p: T, nearest: T? = nil, minDist: Double = Double.infinity, _ depth: Int = 0) -> T? {
        switch(self) {
        case .Leaf:
            return nearest
        case .Node(let value, _, let left, let right):
            let d = value.distance(p)
            let nearest1 = d < minDist ? value : nearest
            let minDist1 = d < minDist ? d : minDist
            let axis = depth % value.dimension()
            let subtree = p.lessThan(value, dim: axis) ? left : right
            return subtree.nearestNeighbor(p, nearest: nearest1, minDist: minDist1, depth + 1)
        }
    }
    
    public func insert(p: T, _ depth: Int = 0) -> KDTree<T> {
        switch(self) {
        case .Leaf:
            return KDTree.makeNode(value: p)
        case .Node(let value, _, let left, let right):
            let axis = depth % value.dimension()
            if p.lessThan(value, dim: axis) {
                return KDTree.makeNode(value: value, left: left.insert(p, depth + 1), right: right)
            } else {
                return KDTree.makeNode(value: value, left: left, right: right.insert(p, depth + 1))
            }
        }
    }
    
    var fields: KDTreeNodeInfo {
        switch(self) {
        case .Leaf: return KDTreeNodeInfo(count: 0, height: 0, balanced: true)
        case .Node(_, let f, _, _): return f as! KDTreeNodeInfo
        }
    }
    
    public var count: Int {return fields.count}
    public var height: Int {return fields.height}
    public var balanced: Bool {return fields.balanced}
    
    public var shape: Double {
        let optimalHeight = log2(Double(1 + count))
        let actualHeight = Double(height)
        return optimalHeight / actualHeight
    }
    
    public func rebalance(threshold t: Double = 1.0) -> KDTree<T> {
        if !balanced && shape < t {
            var points = [T]()
            visit(.InOrder){e in points.append(e)}
            return KDTree.fromPoints(points)
        } else {
            return self
        }
    }
    
    public func visit(order: BinaryTreeVisitOrder, _ visitor: (T -> Void)) -> Void {
        switch(self) {
        case .Leaf: break
        case .Node(let value, _, let left, let right):
            if order == .PreOrder {visitor(value)}
            left.visit(order, visitor)
            if order == .InOrder {visitor(value)}
            right.visit(order, visitor)
            if order == .PostOrder {visitor(value)}
        }
    }
    
    public func printFormatted(depth: Int = 0) {
        switch(self) {
        case .Leaf: break
        case .Node(let value, _, let left, let right):
            let indent = String.init(count: depth*4, repeatedValue: Character(" "))
            print("\(indent)\(value) (count=\(count), height=\(height), balanced=\(balanced), shape=\(shape))")
            left.printFormatted(depth + 1)
            right.printFormatted(depth + 1)
        }
    }
}