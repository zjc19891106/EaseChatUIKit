//
//  MessageAudioRecordView.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/29.
//

import UIKit

@objc open class MessageAudioRecordView: UIView {
    
    private var sendAction: ((URL,Int) -> ())?
    
    private var trashAction: (() -> ())?
    
    private var duration = 0 {
        willSet {
            self.playCount = newValue
        }
    }
    
    private var recordCount = 0 {
        willSet {
            DispatchQueue.main.async {
                if newValue > 50,newValue < 60 {
                    self.recordAlert.text = "\(60-newValue)s "+"remaining".chat.localize
                } else {
                    self.recordAlert.text = ""
                }
                if newValue > 0 {
                    self.recordIcon.setImage(nil, for: .normal)
                    self.recordIcon.setTitle("\(newValue)s", for: .normal)
                }
            }
        }
    }
    
    private var playCount = 0 {
        willSet {
            DispatchQueue.main.async {
                if newValue > 0 {
                    self.recordIcon.setImage(nil, for: .normal)
                    self.recordIcon.setTitle("\(newValue)s", for: .normal)
                }
            }
        }
    }
    
    private var timer: Timer?
    
    private let icon = UIImage(named: "mic_on", in: .chatBundle, with: nil)
    
    private let trashIcon = UIImage(named: "trash", in: .chatBundle, with: nil)
    
    private let sendIcon = UIImage(named: "send_audio", in: .chatBundle, with: nil)
    
    public private(set) lazy var recordCover: UIView = {
        UIView(frame: CGRect(x: self.frame.width/2.0-45, y: 60, width: 90, height: 68)).cornerRadius(.large).backgroundColor(UIColor.theme.primaryColor95)
    }()

    public private(set) lazy var recordIcon: RippleButton = {
        RippleButton(type: .custom).frame(CGRect(x: self.frame.width/2.0-35, y: 70, width: 72, height: 48)).cornerRadius(.large).backgroundColor(UIColor.theme.primaryColor5).textColor(UIColor.theme.neutralColor98, .normal).image(self.icon, .normal).addTargetFor(self, action: #selector(buttonAction), for: .touchUpInside)
    }()

    public private(set) lazy var recordTitle: UILabel = {
        UILabel(frame: CGRect(x: 100, y: self.recordIcon.frame.maxY+16, width: self.frame.width-200, height: 18)).font(UIFont.theme.labelMedium).textColor(UIColor.theme.neutralColor5).textAlignment(.center).backgroundColor(.clear).text("Record".chat.localize)
    }()
    
    public private(set) lazy var recordAlert: UILabel = {
        UILabel(frame: CGRect(x: 100, y: self.recordTitle.frame.maxY+8, width: self.frame.width-200, height: 16)).font(UIFont.theme.bodySmall).textColor(UIColor.theme.neutralColor5).textAlignment(.center).backgroundColor(.clear)
    }()
    
    public private(set) lazy var trash: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.recordIcon.frame.minX-96, y: 76, width: 36, height: 36)).backgroundColor(UIColor.theme.neutralColor9).cornerRadius(.large).image(self.trashIcon, .normal).addTargetFor(self, action: #selector(removeRecord), for: .touchUpInside)
    }()
    
    public private(set) lazy var send: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.recordIcon.frame.maxX+60, y: 76, width: 36, height: 36)).backgroundColor(UIColor.theme.primaryColor5).cornerRadius(.large).image(self.sendIcon, .normal).addTargetFor(self, action: #selector(sendAudio), for: .touchUpInside)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// Audio record view.
    /// - Parameters:
    ///   - frame: ``CGRect``
    ///   - sendClosure: Send closure,contain file url and audio duration.
    ///   - trashClosure: Trash closure.
    @objc public required convenience init(frame: CGRect,sendClosure: @escaping (URL,Int) -> (),trashClosure: @escaping () -> ()) {
        self.init(frame: frame)
        self.sendAction = sendClosure
        self.trashAction = trashClosure
        self.addSubViews([self.recordCover,self.recordIcon,self.recordTitle,self.recordAlert,self.trash,self.send])
        self.trash.isHidden = true
        self.send.isHidden = true
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildTimer() {
        self.timer = nil
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let `self` = self else { return }
            if self.duration <= 0 {
                if self.recordCount < 60 {
                    self.recordCount += 1
                } else {
                    self.stopRecord()
                }
            } else {
                if self.playCount > 1 {
                    self.playCount -= 1
                } else {
                    self.recordIcon.isSelected = false
                    self.stopPlay(send: false)
                }
            }
        }

        if let timer = self.timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    @objc private func buttonAction() {
        self.recordIcon.isSelected = !self.recordIcon.isSelected
        if self.duration > 0 {
            if self.recordIcon.isSelected {
                self.startPlay()
            } else {
                self.stopPlay(send: false)
            }
        } else {
            if self.recordCount <= 0 {
                self.startRecord()
            } else {
                self.stopRecord()
            }
        }
        
    }
    
    private func startRecord() {
        self.recordCount = 0
        self.buildTimer()
        self.recordTitle.text = "Recording".chat.localize
        AudioTools.shared.startRecording()
    }
    
    private func stopRecord() {
        self.recordAlert.text = nil
        self.trash.isHidden = false
        self.send.isHidden = false
        self.duration = self.recordCount
        self.recordCount = 0
        self.timer?.invalidate()
        self.recordTitle.text = "Play".chat.localize
        AudioTools.shared.stopRecording()
    }
    
    private func startPlay() {
        self.playCount = self.duration
        self.recordTitle.text = "Playing".chat.localize
        self.buildTimer()
        self.recordIcon.stopAnimation()
        AudioTools.shared.playRecording {
            
        }
        self.recordIcon.startAnimation()
    }
    
    private func stopPlay(send: Bool) {
        self.playCount = self.duration
        self.recordTitle.text = "Play"
        self.timer?.invalidate()
        AudioTools.shared.stopPlaying()
        self.recordIcon.stopAnimation()
    }
    
    @objc private func removeRecord() {
        self.recordAlert.text = nil
        AudioTools.shared.stopPlaying()
        self.recordIcon.stopAnimation()
        self.recordTitle.text = "Record".chat.localize
        self.duration = 0
        self.recordCount = 0
        self.playCount = 0
        self.recordIcon.setTitle(nil, for: .normal)
        self.recordIcon.setImage(self.icon, for: .normal)
        self.trash.isHidden = true
        self.send.isHidden = true
        if let url = AudioTools.shared.audioFileURL {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                consoleLogInfo("\(error.localizedDescription)", type: .error)
            }
        }
        self.trashAction?()
    }
    
    @objc private func sendAudio() {
        self.recordAlert.text = nil
        self.stopPlay(send: true)
        self.recordCount = 0
        self.playCount = 0
        if let url = AudioTools.shared.audioFileURL {
            self.sendAction?(url,self.duration)
        }
        self.duration = 0
        self.recordIcon.setTitle(nil, for: .normal)
        self.recordIcon.setImage(self.icon, for: .normal)
        self.trash.isHidden = true
        self.send.isHidden = true
        self.timer = nil
    }
}

extension MessageAudioRecordView: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.primaryColor98
        self.recordCover.backgroundColor(style == .dark ? UIColor.theme.primaryColor2:UIColor.theme.primaryColor95)
        self.recordIcon.backgroundColor(style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5)
        self.send.backgroundColor(style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5)
        self.trash.backgroundColor(style == .light ? UIColor.theme.neutralColor9:UIColor.theme.neutralColor2)
        if style == .dark {
            self.trashIcon?.withTintColor(UIColor.theme.neutralColor7)
        }
        self.trash.setImage(self.trashIcon, for: .normal)
    }
    
    
}

@objc open class RippleButton: UIButton {
    
    private weak var timer: Timer?
    
    var borderColor: UIColor = UIColor.theme.primaryColor9
    
    var borderWidth: CGFloat = 5.0
    
    var rippleRadius: CGFloat = 1.5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    private func setupUI() {
        self.borderColor = .clear
        self.borderWidth = 5.0
        updateUI()
    }

    private func updateUI() {
        self.layer.borderColor = self.borderColor.cgColor
        self.layer.borderWidth = self.borderWidth
    }


    @objc func startAnimation() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            self?.handleTimer()
        })
    }

    @objc func stopAnimation() {
        self.borderColor = .clear
        self.timer?.invalidate()
    }

    @objc private func handleTimer() {
        self.borderColor = Theme.style == .dark ? UIColor.theme.primaryColor2:UIColor.theme.primaryColor9
        generateRipples()
        self.perform(#selector(generateRipples), with: nil, afterDelay: 1)
    }

    @objc private func generateRipples() {
        let pathFrame = CGRect(x: -self.bounds.midX, y: -self.bounds.midY, width: self.bounds.size.width, height: self.bounds.size.height)
        let path = UIBezierPath(roundedRect: pathFrame, cornerRadius: self.layer.cornerRadius)
        let circleShape = CAShapeLayer()
        circleShape.path = path.cgPath
        circleShape.position = self.center
        circleShape.opacity = 0
        circleShape.fillColor = UIColor.clear.cgColor
        circleShape.strokeColor = self.borderColor.cgColor
        circleShape.lineWidth = self.borderWidth
        self.superview?.layer.addSublayer(circleShape)
        
        let scaleAnimation = CABasicAnimation()
        scaleAnimation.keyPath = "transform.scale"
        scaleAnimation.toValue = NSValue(caTransform3D: CATransform3DMakeScale(self.rippleRadius, self.rippleRadius, 1.0))
        
        let alphaAnimation = CABasicAnimation()
        alphaAnimation.keyPath = "opacity"
        alphaAnimation.fromValue = 1
        alphaAnimation.toValue = 0
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 2
        animationGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animationGroup.animations = [scaleAnimation, alphaAnimation]
        circleShape.add(animationGroup, forKey: nil)
    }

    func setBorderColor(borderColor: UIColor) {
        self.borderColor = borderColor
        self.updateUI()
    }

    func setBorderWidth(borderWidth: CGFloat) {
        self.borderWidth = borderWidth
        self.updateUI()
    }
}
