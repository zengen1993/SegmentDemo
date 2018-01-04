//
//  SegmentVC.swift
//  ZEScollViewPage
//
//  Created by Apple on 2017/12/26.
//  Copyright © 2017年 com.dome. All rights reserved.
//

import UIKit

class SegmentVC: UIViewController{
    override func viewDidLoad(){
        super.viewDidLoad()
        self.title = "自定义Segment"
        self.view.backgroundColor = UIColor.white
        // 这个是必要的设置
        automaticallyAdjustsScrollViewInsets = false
        // 显示下划线
        var style = SegmentStyle()
        style.scrollTitle = true
        style.showLine = true
        style.scrollLineColor = UIColor.blue
        let scrollview = ScrollSegmentView(frame: CGRect(x: 0, y: 64, width: self.view.frame.width, height: 40), segmentStyle: style, titles: ["绝地求生","绝地大逃杀"])
        self.view.addSubview(scrollview)
        // 显示遮罩
        var style1 = SegmentStyle()
        style1.scrollTitle = true
        style1.showCover = true
        style1.scrollLineColor = UIColor.blue
        
        let scrollview1 = ScrollSegmentView(frame: CGRect(x: 0, y: 164, width: self.view.frame.width, height: 40), segmentStyle:  style1, titles: ["绝地求生","绝地大逃杀"])
        self.view.addSubview(scrollview1)
        
        // 显示下划线
        var style2 = SegmentStyle()
        style2.scaleTitle = true
        style2.scrollTitle = true
        style2.showLine = true
        style2.scrollLineColor = UIColor.blue
        let scrollview2 = ScrollSegmentView(frame: CGRect(x: 0, y: 264, width: self.view.frame.width, height: 40), segmentStyle: style, titles: ["绝地求生","绝地大逃杀","绝地求生","绝地大逃杀","绝地求生","绝地大逃杀"])
        self.view.addSubview(scrollview2)
        
    }
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
