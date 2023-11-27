//
//  CBFlashyTabBar.swift
//  CBFlashyTabBarController
//
//  Created by Anton Skopin on 28/11/2018.
//  Copyright © 2018 cuberto. All rights reserved.
//

import UIKit

open class CBTabBar: UITabBar {

    var buttons: [CBTabBarButton] = []
    open var tabbarBackground:UIColor = .blue
    fileprivate var shouldSelectOnTabBar = true
    var buttonFactory: CBTabButtonFactory? {
        didSet {
            reloadViews()
        }
    }
    
    open override var selectedItem: UITabBarItem? {
        willSet {
            guard let newValue = newValue else {
                buttons.forEach { $0.setSelected(false, animated: false) }
                return
            }
            
            let btnItems: [UITabBarItem?] = buttons.map { $0.item }
            for (index, value) in btnItems.enumerated() {
                if value === newValue {
                    select(itemAt: index, animated: false)
                }
            }
        }
    }

    open override var tintColor: UIColor! {
        didSet {
            buttons.forEach { button in
                if let item = button.item as? CBExtendedTabItem {
                    button.tintColor = item.tintColor ?? tintColor
                } else {
                    button.tintColor = tintColor
                }
            }
        }
    }
    
    var barHeight: CGFloat = 60
    var shapeLayer: CAShapeLayer!
    open override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = barHeight
        if #available(iOS 11.0, *) {
            sizeThatFits.height = sizeThatFits.height + safeAreaInsets.bottom
        }
        return sizeThatFits
    }

    open override var items: [UITabBarItem]? {
        didSet {
            reloadViews()
        }
    }

    open override func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        super.setItems(items, animated: animated)
        reloadViews()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let sizedButtons = buttons.filter { $0.requiredSize != nil }
        let minWidth = bounds.width / CGFloat(buttons.count)
        let predefinedWidth: CGFloat = sizedButtons.compactMap { $0.requiredSize?.width }
                                                   .map { max(minWidth, $0) }
                                                   .reduce(0, +)
    
        let btnWidth = max(0, (bounds.width - predefinedWidth) / CGFloat(buttons.count - sizedButtons.count))
        let bottomOffset: CGFloat
        if #available(iOS 11.0, *) {
            bottomOffset = safeAreaInsets.bottom
        } else {
            bottomOffset = 0
        }
        let btnHeight = bounds.height - bottomOffset
        
        var lastX: CGFloat = 0
        for button in buttons {
            var padding: CGFloat = 0
            if let btnSize = button.requiredSize {
                let btnY = (btnHeight - btnSize.height)/2.0
                padding = max(0, (minWidth - btnSize.width)/2.0)
                button.frame = CGRect(origin: CGPoint(x: lastX + padding, y: btnY),
                                      size: btnSize)
            } else {
                button.frame = CGRect(x: lastX, y: 0, width: btnWidth, height: btnHeight)
            }
            lastX = button.frame.maxX + padding
            button.setNeedsLayout()
        }
        
        let middleRad: CGFloat = bounds.height - 30.0
        
        let cornerRad: CGFloat = 0
        
        let pth = UIBezierPath()
        
        let topLeftC: CGPoint = CGPoint(x: bounds.minX + cornerRad, y: bounds.minY + cornerRad)
        let topRightC: CGPoint = CGPoint(x: bounds.maxX - cornerRad, y: bounds.minY + cornerRad)
        let botRightC: CGPoint = CGPoint(x: bounds.maxX - cornerRad, y: bounds.maxY - cornerRad)
        let botLeftC: CGPoint = CGPoint(x: bounds.minX + cornerRad, y: bounds.maxY - cornerRad)
        
        var pt: CGPoint!
        
        // 1
        pt = CGPoint(x: bounds.minX, y: bounds.minY + cornerRad)
        pth.move(to: pt)
        
        // c1
        pth.addArc(withCenter: topLeftC, radius: cornerRad, startAngle: .pi * 1.0, endAngle: .pi * 1.5, clockwise: true)
        
        // 2
        pt = CGPoint(x: bounds.midX - middleRad, y: bounds.minY)
        pth.addLine(to: pt)
        
        // c2
//        pt.y += middleRad * 0.5
        pth.addArc(withCenter: pt, radius: middleRad * 0.5, startAngle: -.pi * 0.5, endAngle: 0.0, clockwise: true)
        
        // c3
        pt.x += middleRad * 1.0
        pth.addArc(withCenter: pt, radius: middleRad * 0.5, startAngle: .pi * 1.0, endAngle: 0.0, clockwise: false)
        
        // c4
        pt.x += middleRad * 1.0
        pth.addArc(withCenter: pt, radius: middleRad * 0.5, startAngle: .pi * 1.0, endAngle: .pi * 1.5, clockwise: true)
        
        // 3
        pt = CGPoint(x: bounds.maxX - cornerRad, y: bounds.minY)
        pth.addLine(to: pt)
        
        // c5
        pth.addArc(withCenter: topRightC, radius: cornerRad, startAngle: -.pi * 0.5, endAngle: 0.0, clockwise: true)
        
        // 4
        pt = CGPoint(x: bounds.maxX, y: bounds.maxY - cornerRad)
        pth.addLine(to: pt)
        
        // c6
        pth.addArc(withCenter: botRightC, radius: cornerRad, startAngle: 0.0, endAngle: .pi * 0.5, clockwise: true)
        
        // 5
        pt = CGPoint(x: bounds.minX + cornerRad, y: bounds.maxY)
        pth.addLine(to: pt)
        
        // c7
        pth.addArc(withCenter: botLeftC, radius: cornerRad, startAngle: .pi * 0.5, endAngle: .pi * 1.0, clockwise: true)
        
        pth.close()
        
        shapeLayer.path = pth.cgPath
        shapeLayer.fillColor = self.tabbarBackground.cgColor
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    private func commonInit() {
        shapeLayer = self.layer as? CAShapeLayer
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.gray.cgColor
        shapeLayer.lineWidth = 0
    }
    private func reloadViews() {
        subviews.filter { String(describing: type(of: $0)) == "UITabBarButton" }.forEach { $0.removeFromSuperview() }
        buttons.forEach { $0.removeFromSuperview()}
        buttons = buttonFactory?.buttons(forItems: items ?? []) ?? []
        for (index,button) in buttons.enumerated(){
            if let item = button.item as? CBExtendedTabItem {
                button.tintColor = item.tintColor ?? tintColor
            } else {
                button.tintColor = tintColor
            }
            if selectedItem != nil && button.item === selectedItem {
                button.setSelected(true, animated: false)
            }
            button.addTarget(self, action: #selector(btnPressed), for: .touchUpInside)
            if index != 2{
                addSubview(button)
            }
        }
        setNeedsLayout()
    }

    @objc private func btnPressed(sender: UIControl) {
        guard let sender = sender as? CBTabBarButton else {
            return
        }
        
        buttons.forEach { (button) in
            guard button !== sender else {
                return
            }
            button.setSelected(false, animated: true)
        }
        sender.setSelected(true, animated: true)
        if let item = sender.item,
           let items = items,
           items.contains(item) {
            delegate?.tabBar?(self, didSelect: item)
        }
    }

    func select(itemAt index: Int, animated: Bool = false) {
        guard index < buttons.count else {
            return
        }
        let selectedbutton = buttons[index]
        buttons.forEach { (button) in
            guard button !== selectedbutton else {
                return
            }
            button.setSelected(false, animated: false)
        }
        selectedbutton.setSelected(true, animated: false)
    }
}
