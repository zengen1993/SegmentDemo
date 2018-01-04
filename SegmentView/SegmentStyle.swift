//
//  SegmentStyle.swift
//  ZEScollViewPage
//
//  Created by Apple on 2017/12/19.
//  Copyright © 2017年 com.dome. All rights reserved.
//

import UIKit
/// Segment样式
public struct SegmentStyle{
    /// 是否显示遮盖
    public var showCover = false
    /// 是否显示下划线
    public var showLine = false
    /// 是否缩放文字
    public var scaleTitle = false
    /// 是否可以滚动标题
    public var scrollTitle = true
    /// 下面的滚动条的高度 默认2
    public var scrollLineHeight: CGFloat = 2
    /// 下面的滚动条的颜色
    public var scrollLineColor = UIColor.brown
    /// 遮盖的背景颜色
    public var coverBackgroundColor = UIColor.lightGray
    /// 遮盖圆角
    public var coverCornerRadius: CGFloat = 14.0
    /// cover的高度 默认28
    public var coverHeight: CGFloat = 28.0
    /// 文字间的间隔 默认15
    public var titleMargin: CGFloat = 15
    /// 文字 字体 默认14.0
    public var titleFont = UIFont.systemFont(ofSize: 14.0)
    /// 放大倍数 默认1.3
    public var titleBigScale: CGFloat = 1.1
    /// 默认倍数 不可修改
    let titleOriginalScale: CGFloat = 1.0
    
    /// 文字正常状态颜色 请使用RGB空间的颜色值!! 如果提供的不是RGB空间的颜色值就可能crash
    public var normalTitleColor = UIColor(red: 51.0/255.0, green: 53.0/255.0, blue: 75/255.0, alpha: 1.0)
    /// 文字选中状态颜色 请使用RGB空间的颜色值!! 如果提供的不是RGB空间的颜色值就可能crash
    public var selectedTitleColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 121/255.0, alpha: 1.0)
    public init() {
        
    }
}
