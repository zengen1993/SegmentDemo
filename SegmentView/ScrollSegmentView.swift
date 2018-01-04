//
//  ScrollSegmentView.swift
//  ZEScollViewPage
//
//  Created by Apple on 2017/12/20.
//  Copyright © 2017年 com.dome. All rights reserved.
//

import UIKit

open class ScrollSegmentView: UIView {
    open var segmentStyle: SegmentStyle
    /// 点击响应
    open var titleBtnOnClick:((_ label: UILabel, _ index: Int)->Void)?
    /// 所有标题的宽度
    fileprivate var titleWidthArry: [CGFloat] = []
    /// 所有的标题
    fileprivate var titles: [String]
    /// 缓存标题
    fileprivate var labelsArray: [UILabel]  = []
    /// self.bounds.size.width
    fileprivate var currentWidth: CGFloat = 0
    /// 记录当前选中的下标
    fileprivate var currentIndex = 0
    /// 记录上一个下标
    fileprivate var oldIndex = 0
    /// 所以文字的总宽度
    fileprivate var labelWithMax: CGFloat = 0
    /// 遮罩x和文字x的间隙
    fileprivate var xGap = 5
    /// 遮罩宽度比文字宽度多的部分
    fileprivate var wGap: Int {
        return 2 * xGap
    }
    /// 管理标题的滚动
     fileprivate lazy var scrollView: UIScrollView = {
        let scrollV = UIScrollView()
        scrollV.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        scrollV.showsHorizontalScrollIndicator = false
        scrollV.bounces = true
        scrollV.isPagingEnabled = false
        scrollV.scrollsToTop = false
        return scrollV
    }()
    /// 是否显示滚动条
    fileprivate lazy var scrollLine: UIView? = {[unowned self] in
        let line = UIView()
        return self.segmentStyle.showLine ? line : nil
    }()
  
    /// 是否显示遮罩
    fileprivate lazy var coverView: UIView? = {[unowned self] in
        let cover = UIView()
        cover.layer.cornerRadius = CGFloat(self.segmentStyle.coverCornerRadius)
        cover.layer.masksToBounds = true
        return self.segmentStyle.showCover ? cover : nil
    }()
    
    /// 懒加载颜色的rgb变化值, 不要每次滚动时都计算
    fileprivate lazy var rgbDelta: (deltaR: CGFloat, deltaG: CGFloat, deltaB: CGFloat) = {[unowned self] in
        let normalColorRgb = self.normalColorRgb
        let selectedTitleColorRgb = self.selectedTitleColorRgb
        let deltaR = normalColorRgb.r - selectedTitleColorRgb.r
        let deltaG = normalColorRgb.g - selectedTitleColorRgb.g
        let deltaB = normalColorRgb.b - selectedTitleColorRgb.b
        
        return (deltaR: deltaR, deltaG: deltaG, deltaB: deltaB)
    }()
    /// 懒加载颜色的rgb变化值, 不要每次滚动时都计算
    fileprivate lazy var normalColorRgb: (r: CGFloat, g: CGFloat, b: CGFloat) = {
        
        if let normalRgb = self.getColorRGB(self.segmentStyle.normalTitleColor) {
            return normalRgb
        } else {
            fatalError("设置普通状态的文字颜色时 请使用RGB空间的颜色值")
        }
    }()
    
    fileprivate lazy var selectedTitleColorRgb: (r: CGFloat, g: CGFloat, b: CGFloat) =  {
        
        if let selectedRgb = self.getColorRGB(self.segmentStyle.selectedTitleColor) {
            return selectedRgb
        } else {
            fatalError("设置选中状态的文字颜色时 请使用RGB空间的颜色值")
        }
        
    }()
    
    //FIXME: 如果提供的不是RGB空间的颜色值就可能crash
    fileprivate func getColorRGB(_ color: UIColor) -> (r: CGFloat, g: CGFloat, b: CGFloat)? {
        
        //         print(UIColor.getRed(color))
        let numOfComponents = color.cgColor.numberOfComponents
        if numOfComponents == 4 {
            let componemts = color.cgColor.components
            //            print("\(componemts[0]) --- \(componemts[1]) ---- \(componemts[2]) --- \(componemts[3])")
            
            return (r: componemts?[0], g: componemts?[1], b: componemts?[2]) as! (r: CGFloat, g: CGFloat, b: CGFloat)
            
        }
        return nil
        
        
    }
    open var backgroundImage: UIImage? = nil {
        didSet {
            // 在设置了背景图片的时候才添加imageView
            if let image = backgroundImage {
                backgroundImageView.image = image
                insertSubview(backgroundImageView, at: 0)
            }
        }
    }
    fileprivate lazy var backgroundImageView: UIImageView = {[unowned self] in
        let imageView = UIImageView(frame: self.bounds)
        return imageView
    }()

//MARK:- 逻辑处理
    public init(frame: CGRect, segmentStyle: SegmentStyle, titles: [String]){
        self.segmentStyle = segmentStyle
        self.titles = titles
        super.init(frame: frame)
        
        addSubview(scrollView)
        // 根据Titles添加相应的控件
        setupTitles()
        // 设置Frame
        setupUI()
    }
    @objc func titleLabelOnClick(_ tapGes: UITapGestureRecognizer){
        guard let currentLabel = tapGes.view as? CustomLabel else { return }
        currentIndex = currentLabel.tag
        print(currentLabel.tag)
        adjustUIWhenBtnOnClickWithAnimate(true)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - public helper
extension ScrollSegmentView {
    ///  对外界暴露设置选中的下标的方法 可以改变设置下标滚动后是否有动画切换效果
    public func selectedIndex(_ selectedIndex: Int, animated: Bool) {
        assert(!(selectedIndex < 0 || selectedIndex >= titles.count), "设置的下标不合法!!")
        
        if selectedIndex < 0 || selectedIndex >= titles.count {
            return
        }
        
        // 自动调整到相应的位置
        currentIndex = selectedIndex
        //        print("\(oldIndex) ------- \(currentIndex)")
        // 可以改变设置下标滚动后是否有动画切换效果
        adjustUIWhenBtnOnClickWithAnimate(animated)
    }
    
    // 暴露给外界来刷新标题的显示
    public func reloadTitlesWithNewTitles(_ titles: [String]) {
        // 移除所有的scrollView子视图
        scrollView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        // 移除所有的label相关
        titleWidthArry.removeAll()
        labelsArray.removeAll()
        
        // 重新设置UI
        self.titles = titles
        setupTitles()
        setupUI()
        // default selecte the first tag
        selectedIndex(0, animated: true)
    }
}

//MARK:- 私有方法
extension ScrollSegmentView{
    // 根据Titles添加相应的控件
    fileprivate func setupTitles() {
        for (index, title) in titles.enumerated(){
            let label = CustomLabel(frame: CGRect.zero)
            label.tag = index
            label.text = title
            label.font = segmentStyle.titleFont
            label.textColor = UIColor.black
            label.textAlignment = .center
            label.isUserInteractionEnabled = true
            // 添加点击手势
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.titleLabelOnClick(_:)))
            label.addGestureRecognizer(tapGes)
            // 计算文本宽高
            let size = (title as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0.0), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: label.font], context: nil)
            // 缓存文字宽度
            titleWidthArry.append(size.width)
            // 缓存label
            labelsArray.append(label)
            // 添加label
            scrollView.addSubview(label)
        }
    }
    // 设置Frame
    fileprivate func setupUI() {
        // 设置Label位置
        currentWidth = bounds.size.width
        setUpLabelsPosition()
        // 设置滚动条和遮罩
        setupScrollLineAndCover()
        
        if segmentStyle.scrollTitle{
            if let lastLabel = labelsArray.last {
                scrollView.contentSize = CGSize(width: lastLabel.frame.maxX + segmentStyle.titleMargin, height: 0)
            }
        }
    }
    /// 设置label的位置
    fileprivate func setUpLabelsPosition() {
        var titleX: CGFloat = 0.0
        let titleY: CGFloat = 0.0
        var titleW: CGFloat = 0.0
        let titleH = bounds.size.height - segmentStyle.scrollLineHeight
        if !segmentStyle.scrollTitle{
            titleW = currentWidth/CGFloat(titles.count)
            for(index, label) in labelsArray.enumerated(){
                titleX = titleW * CGFloat(index)
                
                label.frame = CGRect(x: titleX, y: titleY, width: titleW, height: titleH)
            }
        }else{
            // 计算标题长度总和
            for (index, labelWith) in titleWidthArry.enumerated(){
                labelWithMax += labelWith + 2 * segmentStyle.titleMargin
            }
            // 当标题的长度总和没有屏幕宽度长时，平分屏幕宽度
            if labelWithMax <= currentWidth{
                for(index, label) in labelsArray.enumerated(){
                    let currWidth = currentWidth - 2 * segmentStyle.titleMargin
                    titleW = currWidth/CGFloat(labelsArray.count)
                    titleX = segmentStyle.titleMargin
                    if index != 0{
                        let lastLabel = labelsArray[index - 1]
                        titleX = lastLabel.frame.maxX 
                    }
                    label.frame = CGRect(x: titleX, y: titleY, width: titleW, height: titleH)
                }
            }
            // 当标题的长度总和比屏幕宽度短时
            else{
                for(index, label) in labelsArray.enumerated(){
                    titleW = titleWidthArry[index]
                
                    titleX = segmentStyle.titleMargin
                    if index != 0{
                        let lastLabel = labelsArray[index - 1]
                        titleX = lastLabel.frame.maxX + segmentStyle.titleMargin * 2
                    }
                    label.frame = CGRect(x: titleX, y: titleY, width: titleW, height: titleH)
                }
            }
        }
        if let firstLabel = labelsArray[0] as? CustomLabel {
            
            // 缩放, 设置初始的label的transform
            if segmentStyle.scaleTitle {
                firstLabel.currentTransformSx = segmentStyle.titleBigScale
            }
            // 设置初始状态文字的颜色
            firstLabel.textColor = segmentStyle.selectedTitleColor
        }
    }
    /// 设置滚动条和遮罩
    fileprivate func setupScrollLineAndCover(){
        if let line = scrollLine {
            line.backgroundColor = segmentStyle.scrollLineColor
            scrollView.addSubview(line)
        }
        if let cover = coverView {
            cover.backgroundColor = segmentStyle.coverBackgroundColor
            scrollView.insertSubview(cover, at: 0)
        }
        let coverX = labelsArray[0].frame.origin.x
        let coverW = labelsArray[0].frame.size.width
        let coverH: CGFloat = segmentStyle.coverHeight
        let coverY = (bounds.size.height - coverH) / 2
        
        // 设置遮罩位置
        if segmentStyle.scrollTitle {
            // 这里x-xGap width+wGap 是为了让遮盖的左右边缘和文字有一定的距离
            coverView?.frame = CGRect(x: coverX - CGFloat(xGap), y: coverY, width: coverW + CGFloat(wGap), height: coverH)
        } else {
            coverView?.frame = CGRect(x: coverX, y: coverY, width: coverW, height: coverH)
        }
        // 设置滚动条位置
        scrollLine?.frame = CGRect(x: coverX, y: bounds.size.height - segmentStyle.scrollLineHeight, width: coverW, height: segmentStyle.scrollLineHeight)
    }
    /// 手动点击按钮的时候调整UI
    func adjustUIWhenBtnOnClickWithAnimate(_ animated: Bool){
        guard currentIndex != oldIndex else {
            return
        }
        let oldLabel = labelsArray[oldIndex] as! CustomLabel
        let currentLabel = labelsArray[currentIndex] as! CustomLabel
        // 让选中标签居中显示
        adjustTitleOffSetToCurrentIndex(currentIndex)
        // 动画效果
        UIView.animate(withDuration: 0.3) {
            [unowned self] in
            // 设置文字颜色
            oldLabel.textColor = self.segmentStyle.normalTitleColor
            currentLabel.textColor = self.segmentStyle.selectedTitleColor
            
            // 缩放文字
            if self.segmentStyle.scaleTitle {
                oldLabel.currentTransformSx = self.segmentStyle.titleOriginalScale

                currentLabel.currentTransformSx = self.segmentStyle.titleBigScale

            }
            // 设置滚动条的位置
            self.scrollLine?.frame.origin.x = currentLabel.frame.origin.x
            // 注意, 通过bounds 获取到的width 是没有进行transform之前的 所以使用frame
            self.scrollLine?.frame.size.width = currentLabel.frame.size.width
            
            // 设置遮盖位置
            if self.segmentStyle.scrollTitle {
                self.coverView?.frame.origin.x = currentLabel.frame.origin.x - CGFloat(self.xGap)
                self.coverView?.frame.size.width = currentLabel.frame.size.width + CGFloat(self.wGap)
            } else {
                self.coverView?.frame.origin.x = currentLabel.frame.origin.x
                self.coverView?.frame.size.width = currentLabel.frame.size.width
            }
        }
        oldIndex = currentIndex
        
        titleBtnOnClick?(currentLabel, currentIndex)
    }
    /// 让选中标签居中显示
    public func adjustTitleOffSetToCurrentIndex(_ currentIndex: Int){
        let currentLabel = labelsArray[currentIndex]
        
        for index in labelsArray.enumerated(){
            if index.offset != currentIndex{
                index.element.textColor = self.segmentStyle.normalTitleColor
            }
        }
        /// scrollView需要移动的偏移量
        var offSetX = currentLabel.center.x - currentWidth/2
        if offSetX < 0 {
            offSetX = 0
        }
        /// scrollView最大偏移量
        var maxOffSetX = scrollView.contentSize.width - currentWidth
        // 可以滚动的区域小余屏幕宽度
        if maxOffSetX < 0 {
            maxOffSetX = 0
        }
        // 当offSetX偏移量大于最大偏移量时，就直接等于最大偏移量，否则会出现最后一个标签也居中显示
        if offSetX > maxOffSetX {
            offSetX = maxOffSetX
        }
        // 设置scrollView的偏移量
        scrollView.setContentOffset(CGPoint(x:offSetX, y: 0), animated: true)
    }
}
open class CustomLabel: UILabel {
    /// 用来记录当前label的缩放比例
    open var currentTransformSx:CGFloat = 1.0 {
        didSet {
            transform = CGAffineTransform(scaleX: currentTransformSx, y: currentTransformSx)
        }
    }
}
