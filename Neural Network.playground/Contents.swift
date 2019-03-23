//: DISCLAIMER: PLEASE WAIT 1 SECOND AFTER INTERACTING WITH CERTAIN BUTTONS. THIS IS A BIG PROGRAM BUILT ON A VERY SIMPLE APPLICATION

//: Playground - noun: a place where people can play
//: "We're here to put a dent in the universe. Otherwise, why even be here?" ~Steve Jobs

//: Main Color :=: UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1)

import UIKit
import PlaygroundSupport
import Vision
import CoreML

class MainView: UIView, ChromaColorPickerDelegate, UITextFieldDelegate {
    
    let sections = ["Numbers", "Names", "Sentences", "Doodles"]
    
    var dev_mode : Bool = false
    
    var menuActivated : Bool = false
    var menu_activated_count : Int = 0
    var currentSection : Int = 0
    var settings_sections = ["paint_icon.png", "erase_icon.png", "restart_icon.png", "RGB_icon.png", "line_thickness_icon.png", "fill_icon.png"]
    
    let main_icon : UIImageView = UIImageView()
    let main_title : UILabel = UILabel()
    let main_loading_bar : LinearProgressView = LinearProgressView()
    let welcome : UILabel = UILabel()
    let welcome_sub : UILabel = UILabel()
    let activator_message : UILabel = UILabel()
    let sections_container : UIView = UIView()
    let main_underline : UIView = UIView()
    let current_title : UILabel = UILabel()
    let drawing_container : SmoothCurvedLinesView = SmoothCurvedLinesView()
    let opening_quote : UILabel = UILabel()
    let citation : UILabel = UILabel()
    let menu_container : UIView = UIView()
    let settings_switcher : UIImageView = UIImageView()
    let settings_bg : UIVisualEffectView = UIVisualEffectView()
    let dismissIntro : UIImageView = UIImageView()
    let articlesBG : UIVisualEffectView = UIVisualEffectView()
    let startBtn : UIButton = UIButton()
    let stopBtn : UIButton = UIButton()
    
    var model: VNCoreMLModel!
    var request = [VNRequest]() // holds Image Classification Request
    var requests = [VNRequest]() // holds Image Classification Request, but different
    var output : String = "" // the output used by both the number recognition and the doodle recognition
    var presentationImages : [UIImage] = []
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        loadModel()
        setupVision()
        
        main_icon.frame = CGRect(x: 200, y: 100, width: 200, height: 200)
        main_icon.image = UIImage(named: "main_icon.png")
        main_icon.backgroundColor = UIColor.clear
        main_icon.contentMode = UIView.ContentMode.scaleAspectFit
        main_icon.alpha = 0
        main_icon.center = self.center
        
        main_title.frame = CGRect(x: 200, y: (main_icon.frame.origin.y + main_icon.frame.size.height) + 25, width: 400, height: 45)
        main_title.text = "Neural Networks"
        main_title.textColor = UIColor.white
        main_title.font = main_title.font.withSize(45)
        main_title.set(textColor: UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1), range: NSMakeRange(0, 6))
        main_title.backgroundColor = UIColor.clear
        main_title.alpha = 0
        main_title.textAlignment = NSTextAlignment.center
        main_title.center.x = self.center.x
        
        main_loading_bar.frame.size = CGSize(width: 400, height: 35)
        main_loading_bar.center.x = self.center.x
        main_loading_bar.frame.origin.y = (main_title.frame.origin.y + main_title.frame.size.height) + 50
        main_loading_bar.barColor = UIColor.gray
        main_loading_bar.trackColor = UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1)
        main_loading_bar.barInset = 10
        main_loading_bar.maximumValue = 100
        main_loading_bar.minimumValue = 0
        main_loading_bar.isCornersRounded = true
        main_loading_bar.alpha = 0
        main_loading_bar.animationDuration = 5
        
        opening_quote.frame = CGRect(x: 100, y: 200, width: 524, height: 300)
        opening_quote.textAlignment = NSTextAlignment.center
        opening_quote.textColor = UIColor.white
        opening_quote.text = "\"We're here to put a dent in the universe. Otherwise why even be here?\""
        opening_quote.numberOfLines = 3
        opening_quote.alpha = 0
        opening_quote.font = opening_quote.font.withSize(30)
        
        citation.frame = CGRect(x: 560, y: 539, width: 300, height: 50)
        citation.text = "~ Steve Jobs"
        citation.textColor = UIColor.white
        citation.set(textColor: UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1), range: NSMakeRange(1, 11))
        citation.alpha = 0
        citation.font = citation.font.withSize(30)
        
        welcome.frame = CGRect(x: 25, y: 300, width: 975, height: 50)
        welcome.text = "Welcome,"
        welcome.textColor = UIColor.white
        welcome.font = welcome.font.withSize(30)
        welcome.alpha = 0
        
        welcome_sub.frame = CGRect(x: 25, y: 350, width: 550, height: 100)
        welcome_sub.text = "This is a collection of interactive Neural Network systems that have been built, trained and tested with the CoreML 2.0 framework. Articles are included to explain how a Neural Network works, along with other resources."
        welcome_sub.textColor = UIColor.white
        welcome_sub.numberOfLines = 4
        welcome_sub.alpha = 0
        
        activator_message.frame = CGRect(x: 0, y: 20, width: 250, height: 25)
        activator_message.center.x = self.center.x
        activator_message.textColor = UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1)
        activator_message.font = activator_message.font.withSize(20)
        activator_message.text = "Please Wait..."
        activator_message.textAlignment = NSTextAlignment.center
        activator_message.alpha = 0
        
        sections_container.frame = CGRect(x: 0, y: 20, width: CGFloat(sections.count * 75), height: 40)
        sections_container.layer.cornerRadius = sections_container.frame.size.height / 2
        sections_container.backgroundColor = UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1)
        sections_container.center.x = self.center.x
        sections_container.transform = CGAffineTransform(scaleX: 0, y: 1)
        
        for i in 0..<sections.count {
            let section_portion = UIImageView(frame: CGRect(x: i * 75, y: 0, width: 75, height: 40))
            section_portion.backgroundColor = UIColor.clear
            section_portion.image = UIImage(named: sections[i] + "_img.png")
            section_portion.contentMode = UIView.ContentMode.scaleAspectFit
            if i != 0 {
                section_portion.alpha = 0.75
            }
            self.sections_container.addSubview(section_portion)
        }
        
        main_underline.frame = CGRect(x: 0, y: 65, width: 40, height: 5)
        main_underline.backgroundColor = UIColor.white
        main_underline.layer.cornerRadius = main_underline.frame.size.height / 2
        main_underline.center.x = sections_container.subviews[0].center.x + 230
        main_underline.transform = CGAffineTransform(scaleX: 0, y: 1)
        
        current_title.frame = CGRect(x: 16, y: 100, width: 500, height: 75)
        current_title.text = sections[currentSection]
        current_title.textColor = UIColor.white
        current_title.font = current_title.font.withSize(75)
        current_title.alpha = 0
        
        drawing_container.frame = CGRect(x: 16, y: 180, width: self.frame.size.width - 32, height: 568)
        drawing_container.backgroundColor = UIColor.black
        drawing_container.layer.borderColor = UIColor.white.cgColor
        drawing_container.layer.borderWidth = 5
        drawing_container.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        settings_switcher.frame = CGRect(x: 700, y: 114, width: 50, height: 50)
        settings_switcher.contentMode = UIView.ContentMode.scaleAspectFit
        settings_switcher.image = UIImage(named: "settings_icon.png")
        settings_switcher.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        menu_container.frame = CGRect(x: self.frame.size.width - 60, y: 15, width: 50, height: 50)
        menu_container.backgroundColor = UIColor.clear
        menu_container.alpha = 0
        
        startBtn.frame = CGRect(x: 640, y: self.drawing_container.frame.origin.y, width: 50, height: 50)
        startBtn.backgroundColor = UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1)
        startBtn.layer.cornerRadius = 10
        startBtn.layer.masksToBounds = true
        startBtn.alpha = 0
        startBtn.addTarget(self, action: #selector(self.runAlgorithimProcess(_:)), for: UIControl.Event.touchUpInside)
        startBtn.setImage(UIImage(named: "play_icon.png"), for: UIControl.State.normal)
        
        stopBtn.frame = CGRect(x: 580, y: self.drawing_container.frame.origin.y, width: 50, height: 50)
        stopBtn.backgroundColor = UIColor.lightGray
        stopBtn.layer.cornerRadius = 10
        stopBtn.layer.masksToBounds = true
        stopBtn.alpha = 0
        stopBtn.addTarget(self, action: #selector(self.cancelAlgorithimProcess(_:)), for: UIControl.Event.touchUpInside)
        stopBtn.setImage(UIImage(named: "pause_icon.png"), for: UIControl.State.normal)
        
        for i in 0...2 {
            var y = (CGFloat(i) * 7.5) * 2
            if i == 0 {
                y = CGFloat(i)
            }
            menu_container.addSubview(UIView(frame: CGRect(x: 0, y: y, width: 50, height: 5)))
            menu_container.subviews[i].layer.cornerRadius = 2.5
            menu_container.subviews[i].backgroundColor = UIColor.white
        }
        
        self.addSubview(main_icon)
        self.addSubview(main_title)
        self.addSubview(main_loading_bar)
        self.addSubview(opening_quote)
        self.addSubview(citation)
        self.addSubview(welcome)
        self.addSubview(welcome_sub)
        self.addSubview(activator_message)
        self.addSubview(sections_container)
        self.addSubview(main_underline)
        self.addSubview(current_title)
        self.addSubview(drawing_container)
        self.addSubview(settings_switcher)
        self.addSubview(menu_container)
        
        self.insertSubview(startBtn, belowSubview: drawing_container)
        self.insertSubview(stopBtn, belowSubview: drawing_container)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            if self.dev_mode == false {
                UIView.animate(withDuration: 0.5, delay: 1.0, options: UIView.AnimationOptions.curveEaseInOut, animations: { () -> Void in
                    self.main_icon.alpha = 1
                    self.main_title.alpha = 1
                    self.main_loading_bar.alpha = 1
                }, completion: { (_) in
                    self.main_loading_bar.setProgress(self.main_loading_bar.maximumValue, animated: true, completion: {_ in
                        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                            self.main_icon.alpha = 0
                            self.main_title.alpha = 0
                            self.main_loading_bar.alpha = 0
                        }, completion: nil)
                        UIView.animate(withDuration: 0.75, delay: 0.6, options: UIView.AnimationOptions.curveEaseInOut, animations: { () -> Void in
                            self.opening_quote.alpha = 1
                            self.opening_quote.frame.origin.y += 25
                            self.citation.alpha = 1
                        }, completion: { (_) in
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0, execute: {
                                UIView.animate(withDuration: 0.75, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                                    self.opening_quote.alpha = 0
                                    self.opening_quote.frame.origin.y += 25
                                    self.citation.alpha = 0
                                }, completion: { (_) in
                                    UIView.animate(withDuration: 0.75, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: { () -> Void in
                                        self.welcome.alpha = 1
                                        self.welcome_sub.alpha = 1
                                        self.welcome.frame.origin.y += 25
                                        self.welcome_sub.frame.origin.y += 25
                                    }, completion: { (finished: Bool) in
                                        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat,.autoreverse], animations: {
                                            self.activator_message.alpha = 1.0
                                        }, completion: nil)
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                                            for i in 1...43 {
                                                if i < 10 {
                                                    self.presentationImages.append(UIImage(named: "Presentation/Presentation.00\(i).png")!)
                                                } else {
                                                    self.presentationImages.append(UIImage(named: "Presentation/Presentation.0\(i).png")!)
                                                    if i == 43 {
                                                        self.activator_message.text = "Touch Anywhere To Begin!"
                                                    }
                                                }
                                            }
                                            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.show_credits(_:))))
                                        })
                                    })
                                })
                            })
                        })
                    })
                })
            } else {
                self.startProgram()
            }
        }
    }
    
    @objc func show_credits(_ sender: UITapGestureRecognizer) {
        if activator_message.text! == "Touch Anywhere To Begin!" {
            self.removeGestureRecognizer(self.gestureRecognizers![self.gestureRecognizers!.count - 1])
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.welcome.alpha = 0
                self.welcome_sub.alpha = 0
                self.welcome.frame.origin.y += 25
                self.welcome_sub.frame.origin.y += 25
                self.activator_message.alpha = 0
            }, completion: { (finished: Bool) in
                let credits = UILabel(frame: self.bounds)
                credits.text = "This is the product of Ozan Mirza exclusive to WWDC 2019"
                credits.textColor = UIColor.white
                credits.set(textColor: UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1), range: NSMakeRange(23, 10))
                credits.set(textColor: UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1), range: NSMakeRange(47, 9))
                credits.font = credits.font.withSize(25)
                credits.alpha = 0
                credits.textAlignment = NSTextAlignment.center
                
                let github_tag = UILabel(frame: CGRect(x: 0, y: 180, width: self.frame.size.width, height: 45))
                github_tag.textAlignment = NSTextAlignment.center
                github_tag.textColor = UIColor.white
                github_tag.text = "Built with ❤️ and"
                github_tag.backgroundColor = UIColor.clear
                github_tag.font = github_tag.font.withSize(45)
                github_tag.set(textColor: UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1), range: NSMakeRange(0, 5))
                github_tag.alpha = 0
                
                let swift_logo = UIImageView(frame: CGRect(x: 0, y: github_tag.frame.origin.y + 55, width: 256, height: 256))
                swift_logo.image = UIImage(named: "swift_icon.png")
                swift_logo.center.x = self.center.x
                swift_logo.alpha = 0
                let swift_comma = UILabel(frame: CGRect(x: swift_logo.frame.origin.x + 256, y: swift_logo.frame.origin.y + 200, width: 50, height: 56))
                swift_comma.textColor = UIColor.white
                swift_comma.text = ","
                swift_comma.font = swift_comma.font.withSize(50)
                swift_comma.alpha = 0
                
                let coreML_logo = UIImageView(frame: CGRect(x: 0, y: swift_logo.frame.origin.y + 256, width: 256, height: 256))
                coreML_logo.image = UIImage(named: "CoreML.png")
                coreML_logo.center.x = self.center.x
                coreML_logo.alpha = 0
                
                self.addSubview(swift_logo)
                self.addSubview(swift_comma)
                self.addSubview(github_tag)
                self.addSubview(credits)
                self.addSubview(coreML_logo)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                        credits.alpha = 1.0
                    }, completion: nil)
                })
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                    UIView.animate(withDuration: 0.5, delay: 1.5, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                        credits.alpha = 0.0
                    }, completion: nil)
                })
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                    UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                        github_tag.alpha = 1.0
                        swift_logo.alpha = 1.0
                        swift_comma.alpha = 1.0
                        coreML_logo.alpha = 1.0
                    }, completion: nil)
                })
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.5, execute: {
                    UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                        github_tag.alpha = 0.0
                        swift_logo.alpha = 0.0
                        swift_comma.alpha = 0.0
                        coreML_logo.alpha = 0.0
                    }, completion: { (finished: Bool) in
                        self.startProgram()
                    })
                })
            })
        }
    }
    
    func startProgram() {
        drawing_container.restartDrawingView()
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.sections_container.transform = CGAffineTransform.identity
            self.main_underline.transform = CGAffineTransform.identity
            self.current_title.alpha = 1
            self.menu_container.alpha = 1
            self.drawing_container.transform = CGAffineTransform.identity
        }, completion: { (finished: Bool) in
            self.startBtn.alpha = 1
            self.stopBtn.alpha = 1
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.settings_switcher.transform = CGAffineTransform.identity
                self.startBtn.frame.origin.y = self.settings_switcher.frame.origin.y
                self.stopBtn.frame.origin.y = self.settings_switcher.frame.origin.y
            }, completion: { (_) in
                self.introduceTutorial()
            })
        })
    }
    
    func introduceTutorial() {
        let bg = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
        bg.frame = self.bounds
        bg.alpha = 0
        self.addSubview(bg)
        bg.contentView.addSubview(UIView(frame: CGRect(x: 150, y: -464, width: 464, height: 464)))
        bg.contentView.subviews[0].layer.cornerRadius = 20
        bg.contentView.subviews[0].backgroundColor = UIColor.darkGray
        dismissIntro.frame = CGRect(x: 150, y: 616, width: 464, height: 35)
        dismissIntro.backgroundColor = UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1)
        dismissIntro.layer.cornerRadius = dismissIntro.frame.size.height / 2
        dismissIntro.layer.masksToBounds = true
        dismissIntro.contentMode = UIView.ContentMode.scaleAspectFit
        dismissIntro.image = UIImage(named: "checkmark_icon.png")
        dismissIntro.transform = CGAffineTransform(scaleX: 0, y: 0)
        bg.contentView.addSubview(dismissIntro)
        let ttl = UILabel(frame: CGRect(x: 16, y: 20, width: 448, height: 50))
        ttl.font = ttl.font.withSize(45)
        ttl.text = "How To Use"
        ttl.textColor = UIColor.white
        ttl.backgroundColor = UIColor.clear
        ttl.textAlignment = NSTextAlignment.center
        bg.contentView.subviews[0].addSubview(ttl)
        let info = UITextView(frame: CGRect(x: 16, y: 100, width: 432, height: 600))
        info.textColor = UIColor.white
        info.isEditable = false
        info.backgroundColor = UIColor.clear
        info.text = "   This is a playground that uses Neural Network logic to decipher what you draw on the canvas behind, or right on the text field. There are " + String(sections.count) + " sections to choose from. The first one uses the MNIST model to detect the number that you've drawn. The second one uses the NamesDT model to detect the gender of the name that you typed. The third one uses the SentimentPolarity model to detect the sentiment of your typed sentence (happy, neutral, or sad). The fourth uses a DoodleClassifier model with local data from the GoogleQuickDraw dataset to identify your sketch of a cat, airplane, or rainbow. To run the recognition process, press the play button. The settings gear has tools such as painting brush to start drawing and eraser to clear the canvas. If you erased, and you want to switch back to drawing mode, reclick the settings gear and a new button will take it's place."
        info.font = info.font?.withSize(17)
        bg.contentView.subviews[0].addSubview(info)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 5, initialSpringVelocity: 10, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            bg.alpha = 1
            bg.contentView.subviews[0].frame.origin.y = bg.contentView.subviews[0].frame.origin.x
            bg.contentView.subviews[1].transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @objc func runAlgorithimProcess(_ sender: UIButton!) {
        if drawing_container.snapshotImage == nil {
            displayInfoTip(message: "Error: The canvas can't be empty, please draw something first!")
        } else {
            drawing_container.isEnabled = false
            sections_container.isUserInteractionEnabled = false
            let bg = UIVisualEffectView(frame: self.bounds)
            bg.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            bg.alpha = 0
            self.addSubview(bg)
            startBtn.removeFromSuperview()
            stopBtn.removeFromSuperview()
            self.insertSubview(startBtn, aboveSubview: bg)
            self.insertSubview(stopBtn, aboveSubview: bg)
            let preview = UIView(frame: CGRect(x: 100, y: 0, width: self.frame.size.width - 200, height: 500))
            preview.layer.cornerRadius = 20
            preview.backgroundColor = UIColor.lightGray
            preview.center = self.center
            preview.alpha = 0
            let ttl = UILabel(frame: CGRect(x: 16, y: 20, width: preview.frame.size.width - 32, height: 50))
            ttl.text = "Finding \(sections[currentSection].dropLast())..."
            ttl.textColor = UIColor.white
            ttl.textAlignment = NSTextAlignment.center
            ttl.font = ttl.font.withSize(45)
            preview.addSubview(ttl)
            let result = UILabel(frame: CGRect(x: 16, y: preview.frame.size.height - 70, width: preview.frame.size.width - 32, height: 50))
            result.textColor = UIColor.white
            result.alpha = 0
            result.textAlignment = NSTextAlignment.center
            result.font = result.font.withSize(35)
            preview.addSubview(result)
            let neuralNetwork = NeuralNetwork(frame: CGRect(x: 16, y: 400, width: self.frame.size.width - 32, height: self.frame.size.height - 420))
            preview.addSubview(neuralNetwork)
            neuralNetwork.frame.origin = CGPoint(x: -90, y: 75)
            bg.contentView.addSubview(preview)
            if self.currentSection == 0 {
                self.recognizeDigit(sender)
            } else if self.currentSection == 3 {
                self.recognizeDoodle(sender)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                UIView.animate(withDuration: 0.5, animations: {
                    bg.alpha = 1
                    self.settings_switcher.alpha = 0.5
                    self.startBtn.backgroundColor = UIColor.lightGray
                    self.stopBtn.backgroundColor = UIColor(red: (244 / 255), green: (66 / 255), blue: (66 / 255), alpha: 1)
                    self.startBtn.frame.origin.y = 20
                    self.stopBtn.frame.origin.y = 20
                    preview.alpha = 1
                }) { (finished: Bool) in
                    neuralNetwork.render(shouldLink: true)
                    result.text = "Found the \(self.current_title.text!.dropLast()): \(self.output)"
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                        bg.contentView.addSubview(SAConfettiView(frame: bg.bounds))
                        (bg.contentView.subviews.last! as? SAConfettiView)?.startConfetti()
                        UIView.animate(withDuration: 0.5, animations: {
                            result.alpha = 1
                        })
                    })
                }
            }
        }
    }
    
    @objc func cancelAlgorithimProcess(_ sender: UIButton!) {
        if sender.backgroundColor != UIColor.lightGray {
            UIView.animate(withDuration: 0.5, animations: {
                self.settings_switcher.alpha = 1
                self.startBtn.backgroundColor = UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1)
                self.stopBtn.backgroundColor = UIColor.lightGray
                self.subviews[self.subviews.count - 3].alpha = 0
                self.startBtn.frame.origin.y = self.settings_switcher.frame.origin.y
                self.stopBtn.frame.origin.y = self.settings_switcher.frame.origin.y
            }) { (finished: Bool) in
                self.drawing_container.isEnabled = true
                self.sections_container.isUserInteractionEnabled = true
                self.stopBtn.setImage(UIImage(named: "pause_icon.png"), for: UIControl.State.normal)
                self.subviews[self.subviews.count - 3].removeFromSuperview()
                self.stopBtn.removeFromSuperview()
                self.startBtn.removeFromSuperview()
                self.insertSubview(self.stopBtn, belowSubview: self.drawing_container)
                self.insertSubview(self.startBtn, belowSubview: self.drawing_container)
            }
        }
    }
    
    @objc func dismissSettingsView(_ sender: UIButton!) {
        UIView.animate(withDuration: 0.7, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.subviews.last!.alpha = 0
        }, completion: { (_) in
            self.settings_bg.contentView.subviews.forEach({ $0.removeFromSuperview() })
            self.settings_bg.removeFromSuperview()
        })
    }
    
    @available(iOS 11.0, *)
    func loadModel() {
        // load MNIST model for the use with the Vision framework
        guard let visionModel = try? VNCoreMLModel(for: DoodleClassifier().model) else {fatalError("can not load Vision ML model")}
        
        // create a classification request and tell it to call handleClassification once its done
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: self.handleDoodle)
        
        self.request = [classificationRequest] // assigns the classificationRequest to the global requests array
    }
    
    @available(iOS 11.0, *)
    func handleDoodle(request:VNRequest, error:Error?) {
        guard let observations = request.results else {print("no results"); return}
        
        // process the ovservations
        var classifications = observations
            .compactMap({$0 as? VNClassificationObservation}) // cast all elements to VNClassificationObservation objects
            .filter({$0.confidence > 0.5}) // only choose observations with a confidence of more than 80%
            .map({$0.identifier}) // only choose the identifier string to be placed into the classifications array
        
        DispatchQueue.main.async {
            self.stopBtn.setImage(UIImage(named: "stop_icon.png"), for: UIControl.State.normal)
            if let range = classifications[0].range(of: "output_") {
                classifications[0].removeSubrange(range)
            }
            self.output = classifications[0].capitalizingFirstLetter()
        }
    }
    
    @available(iOS 11.0, *)
    func recognizeDoodle(_ sender: Any) {
        let image = drawing_container.snapshotImage! // get UIImage from CanvasView
        let scaledImage = scaleImage(image: image, toSize: CGSize(width: 28, height: 28)) // scale the image to the required size of 28x28 for better recognition results
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: scaledImage.cgImage!, options: [:]) // create a handler that should perform the vision request
        
        do {
            try imageRequestHandler.perform(self.request)
        } catch let error as NSError {
            fatalError(error.localizedFailureReason!)
        }
        
    }
    
    @available(iOS 11.0, *)
    func setupVision() {
        // load MNIST model for the use with the Vision framework
        guard let visionModel = try? VNCoreMLModel(for: MNIST().model) else {fatalError("can not load Vision ML model")}

        // create a classification request and tell it to call handleClassification once its done
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: self.handleClassification)

        self.requests = [classificationRequest] // assigns the classificationRequest to the global requests array
    }
    
    @available(iOS 11.0, *)
    func handleClassification (request:VNRequest, error:Error?) {
        guard let observations = request.results else {print("no results"); return}
        
        // process the ovservations
        let classifications = observations
            .compactMap({$0 as? VNClassificationObservation}) // cast all elements to VNClassificationObservation objects
            .filter({$0.confidence > 0.8}) // only choose observations with a confidence of more than 80%
            .map({$0.identifier}) // only choose the identifier string to be placed into the classifications array
        
        DispatchQueue.main.async {
            self.stopBtn.setImage(UIImage(named: "stop_icon.png"), for: UIControl.State.normal)
            self.output = classifications[0]
        }
    }
    
    @available(iOS 11.0, *)
    func recognizeDigit(_ sender: Any) {
        let image = drawing_container.snapshotImage! // get UIImage from CanvasView
        let scaledImage = scaleImage(image: image, toSize: CGSize(width: 28, height: 28)) // scale the image to the required size of 28x28 for better recognition results
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: scaledImage.cgImage!, options: [:]) // create a handler that should perform the vision request
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch let error as NSError {
            fatalError(error.localizedFailureReason!)
        }
        
    }
    
    // scales any UIImage to a desired target size
    func scaleImage (image:UIImage, toSize size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func displayErrorAndTip(errorMessage: String, tipMessage: String) {
        let info = UIView(frame: CGRect(x: 16, y: self.frame.size.height, width: self.drawing_container.frame.size.width - 32, height: 50))
        info.backgroundColor = UIColor.lightGray
        info.layer.cornerRadius = info.frame.size.height / 2
        self.drawing_container.addSubview(info)
        let closeInfo = UIButton(frame: CGRect(x: info.frame.size.width - 50, y: 12.5, width: 25, height: 25))
        closeInfo.setImage(UIImage(named: "cancel_icon.png"), for: UIControl.State.normal)
        closeInfo.backgroundColor = UIColor.clear
        closeInfo.addTarget(self, action: #selector(self.removeTip(_:)), for: UIControl.Event.touchUpInside)
        info.addSubview(closeInfo)
        let infoLbl = UILabel(frame: CGRect(x: 16, y: 0, width: info.frame.size.width - 66, height: info.frame.size.height))
        infoLbl.text = errorMessage
        infoLbl.textColor = UIColor.white
        infoLbl.set(textColor: UIColor(red: (244 / 255), green: (66 / 255), blue: (66 / 255), alpha: 1), range: NSMakeRange(0, 6))
        info.addSubview(infoLbl)
        UIView.animate(withDuration: 0.5) {
            info.frame.origin.y = self.drawing_container.frame.size.height - 70
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.displayInfoTip(message: tipMessage)
            UIView.animate(withDuration: 0.5, animations: {
                info.frame.origin.y -= 70
            })
        }
    }
    
    func displayInfoTip(message: String) {
        let info = UIView(frame: CGRect(x: 16, y: self.frame.size.height, width: self.drawing_container.frame.size.width - 32, height: 50))
        info.backgroundColor = UIColor.lightGray
        info.layer.cornerRadius = info.frame.size.height / 2
        self.drawing_container.addSubview(info)
        let closeInfo = UIButton(frame: CGRect(x: info.frame.size.width - 50, y: 12.5, width: 25, height: 25))
        closeInfo.setImage(UIImage(named: "cancel_icon.png"), for: UIControl.State.normal)
        closeInfo.backgroundColor = UIColor.clear
        closeInfo.addTarget(self, action: #selector(self.removeTip(_:)), for: UIControl.Event.touchUpInside)
        info.addSubview(closeInfo)
        let infoLbl = UILabel(frame: CGRect(x: 16, y: 0, width: info.frame.size.width - 66, height: info.frame.size.height))
        infoLbl.text = message
        infoLbl.textColor = UIColor.white
        infoLbl.set(textColor: UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1), range: NSMakeRange(0, 4))
        info.addSubview(infoLbl)
        UIView.animate(withDuration: 0.5) {
            info.frame.origin.y = self.drawing_container.frame.size.height - 70
        }
    }
    
    @objc func showChromaScale(_ sender: UIButton!) {
        let neatColorPicker = ChromaColorPicker(frame: CGRect(x: (self.frame.size.width / 2) - 150, y: -300, width: 300, height: 300))
        neatColorPicker.padding = 5
        neatColorPicker.stroke = 3
        neatColorPicker.delegate = self
        neatColorPicker.hexLabel.textColor = UIColor.white
        neatColorPicker.backgroundColor = UIColor.lightGray
        neatColorPicker.layer.cornerRadius = 20
        neatColorPicker.layer.masksToBounds = true
        
        self.settings_bg.contentView.addSubview(neatColorPicker)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.settings_bg.contentView.subviews[self.settings_bg.contentView.subviews.count - 2].alpha = 0
        }, completion: { (_) in
            UIView.animate(withDuration: 0.7, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                sender.superview?.frame.origin.y = self.frame.size.height
                neatColorPicker.center = self.center
            }, completion: { (_) in
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                    self.settings_bg.contentView.subviews[self.settings_bg.contentView.subviews.count - 2].alpha = 1
                    self.settings_bg.contentView.subviews[self.settings_bg.contentView.subviews.count - 2].frame = CGRect(x: (self.frame.size.width / 2) - 150, y: (self.frame.size.height / 2) + 152, width: 300, height: 35)
                }, completion: nil)
            })
        })
    }
    
    @objc func activateEraserOnCanvas(_ sender: UIButton!) {
        if settings_sections[1] == "erase_icon.png" {
            self.drawing_container.strokeColor = self.drawing_container.backgroundColor!
            self.drawing_container.lineWidth = 30
            self.dismissSettingsView(self.settings_bg.contentView.subviews.last! as? UIButton)
            settings_sections[1] = "paintBrush"
        } else {
            self.drawing_container.strokeColor = UIColor.white
            self.drawing_container.lineWidth = 10
            self.dismissSettingsView(self.settings_bg.contentView.subviews.last! as? UIButton)
            settings_sections[1] = "erase_icon.png"
        }
    }
    
    @objc func restartCanvas(_ sender: UIButton!) {
        self.drawing_container.restartDrawingView()
        self.dismissSettingsView(self.settings_bg.contentView.subviews.last! as? UIButton)
    }
    
    @objc func updateColor(_ sender: UIButton!) {
        self.drawing_container.strokeColor = sender.backgroundColor!
        self.dismissSettingsView(self.settings_bg.contentView.subviews[self.settings_bg.contentView.subviews.count - 3] as? UIButton)
    }
    
    @objc func showRGBScale(_ sender: UIButton!) {
        let bg = UIView(frame: CGRect(x: (self.frame.size.width / 2) - 150, y: -300, width: 300, height: 300))
        bg.backgroundColor = UIColor.lightGray
        bg.layer.cornerRadius = 20
        self.settings_bg.contentView.addSubview(bg)
        let sections = [["R:", UIColor(red: (244 / 255), green: (66 / 255), blue: (66 / 255), alpha: 1)],
                        ["G:", UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1)],
                        ["B:", UIColor(red: (66 / 255), green: (66 / 255), blue: (244 / 255), alpha: 1)],
                        ["A:", UIColor(red: (235 / 255), green: (235 / 255), blue: (235 / 255), alpha: 1)]]
        let preview = UIButton(frame: CGRect(x: bg.frame.origin.x, y: bg.frame.origin.x + bg.frame.size.height + 2, width: 149, height: 35))
        preview.layer.cornerRadius = preview.frame.size.height / 2
        preview.backgroundColor = UIColor.black
        preview.addTarget(self, action: #selector(self.updateColor(_:)), for: UIControl.Event.touchUpInside)
        preview.setTitle("+", for: UIControl.State.normal)
        preview.titleLabel?.textColor = UIColor.white
        preview.titleLabel?.font = preview.titleLabel?.font.withSize(45)
        preview.titleLabel?.textAlignment = NSTextAlignment.center
        preview.alpha = 0
        self.settings_bg.contentView.addSubview(preview)
        for i in 0..<sections.count {
            let lbl = UILabel(frame: CGRect(x: 16, y: ((i * 20) * 2) + 20, width: 25, height: 25))
            lbl.font = lbl.font.withSize(25)
            lbl.text = sections[i][0] as? String
            lbl.textColor = sections[i][1] as? UIColor
            bg.addSubview(lbl)
            let sldr = UISlider(frame: CGRect(x: 57, y: lbl.frame.origin.y, width: 235, height: 20))
            sldr.isContinuous = true
            sldr.maximumValue = 255
            if i == 3 {
                sldr.maximumValue = 1
                sldr.value = 1
            }
            sldr.minimumValue = 0
            sldr.thumbTintColor = UIColor.white
            sldr.tintColor = sections[i][1] as? UIColor
            sldr.addTarget(self, action: #selector(self.updateColorsSlider(_:)), for: UIControl.Event.valueChanged)
            sldr.center.y = lbl.center.y
            bg.addSubview(sldr)
        }
        for i in 0..<sections.count {
            var x_pos = 40
            var y_pos = 180
            if i % 2 != 0 {
                x_pos = 145
            }
            if i > 1 {
                y_pos = 225
            }
            let lbl = UILabel(frame: CGRect(x: x_pos, y: y_pos, width: 25, height: 25))
            lbl.font = lbl.font.withSize(25)
            lbl.text = sections[i][0] as? String
            lbl.textColor = sections[i][1] as? UIColor
            bg.addSubview(lbl)
            let txt = UITextField(frame: CGRect(x: x_pos + 25, y: y_pos, width: 75, height: 25))
            txt.addTarget(self, action: #selector(self.updateColorsTxt(_:)), for: UIControl.Event.editingDidEnd)
            txt.textColor = UIColor.white
            txt.font = txt.font?.withSize(25)
            txt.backgroundColor = UIColor.darkGray
            txt.layer.cornerRadius = 10
            txt.keyboardType = UIKeyboardType.numberPad
            txt.text = "0"
            if i == 3 {
                txt.text = "1"
            }
            txt.textAlignment = NSTextAlignment.center
            txt.delegate = self
            bg.addSubview(txt)
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.settings_bg.contentView.subviews[self.settings_bg.contentView.subviews.count - 3].alpha = 0
        }, completion: { (_) in
            UIView.animate(withDuration: 0.7, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                sender.superview?.frame.origin.y = self.frame.size.height
                bg.center = self.center
            }, completion: { (_) in
                preview.frame.origin.y = bg.frame.origin.y + bg.frame.size.height + 2
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                    self.settings_bg.contentView.subviews[self.settings_bg.contentView.subviews.count - 3].alpha = 1
                    preview.alpha = 1
                    self.settings_bg.contentView.subviews[self.settings_bg.contentView.subviews.count - 3].frame = CGRect(x: (self.frame.size.width / 2) + 1, y: (self.frame.size.height / 2) + 152, width: 149, height: 35)
                }, completion: nil)
            })
        })
    }
    
    @objc func showLineThicknessScale(_ sender: UIButton!) {
        let bg = UIView(frame: CGRect(x: self.frame.size.width / 2 - 150, y: -100, width: 300, height: 100))
        bg.backgroundColor = UIColor.lightGray
        bg.layer.cornerRadius = 20
        self.settings_bg.contentView.addSubview(bg)
        let ttl = UILabel(frame: CGRect(x: 16, y: 20, width: 268, height: 50))
        ttl.font = ttl.font.withSize(40)
        ttl.text = "Paint Thickness"
        ttl.textColor = UIColor.white
        ttl.textAlignment = NSTextAlignment.center
        bg.addSubview(ttl)
        let sldr = UISlider(frame: CGRect(x: 16, y: 75, width: 268, height: 20))
        sldr.maximumValue = 50
        sldr.minimumValue = 0
        sldr.value = Float(Int(self.drawing_container.lineWidth))
        bg.addSubview(sldr)
        
        let accept = UIButton(frame: CGRect(x: bg.frame.origin.x, y: -35, width: 149, height: 35))
        accept.backgroundColor = UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1)
        accept.layer.cornerRadius = accept.frame.size.height / 2
        accept.layer.masksToBounds = true
        accept.setTitle("+", for: UIControl.State.normal)
        accept.titleLabel?.textAlignment = NSTextAlignment.center
        accept.titleLabel?.textColor = UIColor.white
        accept.addTarget(self, action: #selector(self.setNewLineThickness(_:)), for: UIControl.Event.touchUpInside)
        accept.titleLabel?.font = accept.titleLabel?.font.withSize(30)
        self.settings_bg.contentView.addSubview(accept)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.settings_bg.contentView.subviews[self.settings_bg.contentView.subviews.count - 3].alpha = 0
        }, completion: { (_) in
            UIView.animate(withDuration: 0.7, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                sender.superview?.frame.origin.y = self.frame.size.height
                bg.center = self.center
            }, completion: { (_) in
                accept.frame.origin.y = bg.frame.origin.y + bg.frame.size.height + 2
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                    self.settings_bg.contentView.subviews[self.settings_bg.contentView.subviews.count - 3].alpha = 1
                    accept.alpha = 1
                    self.settings_bg.contentView.subviews[self.settings_bg.contentView.subviews.count - 3].frame = CGRect(x: (self.frame.size.width / 2) + 1, y: (self.frame.size.height / 2) + 52, width: 149, height: 35)
                }, completion: nil)
            })
        })
    }
    
    @objc func setNewLineThickness(_ sender: UIButton!) {
        let sldr = self.settings_bg.contentView.subviews[self.settings_bg.contentView.subviews.count - 2].subviews[1] as? UISlider
        self.drawing_container.lineWidth = CGFloat(Int(sldr!.value))
        self.dismissSettingsView(self.settings_bg.contentView.subviews[self.settings_bg.contentView.subviews.count - 3] as? UIButton)
    }
    
    @objc func showFillBackgroundScale(_ sender: UIButton!) {
        let neatColorPicker = ChromaColorPicker(frame: CGRect(x: (self.frame.size.width / 2) - 150, y: -300, width: 300, height: 300))
        neatColorPicker.padding = 5
        neatColorPicker.stroke = 3
        neatColorPicker.delegate = self
        neatColorPicker.hexLabel.textColor = UIColor.white
        neatColorPicker.backgroundColor = UIColor.lightGray
        neatColorPicker.layer.cornerRadius = 20
        neatColorPicker.layer.masksToBounds = true
        
        self.settings_bg.contentView.addSubview(neatColorPicker)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.settings_bg.contentView.subviews[self.settings_bg.contentView.subviews.count - 2].alpha = 0
        }, completion: { (_) in
            UIView.animate(withDuration: 0.7, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                sender.superview?.frame.origin.y = self.frame.size.height
                neatColorPicker.center.y = self.center.y + 0.000000000001
            }, completion: { (_) in
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                    self.settings_bg.contentView.subviews[self.settings_bg.contentView.subviews.count - 2].alpha = 1
                    self.settings_bg.contentView.subviews[self.settings_bg.contentView.subviews.count - 2].frame = CGRect(x: (self.frame.size.width / 2) - 150, y: (self.frame.size.height / 2) + 152, width: 300, height: 35)
                }, completion: nil)
            })
        })
    }
    
    @objc func updateColorsSlider(_ sender: UISlider!) {
        let r = sender.superview!.subviews[1] as? UISlider
        let g = sender.superview!.subviews[3] as? UISlider
        let b = sender.superview!.subviews[5] as? UISlider
        let a = sender.superview!.subviews[7] as? UISlider
        
        let r_value = CGFloat(r!.value)
        let g_value = CGFloat(g!.value)
        let b_value = CGFloat(b!.value)
        let a_value = CGFloat(a!.value)
        
        self.settings_bg.contentView.subviews.last!.backgroundColor = UIColor(red: (r_value / 255), green: (g_value / 255), blue: (b_value / 255), alpha: a_value)
        
        let r_txt = sender.superview!.subviews[9] as? UITextField
        let g_txt = sender.superview!.subviews[11] as? UITextField
        let b_txt = sender.superview!.subviews[13] as? UITextField
        let a_txt = sender.superview!.subviews[15] as? UITextField
        
        r_txt?.text = String(Int(r!.value))
        g_txt?.text = String(Int(g!.value))
        b_txt?.text = String(Int(b!.value))
        a_txt?.text = String(Float(a!.value))
    }
    
    @objc func updateColorsTxt(_ sender: UITextField!) {
        if let value = Int(sender.text!) {
            if sender == sender.superview?.subviews.last as? UITextField {
                if value > 1 {
                    sender.text = "1"
                } else if value < 0 {
                    sender.text = "0"
                }
            } else {
                if value > 255 {
                    sender.text = "255"
                } else if value < 0 {
                    sender.text = "0"
                }
            }
        } else {
            sender.text = ""
        }
        
        let r = sender.superview!.subviews[9] as? UITextField
        let g = sender.superview!.subviews[11] as? UITextField
        let b = sender.superview!.subviews[13] as? UITextField
        let a = sender.superview!.subviews[15] as? UITextField
        
        let r_value = Int(r!.text!)
        let g_value = Int(g!.text!)
        let b_value = Int(b!.text!)
        let a_value = Int(a!.text!)
        
        self.settings_bg.contentView.subviews.last!.backgroundColor = UIColor(red: (CGFloat(r_value!) / 255), green: (CGFloat(g_value!) / 255), blue: (CGFloat(b_value!) / 255), alpha: CGFloat(a_value!))
        
        let r_sldr = sender.superview!.subviews[1] as? UISlider
        let g_sldr = sender.superview!.subviews[3] as? UISlider
        let b_sldr = sender.superview!.subviews[5] as? UISlider
        let a_sldr = sender.superview!.subviews[7] as? UISlider
        
        r_sldr?.value = Float(r_value!)
        g_sldr?.value = Float(g_value!)
        b_sldr?.value = Float(b_value!)
        a_sldr?.value = Float(a_value!)
    }
    
    @objc func removeTip(_ sender: UIButton!) {
        UIView.animate(withDuration: 0.5, animations: {
            sender.superview!.alpha = 0
        }) { (finished: Bool) in
            sender.superview!.removeFromSuperview()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
            let type = UILabel(frame: CGRect(x: 16, y: drawing_container.center.y, width: drawing_container.frame.size.width - 32, height: 200))
            
            type.textAlignment = NSTextAlignment.center
            type.font = type.font.withSize(35)
            type.numberOfLines = 2
            type.center = CGPoint(x: drawing_container.frame.size.width / 2, y: drawing_container.frame.size.height / 2)
            type.alpha = 0
            if currentSection == 2 {
                let sentiment = SentimentClassificationService().predictSentiment(from: textField.text!)
                
                type.text = "Sentence's Predicted Sentiment Level:\n\(sentiment.emoji)"
                type.textColor = sentiment.color
                drawing_container.addSubview(type)
                UIView.animate(withDuration: 0.5) {
                    type.alpha = 1
                }
            } else {
                let gender = try? NameClassificationService().predictGender(from: textField.text!)
                
                type.text = "Name's Predicted Gender: \(gender!.gender.string.capitalizingFirstLetter())\nConfidence: \(gender!.probability * 100)%"
                type.textColor = UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1)
                drawing_container.addSubview(type)
                UIView.animate(withDuration: 0.5) {
                    type.alpha = 1
                }
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        drawing_container.subviews.forEach { subview in
            if (subview as? UILabel) != nil {
                UIView.animate(withDuration: 0.5, animations: {
                    subview.alpha = 0
                }) { _ in
                    subview.removeFromSuperview()
                }
            }
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let main_touch = touches.first?.location(in: self)
        let sectionsTouchLocation = touches.first?.location(in: self.sections_container)
        let dismissIntroTouch = touches.first?.location(in: self.dismissIntro.superview)
        
        if(dismissIntro.frame.contains(dismissIntroTouch!)) {
            UIView.animate(withDuration: 0.5) {
                self.dismissIntro.superview?.superview?.alpha = 0 // FIXED: NOT GETTING RID OF THE BACKGROUND BLUR
                self.dismissIntro.superview?.removeFromSuperview()
                let info = UIView(frame: CGRect(x: 16, y: self.frame.size.height, width: self.drawing_container.frame.size.width - 32, height: 50))
                info.backgroundColor = UIColor.lightGray
                info.layer.cornerRadius = info.frame.size.height / 2
                self.drawing_container.addSubview(info)
                let closeInfo = UIButton(frame: CGRect(x: info.frame.size.width - 50, y: 12.5, width: 25, height: 25))
                closeInfo.setImage(UIImage(named: "cancel_icon.png"), for: UIControl.State.normal)
                closeInfo.backgroundColor = UIColor.clear
                closeInfo.addTarget(self, action: #selector(self.removeTip(_:)), for: UIControl.Event.touchUpInside)
                info.addSubview(closeInfo)
                let infoLbl = UILabel(frame: CGRect(x: 16, y: 0, width: info.frame.size.width - 66, height: info.frame.size.height))
                infoLbl.text = "Tip: Draw a number and press play for the Neural Network to recognize it."
                infoLbl.textColor = UIColor.white
                infoLbl.set(textColor: UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 1), range: NSMakeRange(0, 4))
                info.addSubview(infoLbl)
                UIView.animate(withDuration: 0.5, animations: {
                    info.frame.origin.y = self.drawing_container.frame.size.height - 70
                }) { _ in
                    self.displayInfoTip(message: "Tip: Use the settings gear for some helpful tools.")
                    UIView.animate(withDuration: 0.5) {
                        info.frame.origin.y -= 70
                    }
                }
            }
        }
        
        if sections_container.isUserInteractionEnabled {
            for i in 0..<self.sections_container.subviews.count {
                if self.sections_container.subviews[i].frame.contains(sectionsTouchLocation!) && self.sections_container.subviews[i].alpha != 0 {
                    for i in 0..<self.sections_container.subviews.count {
                        if self.sections_container.subviews[i].alpha == 1 {
                            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                                self.sections_container.subviews[i].alpha = 0.75
                            }, completion: nil)
                        }
                    }
                    self.currentSection = i
                    if self.currentSection == 2 {
                        self.drawing_container.close()
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.25) {
                            let bar = UITextField(frame: CGRect(x: 16, y: self.drawing_container.center.y, width: self.drawing_container.frame.size.width - 32, height: 50))
                            bar.backgroundColor = UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 0.5)
                            bar.layer.cornerRadius = bar.frame.size.height / 2
                            bar.layer.masksToBounds = true
                            bar.textAlignment = NSTextAlignment.center
                            bar.textColor = UIColor.white
                            bar.alpha = 0
                            bar.font = bar.font?.withSize(40)
                            bar.keyboardAppearance = UIKeyboardAppearance.dark
                            bar.returnKeyType = UIReturnKeyType.done
                            bar.placeholder = "Type a sentence"
                            bar.delegate = self
                            self.drawing_container.addSubview(bar)
                            UIView.animate(withDuration: 0.5, animations: {
                                bar.frame.origin.y = 50
                                bar.alpha = 1
                            }) { _ in
                                bar.becomeFirstResponder()
                            }
                        }
                    } else if self.currentSection == 1 {
                        drawing_container.subviews.forEach { subview in
                            UIView.animate(withDuration: 0.5) {
                                subview.alpha = 0
                            }
                            subview.removeFromSuperview()
                        }
                        self.drawing_container.close()
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.25) {
                            let bar = UITextField(frame: CGRect(x: 16, y: self.drawing_container.center.y, width: self.drawing_container.frame.size.width - 32, height: 50))
                            bar.backgroundColor = UIColor(red: (66 / 255), green: (244 / 255), blue: (178 / 255), alpha: 0.5)
                            bar.layer.cornerRadius = bar.frame.size.height / 2
                            bar.layer.masksToBounds = true
                            bar.textAlignment = NSTextAlignment.center
                            bar.textColor = UIColor.white
                            bar.alpha = 0
                            bar.font = bar.font?.withSize(40)
                            bar.keyboardAppearance = UIKeyboardAppearance.dark
                            bar.returnKeyType = UIReturnKeyType.done
                            bar.placeholder = "Type a name"
                            bar.delegate = self
                            self.drawing_container.addSubview(bar)
                            UIView.animate(withDuration: 0.5, animations: {
                                bar.frame.origin.y = 50
                                bar.alpha = 1
                            }) { _ in
                                bar.becomeFirstResponder()
                            }
                        }
                    } else {
                        self.drawing_container.open()
                    }
                    
                    if self.currentSection == 3 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.displayInfoTip(message: "Tip: Your drawing can be of a Cat's face, Airplane, or Rainbow")
                        }
                    }
                    current_title.fadeTransition(0.4)
                    self.current_title.text = self.sections[self.currentSection]
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                        self.sections_container.subviews[i].alpha = 1
                        self.main_underline.center.x = self.sections_container.subviews[i].center.x + 230
                    }, completion: { (finished: Bool) in
                        self.drawing_container.restartDrawingView()
                    })
                }
            }
        }
        
        if menu_container.frame.contains(main_touch!) && menu_activated_count % 2 == 0 { // User did activate menu
            menu_activated_count += 1
            articlesBG.frame =  self.bounds
            articlesBG.effect = UIBlurEffect(style: UIBlurEffect.Style.light)
            articlesBG.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            articlesBG.alpha = 0
            self.insertSubview(articlesBG, belowSubview: self.menu_container)
            
            let menuTTL = UILabel(frame: CGRect(x: 16, y: 120, width: self.frame.size.width - 32, height: 50))
            menuTTL.text = "Articles"
            menuTTL.textColor = UIColor.white
            menuTTL.textAlignment = NSTextAlignment.center
            menuTTL.font = UIFont.systemFont(ofSize: 45)
            menuTTL.backgroundColor = UIColor.clear
            menuTTL.alpha = 0
            articlesBG.contentView.addSubview(menuTTL)
            UIView.animate(withDuration: 1, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.menu_container.subviews[0].transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 4))
                self.menu_container.subviews[1].alpha = 0
                self.menu_container.subviews[2].transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 4) * -1)
                self.menu_container.subviews[0].center.x = self.menu_container.frame.size.width / 2
                self.menu_container.subviews[2].center.x = self.menu_container.frame.size.width / 2
                self.menu_container.subviews[0].center.y = self.menu_container.frame.size.height / 2
                self.menu_container.subviews[2].center.y = self.menu_container.frame.size.height / 2
                self.menu_container.frame.origin.x -= 100
                self.menu_container.frame.origin.y += 100
                self.articlesBG.alpha = 1
                menuTTL.alpha = 1
            }, completion: { (_) in
                let presentation = Presentation(frame: CGRect(x: 0, y: 1900, width: 720, height: 540))
                presentation.setup(presentationImages: self.presentationImages)
                presentation.center = self.center
                presentation.transform = CGAffineTransform(scaleX: 0, y: 0)
                self.articlesBG.contentView.addSubview(presentation)
                UIView.animate(withDuration: 0.5, animations: {
                    presentation.transform = CGAffineTransform.identity
                })
                self.menuActivated = true
            })
        } else if menu_container.frame.contains(main_touch!) && menu_activated_count % 2 != 0 { // User didn't
            menu_activated_count += 1
            self.menuActivated = false
            UIView.animate(withDuration: 1, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.menu_container.subviews[0].transform = CGAffineTransform.identity
                self.menu_container.subviews[1].alpha = 1
                self.menu_container.subviews[2].transform = CGAffineTransform.identity
                self.menu_container.subviews[0].center.x = self.menu_container.frame.size.width / 2
                self.menu_container.subviews[2].center.x = self.menu_container.frame.size.width / 2
                self.menu_container.subviews[0].frame.origin.y = 0
                self.menu_container.subviews[2].frame.origin.y = 30
                self.menu_container.frame.origin.x += 100
                self.menu_container.frame.origin.y -= 100
                self.articlesBG.alpha = 0
            }, completion: { (_) in
                self.articlesBG.contentView.subviews.forEach { article in article.removeFromSuperview() }
                self.articlesBG.removeFromSuperview()
            })
        }
        
        if menuActivated == true {
            for i in 0..<self.subviews[self.subviews.count - 3].subviews.count {
                if self.subviews[self.subviews.count - 3].subviews[i].frame.contains(main_touch!) {
                    // Article Was Pressed
                }
            }
        }
        
        if settings_switcher.frame.contains(main_touch!) && settings_switcher.alpha == 1 {
            settings_bg.frame = self.bounds
            settings_bg.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            settings_bg.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            settings_bg.alpha = 0
            self.addSubview(settings_bg)
            let switcher_bg = UIView(frame: CGRect(x: (self.frame.size.width / 2) - 117.5, y: (self.frame.size.height / 2) - 100, width: 225, height: 200))
            switcher_bg.center = self.center
            switcher_bg.backgroundColor = UIColor.lightGray
            switcher_bg.layer.cornerRadius = 15
            switcher_bg.transform = CGAffineTransform(scaleX: 0, y: 0)
            settings_bg.contentView.addSubview(switcher_bg)
            let cancel_button = UIButton(frame: CGRect(x: 0, y: switcher_bg.frame.origin.y + 102, width: 200, height: 35))
            cancel_button.setImage(UIImage(named: "cancel_icon.png"), for: UIControl.State.normal)
            cancel_button.backgroundColor = UIColor(red: (244 / 255), green: (85 / 255), blue: (66 / 255), alpha: 1)
            cancel_button.layer.cornerRadius = cancel_button.frame.size.height / 2
            cancel_button.center.x = self.center.x
            cancel_button.addTarget(self, action: #selector(self.dismissSettingsView(_:)), for: UIControl.Event.touchUpInside)
            cancel_button.transform = CGAffineTransform(scaleX: 1, y: 0)
            settings_bg.contentView.addSubview(cancel_button)
            for i in 0..<settings_sections.count {
                var pos_x = (i * 50) + (i * 25)
                if i > 2 {
                    pos_x = Int(switcher_bg.subviews[i - 3].frame.origin.x)
                }
                
                var pos_y = 85
                if i < 3 {
                    pos_y = 15
                }
                
                let switcher_section = UIButton(frame: CGRect(x: pos_x, y: pos_y, width: 75, height: 85))
                switcher_section.setImage(UIImage(named: settings_sections[i]), for: UIControl.State.normal)
                switcher_section.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
                switcher_section.backgroundColor = UIColor.clear
                if i == 0 { // Paint Icon
                    switcher_section.addTarget(self, action: #selector(self.showChromaScale(_:)), for: UIControl.Event.touchUpInside)
                } else if i == 1 { // Erase Icon
                    switcher_section.addTarget(self, action: #selector(self.activateEraserOnCanvas(_:)), for: UIControl.Event.touchUpInside)
                } else if i == 2 { // Restart Icon
                    switcher_section.addTarget(self, action: #selector(self.restartCanvas(_:)), for: UIControl.Event.touchUpInside)
                } else if i == 3 { // RGB Scale Icon
                    switcher_section.addTarget(self, action: #selector(self.showRGBScale(_:)), for: UIControl.Event.touchUpInside)
                } else if i == 4 { // Line Thickness Icon
                    switcher_section.addTarget(self, action: #selector(self.showLineThicknessScale(_:)), for: UIControl.Event.touchUpInside)
                } else if i == 5 { // Fill Icon
                    switcher_section.addTarget(self, action: #selector(self.showFillBackgroundScale(_:)), for: UIControl.Event.touchUpInside)
                }
                switcher_bg.addSubview(switcher_section)
            }
            UIView.animate(withDuration: 0.7, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.settings_bg.alpha = 1
                switcher_bg.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }, completion: { (_) in
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                    switcher_bg.transform = CGAffineTransform.identity
                    cancel_button.transform = CGAffineTransform.identity
                }, completion: nil)
            })
        }
    }
    
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        if colorPicker.center.y == self.center.y {
            self.drawing_container.strokeColor = color
        } else {
            self.drawing_container.backgroundColor = color
        }
        self.dismissSettingsView(self.settings_bg.contentView.subviews[self.settings_bg.contentView.subviews.count - 2] as? UIButton)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

PlaygroundPage.current.liveView = MainView(frame: CGRect(x: 0, y: 0, width: 768, height: 1024))
