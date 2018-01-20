//
//  NetHandler.swift
//  VocabCrack
//
//  Created by aidancbrady on 12/2/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//
import Foundation

class NetHandler
{
    @discardableResult
    class func sendData(_ str:String) -> String?
    {
        Operations.setNetworkActivity(true)
        
        var inputStream:InputStream?
        var outputStream:OutputStream?
        
        Stream.getStreamsToHost(withName: AppDelegate.IP, port: AppDelegate.PORT, inputStream: &inputStream, outputStream: &outputStream)
        
        var writeData = [UInt8]((str + "\n").utf8)
        
        outputStream!.open()
        outputStream!.write(&writeData, maxLength: writeData.count)
        outputStream!.close()
        
        inputStream!.open()
        
        var buffer = [UInt8](repeating: 0, count: 1048576)
        var bytes = inputStream!.read(&buffer, maxLength: 1024)
        let data = NSMutableData(bytes: &buffer, length: bytes)
        
        while inputStream!.hasBytesAvailable
        {
            let read = inputStream!.read(&buffer, maxLength: 1024)
            bytes += read
            data.append(&buffer, length: read)
        }
        
        inputStream?.close()
        
        Operations.setNetworkActivity(false)
        
        if let str = NSString(bytes: data.bytes, length: bytes, encoding: String.Encoding.utf8.rawValue)
        {
            return str as String
        }
        
        return nil
    }
    
    class func sendDeviceID(deviceID: String)
    {
        DispatchQueue.global(qos: .background).async {
            let str = compileMsg("PUSHID", deviceID)
            
            if let ret = sendData(str)
            {
                print("Server responded with msg: " + ret)
            }
            else {
                print("Failed to send device ID to server")
            }
        }
    }
}

func compileMsg(_ msg:String...) -> String
{
    var ret = ""
    
    if msg.count > 0
    {
        for index in 0...msg.count-1
        {
            ret += msg[index]
            
            if index < msg.count-1
            {
                ret += AppDelegate.SPLITTER
            }
        }
    }
    
    return ret
}
