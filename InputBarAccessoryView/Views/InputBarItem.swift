//
//  InputBarItem.swift
//  InputBarAccessoryView
//
//  Copyright © 2017 Nathan Tannar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Nathan Tannar on 8/18/17.
//

import UIKit

open class InputBarButtonItem: UIButton {
    
    public enum Spacing {
        case fixed(CGFloat)
        case flexible
        case none
    }
    
    public typealias InputBarButtonItemAction = ((InputBarButtonItem) -> Void)?
    
    // MARK: - Properties
    
    /// Set automatically when using the InputBarAccessoryView method 'setStackViewItems'
    open weak var inputBarAccessoryView: InputBarAccessoryView?
    
    public var spacing: Spacing = .none {
        didSet {
            switch spacing {
            case .flexible:
                setContentHuggingPriority(1, for: .horizontal)
            case .fixed:
                setContentHuggingPriority(1000, for: .horizontal)
            case .none:
                setContentHuggingPriority(500, for: .horizontal)
            }
        }
    }
    
    /// When not nil this size overrides the intrinsicContentSize
    open var size: CGSize? = CGSize(width: 20, height: 20) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        var contentSize = size ?? super.intrinsicContentSize
        switch spacing {
        case .fixed(let width):
            contentSize.width += width
        default:
            break
        }
        return contentSize
    }
    
    /// The title for the UIControlState.normal
    open var title: String? {
        get {
            return title(for: .normal)
        }
        set {
            setTitle(newValue, for: .normal)
        }
    }
    
    /// The image for the UIControlState.normal
    open var image: UIImage? {
        get {
            return image(for: .normal)
        }
        set {
            setImage(newValue, for: .normal)
        }
    }
    
    open override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            super.isHighlighted = newValue
            if newValue {
                onSelectedAction?(self)
            } else {
                onDeselectedAction?(self)
            }
        }
    }
    
    open override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set {
            super.isEnabled = newValue
            if newValue {
                onEnabledAction?(self)
            } else {
                onDisabledAction?(self)
            }
        }
    }
    
    // MARK: - Hooks
    
    private var onTouchUpInsideAction: InputBarButtonItemAction
    private var onKeyboardEditingBeginsAction: InputBarButtonItemAction
    private var onKeyboardEditingEndsAction: InputBarButtonItemAction
    private var onKeyboardSwipeGestureAction: ((InputBarButtonItem, UISwipeGestureRecognizer) -> Void)?
    private var onTextViewDidChangeAction: ((InputBarButtonItem, InputTextView) -> Void)?
    private var onSelectedAction: InputBarButtonItemAction
    private var onDeselectedAction: InputBarButtonItemAction
    private var onEnabledAction: InputBarButtonItemAction
    private var onDisabledAction: InputBarButtonItemAction
    
    // MARK: - Initialization
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setup() {
        contentVerticalAlignment = .center
        contentHorizontalAlignment = .center
        imageView?.contentMode = .scaleAspectFit
        setContentHuggingPriority(500, for: .horizontal)
        setContentHuggingPriority(500, for: .vertical)
        setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1), for: .normal)
        setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 0.3), for: .highlighted)
        setTitleColor(.lightGray, for: .disabled)
        adjustsImageWhenHighlighted = false
        addTarget(self, action: #selector(InputBarButtonItem.touchUpInsideAction), for: .touchUpInside)
    }
    
    // MARK: - Hook Setup Methods
    
    @discardableResult
    open func configure(_ setup: InputBarButtonItemAction) -> Self {
        setup?(self)
        return self
    }
    
    @discardableResult
    open func onKeyboardEditingBegins(_ action: InputBarButtonItemAction) -> Self {
        onKeyboardEditingBeginsAction = action
        return self
    }
    
    @discardableResult
    open func onKeyboardEditingEnds(_ action: InputBarButtonItemAction) -> Self {
        onKeyboardEditingEndsAction = action
        return self
    }
    
    @discardableResult
    open func onKeyboardSwipeGesture(_ action: @escaping (_ item: InputBarButtonItem, _ gesture: UISwipeGestureRecognizer) -> Void) -> Self {
        onKeyboardSwipeGestureAction = action
        return self
    }
    
    @discardableResult
    open func onTextViewDidChange(_ action: @escaping (_ item: InputBarButtonItem, _ textView: InputTextView) -> Void) -> Self {
        onTextViewDidChangeAction = action
        return self
    }
    
    @discardableResult
    open func onTouchUpInside(_ action: InputBarButtonItemAction) -> Self {
        onTouchUpInsideAction = action
        return self
    }
    
    @discardableResult
    open func onSelected(_ action: InputBarButtonItemAction) -> Self {
        onSelectedAction = action
        return self
    }
    
    @discardableResult
    open func onDeselected(_ action: InputBarButtonItemAction) -> Self {
        onDeselectedAction = action
        return self
    }
    
    @discardableResult
    open func onEnabled(_ action: InputBarButtonItemAction) -> Self {
        onEnabledAction = action
        return self
    }
    
    @discardableResult
    open func onDisabled(_ action: InputBarButtonItemAction) -> Self {
        onDisabledAction = action
        return self
    }
    
    // MARK: - Hook Executors
    
    public func textViewDidChangeAction(with textView: InputTextView) {
        onTextViewDidChangeAction?(self, textView)
    }
    
    public func keyboardSwipeGestureAction(with gesture: UISwipeGestureRecognizer) {
        onKeyboardSwipeGestureAction?(self, gesture)
    }
    
    public func keyboardEditingEndsAction() {
        onKeyboardEditingEndsAction?(self)
    }
    
    public func keyboardEditingBeginsAction() {
        onKeyboardEditingBeginsAction?(self)
    }
    
    public func touchUpInsideAction() {
        onTouchUpInsideAction?(self)
    }
    
    // MARK: - Static vars
    
    open static var flexibleSpace: InputBarButtonItem {
        let item = InputBarButtonItem()
        item.size = .zero
        item.spacing = .flexible
        return item
    }
    
    open static func fixedSpace(_ width: CGFloat) -> InputBarButtonItem {
        let item = InputBarButtonItem()
        item.size = .zero
        item.spacing = .fixed(width)
        return item
    }
}
