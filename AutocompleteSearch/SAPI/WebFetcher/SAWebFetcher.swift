//
//  WebFetcher.swift
//  Project
//
//  Created by GIB on 5/11/16.
//  Copyright © 2016 Veripark. All rights reserved.
//

import UIKit

let kServiceTimeOut: NSTimeInterval = 60.0

// enum for http methods
@objc public enum HTTPMethod: Int {
    case Get    = 1
    case Post   = 2
    case Put    = 3
    case Delete = 4
    
    func value() -> String {
        switch self {
        case .Get:    return "GET"
        case .Post:   return "POST"
        case .Put:    return "PUT"
        case .Delete: return "DELETE"
        }
    }
}

// enum for data format
@objc public enum DataFormat: Int {
    
    case JSON = 0
    case MessagePack = 1
    case Image = 2
}

// enum for request state
enum RequestState: Int {
    
    case None = 0
    case Executing = 1
    case Finished = 2
    case Cancelled = 3
}

// content type constants
let kWebRequestContentType: String        = "Content-type"
let kWebRequestContentTypeMsgPack: String = "application/x-msgpack"
let kWebRequestContentTypeJson: String    = "application/json"
let kWebRequestContentTypeJPEG: String    = "image/jpeg"

// status code
let kStatusCodeOK: Int = 200

// TODO
// error class

@objc public class SAWebFetcher: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    // MARK: public properties
    
    
    public var parameterDict = Dictionary <String, AnyObject>()
    public var additionalRequestHaders: NSDictionary? = nil
    
    // callback methods
    public var successCallback: (responseData: NSData) -> Void = { (responseData: NSData) in }
    public var failureCallback: (error: NSError?) -> Void = { (error: NSError?) in }
    
    // MARK: private properties

    private var url: NSURL!
    private var httpMethod: HTTPMethod? = .Get
    private var dataFormat: DataFormat? = .JSON
    private var connection: NSURLConnection!
    private var requestState: RequestState? = .None
    private var httpResponse: NSHTTPURLResponse?
    private var data: NSMutableData?
    
    // initialize with url
    public func setUrl(url: NSURL) {

        self.url = url
    }
    
    // this method will set http method
    public func setHttpMethod(httpMethod: HTTPMethod) {
        self.httpMethod = httpMethod
    }
    
    // this method will set http method
    public func setDataFormat(dataFormat: DataFormat) {
        self.dataFormat = dataFormat
    }
    
    // this method will do async web call
    public func startFetchingAsync() {
        
        if SANetworkUtility.hasConnectivity() {
            SALogger.Log("Going to hit end point: " + self.url.absoluteString!)
            
            self.requestState = .Executing
            let conn: NSURLConnection = NSURLConnection(request: self.executingRequest(), delegate:self, startImmediately:false)!
            self.connection = conn
            self.connection.start()
            
            SALogger.Log("startFetchingAsync")
        }
        else {
            
            SALogger.Log("Please check internet connectivity..")
        }
        
    }
    
    // this method will do sync web call
    public func startFetchingSync() {
        
        if SANetworkUtility.hasConnectivity() {
            
            self.requestState = .Executing
            
            var response: NSURLResponse?
            
            do {
                
                let data = try NSURLConnection.sendSynchronousRequest(self.executingRequest(), returningResponse: &response)
                
                let httpResponse = response as! NSHTTPURLResponse
                
                if httpResponse.statusCode == kStatusCodeOK {
                    
                    // success callback
                    self.successCallback(responseData: data)
                }
                else {
                    
                    // failure callback
                    let error: NSError = NSError(domain: "Error with status code:\(httpResponse.statusCode)", code: 0, userInfo: nil)
                    self.failureCallback(error: error)
                }
                
                self.requestState = .Finished
                
            }
            catch let error as NSError {
                
                SALogger.Log(error)
                
                // failure callback
                self.failureCallback(error: error)
            }
        }
        else {
            
            SALogger.Log("Please check internet connectivity..")
        }
    }

    // this method will cancel the current request
    public func cancel() {
        
        if self.requestState == .Executing {
            
            self.connection.cancel()
            self.requestState = .Cancelled
        }
        
    }
    
    deinit {
        
        self.requestState = .None
        self.data = nil
        self.httpResponse = nil
        
        if self.connection != nil {
            
            self.connection.cancel()
            self.connection = nil
        }
    }
    
    // MARK: NSURLConnectionDelegate
    
    public func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        
        self.requestState = .Finished
        
        SALogger.Log(error)
        
        // failure callback
        self.failureCallback(error: error)
    }
    
    // MARK: NSURLConnectionDataDelegate
    
    public func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {

        self.httpResponse = response as? NSHTTPURLResponse
    }
    
    public func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        
        if self.data == nil {
            self.data = NSMutableData()
        }
        
        self.data?.appendData(data)
    }
    
    public func connectionDidFinishLoading(connection: NSURLConnection) {
     
        self.requestState = .Finished
        
        if self.httpResponse?.statusCode == kStatusCodeOK {
            
            // success callback
            self.successCallback(responseData: self.data!)
        }
        else {
            
            // failure callback
            let error: NSError = NSError(domain: "Error with status code:\(httpResponse?.statusCode)", code: 0, userInfo: nil)
            self.failureCallback(error: error)
        }
    }

    // MARK: Helper Methods
    
    // this method will create http request
    private func executingRequest() -> NSMutableURLRequest {
        
        // Normal request
        let request: NSMutableURLRequest = NSMutableURLRequest()
        request.URL = self.url
        request.timeoutInterval = kServiceTimeOut
        
        if self.dataFormat == .JSON {
            
            request.addValue(kWebRequestContentTypeJson, forHTTPHeaderField: kWebRequestContentType)
        }
        else if self.dataFormat == .Image {
            
            request.addValue(kWebRequestContentTypeJPEG, forHTTPHeaderField: kWebRequestContentType)
        }
        
        // Additional headers
        if self.additionalRequestHaders != nil {
            
            for (key, value) in self.additionalRequestHaders! {
                request.addValue(value as! String, forHTTPHeaderField:key as! String)
            }
            
            SALogger.Log("Request Header:")
            SALogger.Log(self.additionalRequestHaders)
        }
        
        if self.parameterDict.count > 0 {
            
            request.HTTPBody = self.createHTTPBody()
            
            SALogger.Log("Request Body:")
            SALogger.Log(request.HTTPBody)
        }
        
        if self.httpMethod != .None {
            
            request.HTTPMethod = (self.httpMethod?.value())!
        }
        else {
            
            request.HTTPMethod = HTTPMethod.Get.value()
        }
        
        SALogger.Log("Request Method:" + request.HTTPMethod)
        
        return request
    }
    
    // this method will create http request body
    private func createHTTPBody() -> NSData?
    {
        var httpBody: NSData = NSData()
        
        let params:NSMutableData = NSMutableData()
        
        for (key, value) in self.parameterDict {
            
            // Check if value is an array. If so create a string of values with the same key.
            if let stringArray = value as? [String]
            {
                // obj is a string array. Do something with stringArray
                for string: String  in stringArray
                {
                    let encodedValue = SANetworkUtility.urlEncodeValue(string, encoding: NSUTF8StringEncoding)
                    let keyValueParam = key + "=" + encodedValue + "&"
                    params.appendData(keyValueParam.dataUsingEncoding(NSUTF8StringEncoding)!)
                }
            }
            else
            {
                // obj is not a string array
                // Create a single key=value& parameter
                let encodedValue = SANetworkUtility.urlEncodeValue(value as? String, encoding: NSUTF8StringEncoding)
                let keyValueParam = key + "=" + encodedValue  + "&"
                params.appendData(keyValueParam.dataUsingEncoding(NSUTF8StringEncoding)!)
            }
        }
        
        httpBody = params.copy() as! NSData
        
        return httpBody
    }
}


