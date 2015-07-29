//
//  NpmDataSource.swift
//  NPM data
//
//  Created by YourtionGuo on 7/29/15.
//  Copyright (c) 2015 Yourtion. All rights reserved.
//

import Foundation

protocol NpmDataSourceDelegate {
    func getSearchResult(result:AnyObject!, error:NSError!)
    func getSuggestionsResult(result:AnyObject!, error:NSError!)
    func getGetNpmPackageResult(result:AnyObject!, error:NSError!)
}

class NpmDataSource {
    
    var delegate:NpmDataSourceDelegate?
    let op:NSOperationQueue = NSOperationQueue()
    
    func SearcNpm (keyword:String) {
        let urlstr = "https://npm.best/api/search.json?query=" + keyword + "&skip=0&limit=10"
        let url = NSURL(string: urlstr)
        let urlrequest = NSURLRequest(URL: url!)
        //通过NSURLConnection发送请求
        NSLog("开始请求数据...")
        NSURLConnection.sendAsynchronousRequest(urlrequest, queue: self.op) {
            (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
            
            NSLog("下载完成")
            
            self.delegate?.getSearchResult(data, error: error)
            
        }
    }
    
    func SuggestionsNpm (keyword:String) {
        let urlstr = "https://npm.best/api/search/input/suggestions?type=start&query=" + keyword + "&skip=0&limit=10"
        let url = NSURL(string: urlstr)
        let urlrequest = NSURLRequest(URL: url!)
        //通过NSURLConnection发送请求
        NSLog("开始请求数据...")
        NSURLConnection.sendAsynchronousRequest(urlrequest, queue: self.op) {
            (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
            
            NSLog("下载完成")
            
            self.delegate?.getSuggestionsResult(data, error: error)
            
        }
    }
    
    func GetNpmPackage (package:String) {
        let urlstr = "http://registry.npmjs.org/" + package
        let url = NSURL(string: urlstr)
        let urlrequest = NSURLRequest(URL: url!)
        //通过NSURLConnection发送请求
        NSLog("开始请求数据...")
        NSURLConnection.sendAsynchronousRequest(urlrequest, queue: self.op) {
            (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
            
            self.delegate?.getGetNpmPackageResult(data, error: error)
            
        }
    }
    
}